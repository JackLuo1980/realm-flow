#!/usr/bin/env bash

set -euo pipefail

DEFAULT_TIMEZONE="Asia/Shanghai"

usage() {
  cat <<'EOF'
Usage:
  sudo bash one-click-system-tuning.sh [--yes] [--timezone Asia/Shanghai|Asia/Hong_Kong]

Options:
  --yes         Skip the confirmation prompt.
  --timezone    Set timezone to Asia/Shanghai or Asia/Hong_Kong.
  -h, --help    Show this help text
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

script_dir() {
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

confirm() {
  cat <<EOF
------------------------------------------------
This will run the following local scripts in order:
1. 01-bootstrap-curl-update.sh
2. 02-install-base-tools.sh
3. 03-enable-bbr.sh
4. 04-install-fail2ban.sh
5. 05-set-timezone.sh (${DEFAULT_TIMEZONE} or Asia/Hong_Kong)
------------------------------------------------
EOF

  if [[ "${ASSUME_YES:-false}" == "true" ]]; then
    return 0
  fi

  read -r -p "Type yes to continue: " answer
  [[ "${answer}" == "yes" ]]
}

run_step() {
  local step="$1"
  shift
  log "Running ${step}"
  bash "$(script_dir)/${step}" "$@"
}

main() {
  local timezone="${DEFAULT_TIMEZONE}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        ASSUME_YES="true"
        shift
        ;;
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
  confirm

  run_step 01-bootstrap-curl-update.sh
  run_step 02-install-base-tools.sh
  run_step 03-enable-bbr.sh
  run_step 04-install-fail2ban.sh
  run_step 05-set-timezone.sh "$timezone"

  log "Done"
}

main "$@"
