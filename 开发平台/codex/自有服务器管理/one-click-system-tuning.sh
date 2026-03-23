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

supports_color() {
  [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]
}

color_code() {
  if ! supports_color; then
    return 0
  fi

  case "$1" in
    reset) printf '\033[0m' ;;
    bold) printf '\033[1m' ;;
    green) printf '\033[32m' ;;
    red) printf '\033[31m' ;;
    yellow) printf '\033[33m' ;;
    cyan) printf '\033[36m' ;;
  esac
}

color_wrap() {
  local color="$1"
  shift

  if supports_color; then
    printf '%s%s%s' "$(color_code "$color")" "$*" "$(color_code reset)"
  else
    printf '%s' "$*"
  fi
}

step_banner() {
  local label="$1"
  local status="${2:-}"
  local status_color="${3:-}"

  printf '\n%s\n' "$(color_wrap cyan '================================================')"

  if [[ -n "$status" ]]; then
    printf '%s\n' "$(color_wrap bold "$(color_wrap yellow "$label") $(color_wrap "$status_color" "$status")")"
  else
    printf '%s\n' "$(color_wrap bold "$(color_wrap yellow "$label")")"
  fi

  printf '%s\n' "$(color_wrap cyan '================================================')"
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

step_label() {
  case "$1" in
    step-1-bootstrap.sh) printf '基础初始化' ;;
    step-4-tools.sh) printf '常用工具' ;;
    step-5-bbr.sh) printf 'BBR 调优' ;;
    step-13-apps.sh) printf '安全防护' ;;
    step-timezone.sh) printf '时区设置' ;;
    *) printf '%s' "$1" ;;
  esac
}

confirm() {
  cat <<EOF
------------------------------------------------
This will run the following local scripts in order:
1. $(step_label step-1-bootstrap.sh)
2. $(step_label step-4-tools.sh)
3. $(step_label step-5-bbr.sh)
4. $(step_label step-13-apps.sh)
5. $(step_label step-timezone.sh) (${DEFAULT_TIMEZONE} or Asia/Hong_Kong)
------------------------------------------------
EOF

  if [[ "${ASSUME_YES:-false}" == "true" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    return 0
  fi

  read -r -p "Type yes to continue: " answer
  [[ "${answer}" == "yes" ]]
}

run_step() {
  local step="$1"
  shift
  local step_path
  local label
  step_path="$(script_dir)/${step}"
  label="$(step_label "${step}")"

  step_banner "BEGIN ${label}" "RUNNING" "yellow"
  log "Running ${step_path}"
  if bash "${step_path}" "$@"; then
    log "Completed ${label}"
    step_banner "OK ${label}" "SUCCESS" "green"
  else
    local exit_code=$?
    log "Failed ${label} with exit code ${exit_code}"
    step_banner "FAIL ${label}" "FAILED" "red"
    exit "${exit_code}"
  fi
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

  step_banner "START LOCAL SERVER TUNING" "READY" "yellow"
  run_step step-1-bootstrap.sh
  run_step step-4-tools.sh
  run_step step-5-bbr.sh
  run_step step-13-apps.sh
  run_step step-timezone.sh "$timezone"
  step_banner "DONE" "SUCCESS" "green"
  log "All steps finished successfully"
}

main "$@"
