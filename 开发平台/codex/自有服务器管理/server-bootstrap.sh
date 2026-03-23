#!/usr/bin/env bash

set -euo pipefail

DEFAULT_TIMEZONE="Asia/Shanghai"
ZENTAO_DIR="/home/docker/zentao-server"
CLOUDEVE_DIR="/home/docker/cloudreve"
UPTIME_KUMA_DIR="/home/docker/uptime-kuma"

log() {
  printf '[%s] %s\n' "$(date +'%F %T')" "$*"
}

usage() {
  cat <<'EOF'
Usage:
  sudo bash server-bootstrap.sh [--timezone Asia/Shanghai]

Options:
  --timezone   Set the server timezone. Default: Asia/Shanghai
  -h, --help   Show this help text
EOF
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run as root: sudo bash server-bootstrap.sh"
    exit 1
  fi
}

require_apt_get() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get not found. This script currently targets Debian/Ubuntu servers."
    exit 1
  fi
}

apt_install() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

ensure_docker() {
  if command -v docker >/dev/null 2>&1; then
    return 0
  fi

  log "Installing Docker and Compose plugin"
  apt_install docker.io docker-compose-plugin

  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now docker
  else
    service docker start >/dev/null 2>&1 || true
  fi
}

set_timezone() {
  local timezone="$1"
  log "Setting timezone to ${timezone}"
  if command -v timedatectl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
    timedatectl set-timezone "$timezone"
  else
    apt_install tzdata
    ln -snf "/usr/share/zoneinfo/${timezone}" /etc/localtime
    echo "$timezone" >/etc/timezone
  fi
}

install_prereqs() {
  log "Updating package index"
  DEBIAN_FRONTEND=noninteractive apt-get update -y

  log "Installing baseline packages"
  apt_install curl ca-certificates wget unzip tar tzdata
}

install_zentao() {
  log "Installing ZenTao"
  mkdir -p "$ZENTAO_DIR"

  if docker ps -a --format '{{.Names}}' | grep -qx 'zentao-server'; then
    docker rm -f zentao-server >/dev/null 2>&1 || true
  fi

  docker pull idoop/zentao:latest
  docker run -d \
    --name zentao-server \
    --restart=always \
    -p 82:80 \
    -e ADMINER_USER="root" \
    -e ADMINER_PASSWD="password" \
    -e BIND_ADDRESS="false" \
    -v "${ZENTAO_DIR}:/opt/zbox" \
    --add-host smtp.exmail.qq.com:163.177.90.125 \
    idoop/zentao:latest

  log "ZenTao is available on port 82"
}

install_cloudreve() {
  log "Installing Cloudreve"
  mkdir -p "${CLOUDEVE_DIR}/uploads" "${CLOUDEVE_DIR}/avatar"

  if docker ps -a --format '{{.Names}}' | grep -qx 'cloudreve'; then
    docker rm -f cloudreve >/dev/null 2>&1 || true
  fi

  docker pull cloudreve/cloudreve:latest
  docker run -d \
    --name cloudreve \
    --restart=always \
    -p 5212:5212 \
    -e TZ="${DEFAULT_TIMEZONE}" \
    -v "${CLOUDEVE_DIR}/uploads:/cloudreve/uploads" \
    -v "${CLOUDEVE_DIR}/avatar:/cloudreve/avatar" \
    -v "${CLOUDEVE_DIR}/cloudreve.db:/cloudreve/cloudreve.db" \
    cloudreve/cloudreve:latest

  log "Cloudreve is available on port 5212"
}

install_uptime_kuma() {
  log "Installing Uptime Kuma"
  mkdir -p "${UPTIME_KUMA_DIR}"

  if docker ps -a --format '{{.Names}}' | grep -qx 'uptime-kuma'; then
    docker rm -f uptime-kuma >/dev/null 2>&1 || true
  fi

  docker pull louislam/uptime-kuma:1
  docker run -d \
    --name uptime-kuma \
    --restart=always \
    -p 3001:3001 \
    -e TZ="${DEFAULT_TIMEZONE}" \
    -v "${UPTIME_KUMA_DIR}:/app/data" \
    louislam/uptime-kuma:1

  log "Uptime Kuma is available on port 3001"
}

main() {
  local timezone="${DEFAULT_TIMEZONE}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --timezone)
        timezone="${2:?missing timezone value}"
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
  require_apt_get

  install_prereqs
  ensure_docker

  install_zentao
  install_cloudreve
  install_uptime_kuma
  set_timezone "${timezone}"

  log "All bootstrap steps completed"
}

main "$@"
