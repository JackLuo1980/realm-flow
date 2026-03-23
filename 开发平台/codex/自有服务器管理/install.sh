#!/usr/bin/env bash

set -euo pipefail

REPO_RAW_BASE="${REPO_RAW_BASE:-https://raw.githubusercontent.com/JackLuo1980/one-click-system-tuning/main}"
TARGET_SCRIPT_URL="${TARGET_SCRIPT_URL:-${REPO_RAW_BASE}/one-click-system-tuning.sh}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_curl_or_wget() {
  if need_cmd curl || need_cmd wget; then
    return 0
  fi

  if [ "$(id -u)" -ne 0 ]; then
    echo "curl or wget is required to fetch the installer. Please install one first, or run as root so apt-get can install curl."
    exit 1
  fi

  if need_cmd apt-get; then
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates
  else
    echo "Neither curl nor wget is installed, and apt-get is unavailable."
    exit 1
  fi
}

download_to_stdout() {
  if need_cmd curl; then
    curl -fsSL "$1"
  else
    wget -qO- "$1"
  fi
}

main() {
  ensure_curl_or_wget
  exec bash <(download_to_stdout "$TARGET_SCRIPT_URL") "$@"
}

main "$@"
