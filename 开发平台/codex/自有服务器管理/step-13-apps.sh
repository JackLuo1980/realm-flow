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

APT_OPTS=(-o Dpkg::Lock::Timeout=300 -o Acquire::Retries=3)

DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" update -y
DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" install -y fail2ban

mkdir -p /etc/fail2ban/jail.d
cat >/etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled = true
backend = systemd
maxretry = 5
findtime = 10m
bantime = 1h
EOF

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now fail2ban >/dev/null 2>&1 || true
else
  service fail2ban restart >/dev/null 2>&1 || true
fi
