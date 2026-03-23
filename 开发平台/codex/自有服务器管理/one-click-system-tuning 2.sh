#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME="One-Click System Tuning"
DEFAULT_TIMEZONE="Asia/Shanghai"
SSH_PORT="5522"
SWAP_SIZE="1G"

log() {
  printf '[%s] %s\n' "$(date +'%F %T')" "$*"
}

warn() {
  printf '[%s] WARNING: %s\n' "$(date +'%F %T')" "$*" >&2
}

usage() {
  cat <<'EOF'
Usage:
  sudo bash one-click-system-tuning.sh [--yes] [--timezone Asia/Shanghai]

Options:
  --yes         Skip the confirmation prompt.
  --timezone    Set the target timezone. Default: Asia/Shanghai
  -h, --help    Show this help text
EOF
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run this script as root: sudo bash one-click-system-tuning.sh"
    exit 1
  fi
}

require_apt_get() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get was not found. This script currently targets Debian/Ubuntu servers."
    exit 1
  fi
}

apt_install() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

confirm() {
  cat <<EOF
${SCRIPT_NAME}
------------------------------------------------
This will perform the following actions:
1. Optimize apt sources and update the system
2. Clean system junk files
3. Create a 1G swap file
4. Install and enable fail2ban for SSH brute-force protection
5. Open all ports by disabling common firewall rules
6. Enable BBR acceleration
7. Set timezone to ${DEFAULT_TIMEZONE}
8. Automatically optimize DNS for overseas/domestic environments
9. Set IPv4 priority
10. Install base tools: docker wget sudo tar unzip socat btop nano vim
11. Apply kernel and network sysctl tuning
12. Change SSH port to ${SSH_PORT}
------------------------------------------------
EOF

  if [[ "${ASSUME_YES:-false}" == "true" ]]; then
    return 0
  fi

  read -r -p "Type yes to continue: " answer
  [[ "${answer}" == "yes" ]]
}

detect_country() {
  local country=""
  if command -v curl >/dev/null 2>&1; then
    country="$(curl -fsSL --max-time 5 https://ipinfo.io/country 2>/dev/null || true)"
  elif command -v wget >/dev/null 2>&1; then
    country="$(wget -qO- --timeout=5 https://ipinfo.io/country 2>/dev/null || true)"
  fi
  printf '%s' "${country:-UNKNOWN}"
}

