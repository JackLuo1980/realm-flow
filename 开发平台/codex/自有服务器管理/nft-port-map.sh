#!/usr/bin/env bash

set -euo pipefail

FAMILY="${NFT_FAMILY:-ip}"
TABLE="${NFT_TABLE:-nat}"
MAP_NAME="${NFT_MAP:-port_to_dest}"

usage() {
  cat <<'EOF'
Usage:
  sudo bash nft-port-map.sh list
  sudo bash nft-port-map.sh add <port> <dest-ip> [dest-port]
  sudo bash nft-port-map.sh delete <port> [port...]
  sudo bash nft-port-map.sh flush

Environment:
  NFT_FAMILY   nftables family, default: ip
  NFT_TABLE    nftables table, default: nat
  NFT_MAP      map name, default: port_to_dest

Examples:
  sudo bash nft-port-map.sh add 12225 172.81.111.70 12225
  sudo bash nft-port-map.sh add 46687 198.176.52.9 46687
  sudo bash nft-port-map.sh delete 54322 54323
  sudo bash nft-port-map.sh list
  sudo bash nft-port-map.sh flush
EOF
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
  fi
}

map_ref() {
  printf '%s %s %s' "$FAMILY" "$TABLE" "$MAP_NAME"
}

require_map() {
  if ! nft list map "$(map_ref)" >/dev/null 2>&1; then
    echo "Map not found: $(map_ref)"
    exit 1
  fi
}

list_map() {
  nft list map "$(map_ref)"
}

add_element() {
  local port="$1"
  local dest_ip="$2"
  local dest_port="${3:-$1}"

  nft add element "$(map_ref)" "{ ${port} : ${dest_ip} . ${dest_port} }"
}

delete_elements() {
  local payload=""
  local port

  for port in "$@"; do
    payload+="${payload:+, }${port}"
  done

  nft delete element "$(map_ref)" "{ ${payload} }"
}

flush_map() {
  nft flush map "$(map_ref)"
}

main() {
  require_root

  local action="${1:-}"
  shift || true

  case "$action" in
    list)
      require_map
      list_map
      ;;
    add)
      if [[ $# -lt 2 || $# -gt 3 ]]; then
        usage
        exit 1
      fi
      require_map
      add_element "$@"
      ;;
    delete)
      if [[ $# -lt 1 ]]; then
        usage
        exit 1
      fi
      require_map
      delete_elements "$@"
      ;;
    flush)
      require_map
      flush_map
      ;;
    -h|--help|"")
      usage
      ;;
    *)
      echo "Unknown action: $action"
      usage
      exit 1
      ;;
  esac
}

main "$@"
