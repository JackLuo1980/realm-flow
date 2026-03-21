#!/bin/bash
# ============================================================
# PO0 中转机 nftables 增量端口转发部署
# 通过状态文件保存线路，支持 add/list/delete/apply
#
# 适用: Ubuntu 22.04 / 24.04
# 用法:
#   bash setup-relay-incremental.sh            # 默认 add
#   bash setup-relay-incremental.sh add        # 增量添加线路
#   bash setup-relay-incremental.sh list       # 查看已保存线路
#   bash setup-relay-incremental.sh delete     # 删除某条线路
#   bash setup-relay-incremental.sh apply      # 按当前状态重生成 nftables
#   bash setup-relay-incremental.sh init       # 首次初始化基础环境
# ============================================================
set -euo pipefail

STATE_FILE="/etc/relay-forwards.conf"
NFT_CONF="/etc/nftables.conf"
SYSCTL_FILE="/etc/sysctl.d/99-relay.conf"

WAN_IF=$(ip -4 route show default | awk '{print $5; exit}')
if [ -z "${WAN_IF:-}" ]; then
  echo "ERROR: failed to detect default NIC"
  exit 1
fi

RELAY_LAN_IP=$(ip -4 addr show "$WAN_IF" | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
if [ -z "${RELAY_LAN_IP:-}" ]; then
  echo "ERROR: failed to detect relay LAN IP"
  exit 1
fi

random_port() {
  local port
  while true; do
    port=$(( RANDOM % 50000 + 10000 ))
    if ! relay_port_exists "$port"; then
      echo "$port"
      return
    fi
  done
}

ensure_state_file() {
  if [ ! -f "$STATE_FILE" ]; then
    sudo install -m 600 /dev/null "$STATE_FILE"
  fi
}

backup_state_file() {
  ensure_state_file
  local backup="${STATE_FILE}.bak.$(date +%F-%H%M%S)"
  sudo cp "$STATE_FILE" "$backup"
}

count_state_rules() {
  if [ ! -f "$STATE_FILE" ]; then
    echo 0
    return
  fi
  awk -F'|' 'NF >= 4 && $1 != "" { count++ } END { print count + 0 }' "$STATE_FILE"
}

count_existing_nft_rules() {
  if [ ! -f "$NFT_CONF" ]; then
    echo 0
    return
  fi
  grep -cE '^define PORT_IN_[0-9]+' "$NFT_CONF" || true
}

safety_check_rule_shrink() {
  local state_count conf_count
  state_count=$(count_state_rules)
  conf_count=$(count_existing_nft_rules)

  if [ "${RELAY_ALLOW_SHRINK:-0}" = "1" ]; then
    return
  fi

  if [ "$conf_count" -gt 0 ] && [ "$state_count" -lt "$conf_count" ]; then
    echo "ERROR: safety check blocked apply."
    echo "  state rules: ${state_count}"
    echo "  current nft config rules: ${conf_count}"
    echo "State file seems incomplete and would overwrite existing forwards."
    echo "If this shrink is intentional, rerun with:"
    echo "  RELAY_ALLOW_SHRINK=1 bash setup-relay-incremental.sh apply"
    exit 1
  fi
}

relay_port_exists() {
  local target_port="$1"
  if [ ! -f "$STATE_FILE" ]; then
    return 1
  fi

  awk -F'|' -v port="$target_port" '
    NF >= 4 && $4 == port { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$STATE_FILE"
}

load_rules() {
  RULE_COUNT=0
  LINE_NAMES=()
  DEST_TARGETS=()
  DEST_PORTS=()
  RELAY_PORTS=()

  if [ ! -f "$STATE_FILE" ]; then
    return
  fi

  while IFS='|' read -r name dest_ip dest_port relay_port; do
    [ -z "${name:-}" ] && continue
    RULE_COUNT=$((RULE_COUNT + 1))
    LINE_NAMES[$RULE_COUNT]="$name"
    DEST_TARGETS[$RULE_COUNT]="$dest_ip"
    DEST_PORTS[$RULE_COUNT]="$dest_port"
    RELAY_PORTS[$RULE_COUNT]="$relay_port"
  done < "$STATE_FILE"
}

validate_ipv4() {
  local ip="$1"
  if ! [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    return 1
  fi

  IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
  for octet in "$o1" "$o2" "$o3" "$o4"; do
    if [ "$octet" -gt 255 ]; then
      return 1
    fi
  done
}

validate_hostname() {
  local host="$1"
  [[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] && [[ "$host" != .* ]] && [[ "$host" != *..* ]]
}

resolve_target_ipv4() {
  local target="$1"
  local resolved=""

  if validate_ipv4 "$target"; then
    echo "$target"
    return 0
  fi

  resolved=$(getent ahostsv4 "$target" 2>/dev/null | awk 'NR==1 {print $1}')
  if [ -z "$resolved" ] && command -v dig >/dev/null 2>&1; then
    resolved=$(dig +short A "$target" | awk 'NF {print; exit}')
  fi

  if [ -z "$resolved" ]; then
    return 1
  fi

  echo "$resolved"
}

validate_port() {
  local port="$1"
  [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]
}

print_rules() {
  load_rules
  echo ""
  echo "Saved relay rules:"
  if [ "$RULE_COUNT" -eq 0 ]; then
    echo "  (empty)"
    return
  fi

  local i
  for i in $(seq 1 "$RULE_COUNT"); do
    echo "  [$i] [${LINE_NAMES[$i]}] :${RELAY_PORTS[$i]} -> ${DEST_TARGETS[$i]}:${DEST_PORTS[$i]}"
  done
}

write_sysctl() {
  sudo tee "$SYSCTL_FILE" >/dev/null <<'EOF'
net.ipv4.ip_forward=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.netfilter.nf_conntrack_max=65536
EOF
  sudo sysctl --system >/dev/null
}

disable_ufw() {
  if systemctl is-active --quiet ufw 2>/dev/null; then
    sudo systemctl disable --now ufw
  fi
}

install_conntrack() {
  sudo apt install -y conntrack >/dev/null 2>&1
}

generate_nftables() {
  safety_check_rule_shrink
  load_rules

  if [ "$RULE_COUNT" -eq 0 ]; then
    echo "ERROR: no rules saved in $STATE_FILE"
    exit 1
  fi

  local nft_vars input_ports nft_dnat nft_snat nft_fwd mss_match mss_set i resolved_ip
  RESOLVED_DEST_IPS=()

  nft_vars="define RELAY_LAN_IP = $RELAY_LAN_IP\n"
  for i in $(seq 1 "$RULE_COUNT"); do
    resolved_ip=$(resolve_target_ipv4 "${DEST_TARGETS[$i]}") || {
      echo "ERROR: failed to resolve target ${DEST_TARGETS[$i]}"
      exit 1
    }
    RESOLVED_DEST_IPS[$i]="$resolved_ip"
    nft_vars+="define DEST_IP_${i}   = ${RESOLVED_DEST_IPS[$i]}\n"
    nft_vars+="define DEST_PORT_${i} = ${DEST_PORTS[$i]}\n"
    nft_vars+="define PORT_IN_${i}   = ${RELAY_PORTS[$i]}\n"
  done

  input_ports="\$PORT_IN_1"
  if [ "$RULE_COUNT" -gt 1 ]; then
    for i in $(seq 2 "$RULE_COUNT"); do
      input_ports+=", \$PORT_IN_${i}"
    done
  fi

  nft_dnat=""
  nft_snat=""
  nft_fwd=""
  for i in $(seq 1 "$RULE_COUNT"); do
    nft_dnat+="        # [${LINE_NAMES[$i]}]\n"
    nft_dnat+="        meta l4proto { tcp, udp } th dport \$PORT_IN_${i} dnat to \$DEST_IP_${i}:\$DEST_PORT_${i}\n"

    nft_snat+="        # [${LINE_NAMES[$i]}]\n"
    nft_snat+="        ip daddr \$DEST_IP_${i} meta l4proto { tcp, udp } th dport \$DEST_PORT_${i} snat to \$RELAY_LAN_IP\n"

    nft_fwd+="        ip daddr \$DEST_IP_${i} meta l4proto { tcp, udp } th dport \$DEST_PORT_${i} accept\n"
  done

  if [ "$RULE_COUNT" -eq 1 ]; then
    mss_match="ip daddr \$DEST_IP_1"
  else
    mss_set="\$DEST_IP_1"
    for i in $(seq 2 "$RULE_COUNT"); do
      mss_set+=", \$DEST_IP_${i}"
    done
    mss_match="ip daddr { ${mss_set} }"
  fi

  sudo cp "$NFT_CONF" "${NFT_CONF}.bak.$(date +%F-%H%M%S)" 2>/dev/null || true

  sudo tee "$NFT_CONF" >/dev/null <<EOF
#!/usr/sbin/nft -f
# ============================================================
# PO0 relay nftables rules
# generated at: $(date '+%Y-%m-%d %H:%M:%S')
# ============================================================
flush ruleset

$(echo -e "$nft_vars")
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state { established, related } accept
        iif "lo" accept
        ip protocol icmp accept

        # SSH anti-scan
        tcp dport 22 ct state new limit rate 10/minute burst 5 packets accept
        tcp dport 22 ct state established accept

        # relay ports
        iifname "$WAN_IF" meta l4proto { tcp, udp } th dport { ${input_ports} } accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state { established, related } accept
$(echo -e "$nft_fwd")
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}

table ip nat {
    chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
$(echo -e "$nft_dnat")
    }

    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
$(echo -e "$nft_snat")
    }
}

table ip mangle {
    chain forward {
        type filter hook forward priority mangle; policy accept;
        ${mss_match} tcp flags syn tcp option maxseg size set 1452
    }
}
EOF

  sudo nft -c -f "$NFT_CONF"
  sudo nft -f "$NFT_CONF"
  # Keep nftables under systemd management immediately (not only on next boot).
  sudo systemctl enable --now nftables >/dev/null
}

init_base() {
  echo "[1/3] write sysctl"
  write_sysctl
  echo "  OK"

  echo "[2/3] disable ufw"
  disable_ufw
  echo "  OK"

  echo "[3/3] install conntrack"
  install_conntrack
  echo "  OK"
}

append_rule() {
  ensure_state_file

  local name dest_target dest_port relay_port default_port

  echo ""
  read -rp "Line name: " name
  name=${name:-default}
  if [[ "$name" == *"|"* ]]; then
    echo "ERROR: name cannot contain |"
    exit 1
  fi

  read -rp "Destination IP or domain: " dest_target
  if ! validate_ipv4 "$dest_target" && ! validate_hostname "$dest_target"; then
    echo "ERROR: invalid IP/domain"
    exit 1
  fi
  if ! resolve_target_ipv4 "$dest_target" >/dev/null; then
    echo "ERROR: failed to resolve destination target"
    exit 1
  fi

  read -rp "Destination port: " dest_port
  if ! validate_port "$dest_port"; then
    echo "ERROR: invalid destination port"
    exit 1
  fi

  default_port=$(random_port)
  read -rp "Relay port [${default_port}]: " relay_port
  relay_port=${relay_port:-$default_port}
  if ! validate_port "$relay_port"; then
    echo "ERROR: invalid relay port"
    exit 1
  fi

  if relay_port_exists "$relay_port"; then
    echo "ERROR: relay port ${relay_port} already exists"
    exit 1
  fi

  echo ""
  echo "Will add:"
  echo "  [${name}] :${relay_port} -> ${dest_target}:${dest_port}"
  read -rp "Apply and regenerate nftables? [Y/n]: " confirm
  confirm=${confirm:-Y}
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
  fi

  backup_state_file
  echo "${name}|${dest_target}|${dest_port}|${relay_port}" | sudo tee -a "$STATE_FILE" >/dev/null

  init_base
  generate_nftables

  echo ""
  echo "Done. Current rules:"
  print_rules
}

delete_rule() {
  ensure_state_file
  load_rules

  if [ "$RULE_COUNT" -eq 0 ]; then
    echo "No saved rules to delete"
    exit 0
  fi

  print_rules
  echo ""

  local index temp_file
  read -rp "Delete rule index: " index
  if ! [[ "$index" =~ ^[0-9]+$ ]] || [ "$index" -lt 1 ] || [ "$index" -gt "$RULE_COUNT" ]; then
    echo "ERROR: invalid index"
    exit 1
  fi

  echo "Will delete: [${LINE_NAMES[$index]}] :${RELAY_PORTS[$index]} -> ${DEST_TARGETS[$index]}:${DEST_PORTS[$index]}"
  read -rp "Confirm delete? [Y/n]: " confirm
  confirm=${confirm:-Y}
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
  fi

  temp_file=$(mktemp)
  awk -F'|' -v target="$index" 'NF >= 4 { count++; if (count != target) print $0 }' "$STATE_FILE" > "$temp_file"
  backup_state_file
  sudo install -m 600 "$temp_file" "$STATE_FILE"
  rm -f "$temp_file"

  if [ -s "$STATE_FILE" ]; then
    init_base
    RELAY_ALLOW_SHRINK=1 generate_nftables
  else
    echo "No rules left, nftables config kept as-is. You can adjust manually if needed."
  fi

  echo ""
  echo "After delete:"
  print_rules
}

apply_rules() {
  ensure_state_file
  init_base
  generate_nftables
  echo ""
  echo "Applied current saved relay rules."
  print_rules
}

show_usage() {
  cat <<'EOF'
Usage:
  bash setup-relay-incremental.sh [command]

Commands:
  add     Add a new relay rule incrementally (default)
  list    Show saved rules
  delete  Delete one saved rule and regenerate nftables
  apply   Regenerate nftables from saved rules
  init    Initialize sysctl / ufw / conntrack only
EOF
}

main() {
  local cmd="${1:-add}"
  case "$cmd" in
    add)
      append_rule
      ;;
    list)
      ensure_state_file
      print_rules
      ;;
    delete)
      delete_rule
      ;;
    apply)
      apply_rules
      ;;
    init)
      ensure_state_file
      init_base
      ;;
    help|-h|--help)
      show_usage
      ;;
    *)
      echo "ERROR: unknown command: $cmd"
      show_usage
      exit 1
      ;;
  esac
}

main "$@"