optimize_apt_sources() {
  local country mirror_used
  country="$(detect_country)"

  if [[ -f /etc/debian_version ]] && command -v sed >/dev/null 2>&1; then
    if [[ "$country" == "CN" ]]; then
      mirror_used="domestic"
      if [[ -f /etc/apt/sources.list ]]; then
        cp -a /etc/apt/sources.list "/etc/apt/sources.list.bak.$(date +%Y%m%d%H%M%S)"
        sed -i \
          -e 's|http://deb.debian.org/debian|https://mirrors.aliyun.com/debian|g' \
          -e 's|http://security.debian.org/debian-security|https://mirrors.aliyun.com/debian-security|g' \
          -e 's|http://archive.ubuntu.com/ubuntu|https://mirrors.aliyun.com/ubuntu|g' \
          -e 's|http://security.ubuntu.com/ubuntu|https://mirrors.aliyun.com/ubuntu|g' \
          /etc/apt/sources.list
      fi
      for file in /etc/apt/sources.list.d/*.list; do
        [[ -e "$file" ]] || continue
        sed -i \
          -e 's|http://deb.debian.org/debian|https://mirrors.aliyun.com/debian|g' \
          -e 's|http://security.debian.org/debian-security|https://mirrors.aliyun.com/debian-security|g' \
          -e 's|http://archive.ubuntu.com/ubuntu|https://mirrors.aliyun.com/ubuntu|g' \
          -e 's|http://security.ubuntu.com/ubuntu|https://mirrors.aliyun.com/ubuntu|g' \
          "$file"
      done
    else
      mirror_used="default"
    fi
    log "APT source mode: ${mirror_used} (${country})"
  fi
}

update_system() {
  log "Updating apt package index"
  DEBIAN_FRONTEND=noninteractive apt-get update -y

  log "Upgrading system packages"
  DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y
}

clean_system() {
  log "Cleaning system junk"
  DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y
  DEBIAN_FRONTEND=noninteractive apt-get autoclean -y
  journalctl --rotate >/dev/null 2>&1 || true
  journalctl --vacuum-time=1s >/dev/null 2>&1 || true
}

create_swap() {
  local swapfile="/swapfile"
  if swapon --show | awk '{print $1}' | grep -qx "$swapfile"; then
    log "Swap file already exists"
    return 0
  fi

  log "Creating ${SWAP_SIZE} swap file"
  if [[ -f "$swapfile" ]]; then
    rm -f "$swapfile"
  fi

  fallocate -l "${SWAP_SIZE}" "$swapfile" || dd if=/dev/zero of="$swapfile" bs=1M count=1024 status=none
  chmod 600 "$swapfile"
  mkswap "$swapfile" >/dev/null
  swapon "$swapfile"

  if ! grep -q "^${swapfile} " /etc/fstab; then
    echo "${swapfile} none swap sw 0 0" >> /etc/fstab
  fi
}

install_base_tools() {
  log "Installing base tools"
  apt_install curl wget sudo tar unzip socat btop nano vim
  apt_install docker.io

  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now docker >/dev/null 2>&1 || true
  else
    service docker start >/dev/null 2>&1 || true
  fi
}

install_fail2ban() {
  log "Installing fail2ban"
  apt_install fail2ban

  mkdir -p /etc/fail2ban/jail.d
  cat >/etc/fail2ban/jail.d/sshd.local <<EOF
[sshd]
enabled = true
port = ${SSH_PORT}
backend = systemd
maxretry = 5
findtime = 10m
bantime = 1h
EOF

  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now fail2ban >/dev/null 2>&1 || true
  else
    service fail2ban restart >/dev/null 2>&1 || true
  fi
}

open_all_ports() {
  log "Opening all ports by disabling common firewalls"

  if command -v ufw >/dev/null 2>&1; then
    ufw disable >/dev/null 2>&1 || true
  fi

  if command -v firewall-cmd >/dev/null 2>&1; then
    systemctl stop firewalld >/dev/null 2>&1 || true
    systemctl disable firewalld >/dev/null 2>&1 || true
  fi

  if command -v iptables >/dev/null 2>&1; then
    iptables -P INPUT ACCEPT || true
    iptables -P FORWARD ACCEPT || true
    iptables -P OUTPUT ACCEPT || true
    iptables -F || true
    iptables -X || true
  fi

  if command -v ip6tables >/dev/null 2>&1; then
    ip6tables -P INPUT ACCEPT || true
    ip6tables -P FORWARD ACCEPT || true
    ip6tables -P OUTPUT ACCEPT || true
    ip6tables -F || true
    ip6tables -X || true
  fi
}

enable_bbr() {
  log "Enabling BBR"
  cat >/etc/sysctl.d/99-one-click-bbr.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
  modprobe tcp_bbr >/dev/null 2>&1 || true
  sysctl --system >/dev/null 2>&1 || true
}

set_timezone() {
  local timezone="$1"
  log "Setting timezone to ${timezone}"

  if command -v timedatectl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
    timedatectl set-timezone "$timezone"
  else
    apt_install tzdata
    ln -snf "/usr/share/zoneinfo/${timezone}" /etc/localtime
    echo "$timezone" >/etc/timezone
  fi
}

optimize_dns() {
  local country dns1 dns2
  country="$(detect_country)"

  if [[ "$country" == "CN" ]]; then
    dns1="223.5.5.5"
    dns2="223.6.6.6"
  else
    dns1="1.1.1.1"
    dns2="8.8.8.8"
  fi

  log "Optimizing DNS with ${dns1} and ${dns2} (${country})"

  mkdir -p /etc/systemd/resolved.conf.d
  cat >/etc/systemd/resolved.conf.d/99-one-click-dns.conf <<EOF
[Resolve]
DNS=${dns1} ${dns2}
FallbackDNS=1.1.1.1 8.8.8.8
EOF

  if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet systemd-resolved >/dev/null 2>&1; then
    systemctl restart systemd-resolved || true
  fi

  cat >/etc/resolv.conf <<EOF
nameserver ${dns1}
nameserver ${dns2}
EOF
}

prefer_ipv4() {
  log "Setting IPv4 preference"
  cat >/etc/gai.conf <<'EOF'
precedence ::ffff:0:0/96 100
EOF
}

apply_sysctl_tuning() {
  local country profile
  country="$(detect_country)"

  if [[ "$country" == "CN" ]]; then
    profile="domestic"
  else
    profile="global"
  fi

  log "Applying kernel and network tuning (${profile})"
  if [[ "$profile" == "domestic" ]]; then
    cat >/etc/sysctl.d/99-one-click-network.conf <<'EOF'
net.ipv4.ip_forward = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 8192
net.core.netdev_max_backlog = 500000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF
  else
    cat >/etc/sysctl.d/99-one-click-network.conf <<'EOF'
net.ipv4.ip_forward = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 4096
net.core.netdev_max_backlog = 250000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_synack_retries = 5
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF
  fi

  sysctl --system >/dev/null 2>&1 || true
}

set_ssh_port() {
  local sshd_config="/etc/ssh/sshd_config"
  local backup_file="${sshd_config}.bak.$(date +%Y%m%d%H%M%S)"

  log "Changing SSH port to ${SSH_PORT}"
  cp -a "$sshd_config" "$backup_file"

  sed -i '/^[[:space:]]*#\?[[:space:]]*Port[[:space:]]\+[0-9]\+/d' "$sshd_config"
  printf '\nPort %s\n' "$SSH_PORT" >>"$sshd_config"

  if command -v sshd >/dev/null 2>&1; then
    sshd -t
  fi

  if systemctl list-unit-files 2>/dev/null | grep -q '^ssh\.service'; then
    systemctl restart ssh
  else
    systemctl restart sshd
  fi

  if command -v systemctl >/dev/null 2>&1; then
    systemctl restart fail2ban >/dev/null 2>&1 || true
  fi
}

print_summary() {
  cat <<EOF
------------------------------------------------
Completed:
1. apt sources optimized and system updated
2. system junk cleaned
3. 1G swap configured
4. fail2ban enabled
5. common firewalls disabled
6. BBR enabled
7. timezone set to ${DEFAULT_TIMEZONE}
8. DNS optimized
9. IPv4 priority enabled
10. base tools installed
11. kernel and network sysctl tuning applied
12. SSH port changed to ${SSH_PORT}
------------------------------------------------
EOF
}

main() {
  local timezone="$DEFAULT_TIMEZONE"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        ASSUME_YES="true"
        shift
        ;;
      --timezone)
        timezone="${2:?missing timezone value}"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  require_root
  require_apt_get

  confirm

  log "Updating package manager prerequisites"
  DEBIAN_FRONTEND=noninteractive apt-get update -y
  apt_install curl wget ca-certificates

  optimize_apt_sources
  update_system
  clean_system
  create_swap
  install_fail2ban
  open_all_ports
  enable_bbr
  set_timezone "$timezone"
  optimize_dns
  prefer_ipv4
  install_base_tools
  apply_sysctl_tuning
  set_ssh_port
  print_summary
}

main "$@"
