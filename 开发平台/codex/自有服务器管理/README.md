# Server Bootstrap

This directory contains a single serial bootstrap script for Debian/Ubuntu servers:

- `server-bootstrap.sh`

What it does:

1. Runs `apt-get update`
2. Installs baseline packages such as `curl`, `wget`, `tzdata`, and archive tools
3. Installs Docker
4. Installs ZenTao in a Docker container
5. Installs Cloudreve in a Docker container
6. Installs Uptime Kuma in a Docker container
7. Sets the server timezone to `Asia/Shanghai`

Usage:

```bash
sudo bash server-bootstrap.sh
```

Custom timezone:

```bash
sudo bash server-bootstrap.sh --timezone Asia/Shanghai
```

Default ports:

- ZenTao: `82`
- Cloudreve: `5212`
- Uptime Kuma: `3001`
