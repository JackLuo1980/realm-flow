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

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  ca-certificates \
  wget \
  sudo \
  socat \
  htop \
  iftop \
  unzip \
  tar \
  tmux \
  btop \
  ncdu \
  fzf \
  vim \
  nano \
  git \
  docker.io

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now docker >/dev/null 2>&1 || true
else
  service docker start >/dev/null 2>&1 || true
fi
