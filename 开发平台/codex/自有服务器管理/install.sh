#!/usr/bin/env bash

set -euo pipefail

REPO_RAW_BASE="${REPO_RAW_BASE:-https://raw.githubusercontent.com/JackLuo1980/one-click-system-tuning/main}"
FILES=(
  "one-click-system-tuning.sh"
  "01-bootstrap-curl-update.sh"
  "02-install-base-tools.sh"
  "03-enable-bbr.sh"
  "04-install-fail2ban.sh"
  "05-set-timezone.sh"
)

need_cmd() {
  command -v "$1" >/dev/null 2>&1
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
  if need_cmd curl; then
    curl -fsSL "$url" -o "$output"
  else
    wget -qO "$output" "$url"
  fi
}

main() {
  ensure_fetcher

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  for file in "${FILES[@]}"; do
    download_file "${REPO_RAW_BASE}/${file}" "${tmp_dir}/${file}"
    chmod +x "${tmp_dir}/${file}"
  done

  cd "$tmp_dir"
  bash ./one-click-system-tuning.sh "$@"
}

main "$@"
