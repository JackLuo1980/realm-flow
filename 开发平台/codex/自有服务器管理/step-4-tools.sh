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

DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" install -y \
  curl \
  ca-certificates \
  cron \
  acme \
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
  gnupg \
  lsb-release

repair_package_state() {
  DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" -f install -y || true
  DEBIAN_FRONTEND=noninteractive dpkg --force-confdef --force-confold --configure -a >/dev/null 2>&1 || true
}

purge_conflicting_docker_packages() {
  local pkgs=(
    docker-buildx
    docker-buildx-plugin
    docker-compose
  )
  local pkg

  for pkg in "${pkgs[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
      DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" purge -y "$pkg" >/dev/null 2>&1 || true
    fi
  done
}

print_docker_ce_diagnostics() {
  echo "Docker CE 安装失败，正在打印检测信息并准备重试..."
  echo "=== /etc/os-release ==="
  cat /etc/os-release
  echo "=== 冲突包状态 ==="
  dpkg -l | awk '/docker-(buildx|compose)|docker\.io|containerd|runc/ {print}' || true
  echo "=== Docker 仓库信息 ==="
  cat /etc/apt/sources.list.d/docker.list 2>/dev/null || true
  echo "=== Docker 包候选信息 ==="
  apt-cache policy docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
}

install_docker_ce() {
  local os_id="${ID:-}"
  local os_version="${VERSION_CODENAME:-}"
  local docker_list_path="/etc/apt/sources.list.d/docker.list"

  if [[ -z "$os_id" || -z "$os_version" ]]; then
    . /etc/os-release
    os_id="${ID:-}"
    os_version="${VERSION_CODENAME:-}"
  fi

  if [[ -z "$os_id" || -z "$os_version" ]]; then
    echo "Unable to detect distribution for Docker CE repository setup."
    exit 1
  fi

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/${os_id}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  cat >"${docker_list_path}" <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${os_id} ${os_version} stable
EOF

  apt_get_docker_packages() {
    DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" update -y
    DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin
  }

  purge_conflicting_docker_packages
  if apt_get_docker_packages; then
    return 0
  fi

  print_docker_ce_diagnostics
  purge_conflicting_docker_packages
  DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" update -y
  apt_get_docker_packages
}

repair_package_state
install_docker_ce

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now docker >/dev/null 2>&1 || true
else
  service docker start >/dev/null 2>&1 || true
fi
