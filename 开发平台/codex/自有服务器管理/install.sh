#!/usr/bin/env bash

set -euo pipefail

REPO_RAW_BASE_GLOBAL="${REPO_RAW_BASE_GLOBAL:-https://raw.githubusercontent.com/JackLuo1980/one-click-system-tuning/main}"
REPO_RAW_BASE_CN="${REPO_RAW_BASE_CN:-https://imgcache.yyyisp.com/shell/JackLuo1980/one-click-system-tuning/main}"
CACHE_BUST="${CACHE_BUST:-$(date +%s%N)}"
FILES=(
  "one-click-system-tuning.sh"
  "step-1-bootstrap.sh"
  "step-4-tools.sh"
  "step-5-bbr.sh"
  "step-13-apps.sh"
  "step-timezone.sh"
)

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

detect_country_code() {
  if ! need_cmd curl; then
    echo ""
    return 0
  fi

  curl -fsSL --max-time 3 https://ipapi.co/country/ 2>/dev/null | tr -d '[:space:]' || true
}

pick_repo_raw_base() {
  local country_code
  country_code="$(detect_country_code)"

  case "$country_code" in
    CN)
      printf '%s' "$REPO_RAW_BASE_CN"
      ;;
    *)
      printf '%s' "$REPO_RAW_BASE_GLOBAL"
      ;;
  esac
}

ensure_fetcher() {
  if need_cmd curl || need_cmd wget; then
    return 0
  fi

  if [ "$(id -u)" -ne 0 ] || ! need_cmd apt-get; then
    echo "curl or wget is required to fetch this installer."
    exit 1
  fi

  DEBIAN_FRONTEND=noninteractive apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates
}

download_file() {
  local url="$1"
  local output="$2"
  local fetch_url="$url"

  if [[ "$fetch_url" == *"?"* ]]; then
    fetch_url="${fetch_url}&t=${CACHE_BUST}"
  else
    fetch_url="${fetch_url}?t=${CACHE_BUST}"
  fi

  if need_cmd curl; then
    curl -fsSL "$fetch_url" -o "$output"
  else
    wget -qO "$output" "$fetch_url"
  fi
}

main() {
  ensure_fetcher

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  repo_raw_base="$(pick_repo_raw_base)"

  for file in "${FILES[@]}"; do
    if ! download_file "${repo_raw_base}/${file}" "${tmp_dir}/${file}"; then
      if [[ "$repo_raw_base" != "$REPO_RAW_BASE_GLOBAL" ]]; then
        download_file "${REPO_RAW_BASE_GLOBAL}/${file}" "${tmp_dir}/${file}"
      else
        return 1
      fi
    fi
    chmod +x "${tmp_dir}/${file}"
  done

  cd "$tmp_dir"
  bash ./one-click-system-tuning.sh --yes "$@"
}

main "$@"
