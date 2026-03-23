#!/usr/bin/env bash

set -euo pipefail

timezone="${1:-Asia/Shanghai}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

case "$timezone" in
  sh|shanghai|Asia/Shanghai)
    timezone="Asia/Shanghai"
    ;;
  hk|hongkong|hong_kong|Asia/Hong_Kong)
    timezone="Asia/Hong_Kong"
    ;;
esac

if command -v timedatectl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
  timedatectl set-timezone "$timezone"
else
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get was not found. Cannot install tzdata."
    exit 1
  fi
  DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
  ln -snf "/usr/share/zoneinfo/${timezone}" /etc/localtime
  echo "$timezone" >/etc/timezone
fi
