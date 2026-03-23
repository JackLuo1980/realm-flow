#!/usr/bin/env bash

set -euo pipefail

DEFAULT_TIMEZONE="Asia/Shanghai"

usage() {
  cat <<'EOF'
Usage:
  sudo bash one-click-system-tuning.sh [--timezone Asia/Shanghai|Asia/Hong_Kong]

Options:
  --timezone   Set timezone to Asia/Shanghai or Asia/Hong_Kong.
  -h, --help   Show this help text
EOF
}

log() {
  printf '[%s] %s\n' "$(date +'%F %T')" "$*"
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
  fi
}

ensure_apt_get() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get was not found. This script is for Debian/Ubuntu systems."
    exit 1
  fi
}

normalize_timezone() {
  case "${1:-}" in
    ""|sh|shanghai|Asia/Shanghai)
      echo "Asia/Shanghai"
      ;;
    hk|hongkong|hong_kong|Asia/Hong_Kong)
      echo "Asia/Hong_Kong"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

set_timezone() {
  local timezone="$1"
  log "Setting timezone to ${timezone}"

  if command -v timedatectl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
    timedatectl set-timezone "$timezone"
  else
    apt-get install -y tzdata
    ln -snf "/usr/share/zoneinfo/${timezone}" /etc/localtime
    echo "$timezone" >/etc/timezone
  fi
}

install_curl_first() {
  log "Installing curl"
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl
}

update_apt() {
  log "Updating apt"
  DEBIAN_FRONTEND=noninteractive apt-get update -y
}

ensure_local_kejilion() {
  if [[ ! -f ./kejilion.sh ]]; then
    echo "Missing local kejilion.sh. Please keep it in the same directory as this script."
    exit 1
  fi
  chmod +x ./kejilion.sh
}

kejilion_needs_license() {
  if [[ -f /usr/local/bin/k ]] && grep -q '^permission_granted="true"' /usr/local/bin/k 2>/dev/null; then
    return 1
  fi
  return 0
}

run_kejilion_steps() {
  log "Running kejilion steps"

  local input=""
  if kejilion_needs_license; then
    input+="y\n"
  fi
  input+="4\n32\n\n5\n11\n\n13\n22\n\n"

  printf '%b' "$input" | ./kejilion.sh
}

main() {
  local timezone="${DEFAULT_TIMEZONE}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --timezone)
        timezone="$(normalize_timezone "${2:?missing timezone value}")"
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
  ensure_apt_get

  cat <<EOF
------------------------------------------------
Will perform:
1. apt-get install curl
2. apt-get update
3. Download kejilion.sh
4. Install kejilion tools with the equivalent of menu 4 -> 32
5. Run BBR step with the equivalent of menu 5 -> 11
6. Install menu 13 -> 22
7. Set timezone to ${timezone}
------------------------------------------------
EOF

  cd "$(dirname "${BASH_SOURCE[0]}")"

  install_curl_first
  update_apt
  ensure_local_kejilion
  run_kejilion_steps
  set_timezone "$timezone"

  log "Done"
}

main "$@"
