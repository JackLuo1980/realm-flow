#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get was not found. This script targets Debian/Ubuntu."
  exit 1
fi

APT_OPTS=(
  -o Dpkg::Lock::Timeout=300
  -o Acquire::Retries=3
  -o Dpkg::Options::=--force-confdef
  -o Dpkg::Options::=--force-confold
)

DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" update -y
