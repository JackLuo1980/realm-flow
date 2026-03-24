# WireGuard Configuration

## Server B (Gateway)
- **Public IP**: 95.169.166.185
- **WireGuard IP**: 10.0.0.1
- **Listen Port**: 51820
- **Public Key**: `0j0OX7m7gnuXndphgKI6dEif4jz4KxIp3LmGtq6PzE4=`
- **Private Key**: `qKh9VWYJO7oCqgMnFw/LT8ASzVPNUNLIvtT2wv2WsnA=`

## Server A (Client)
- **User**: `root`
- **Password**: `9hXrzh4z8yBgbvIHVwki`
- **IPv6**: 2a01:4f8:151:534a:6::a
- **WireGuard IP**: 10.0.0.2
- **Public Key**: `qBjwdXtm5ImmAZcKsEa/ajwBhQERABvcXVsVu3jDLEQ=`
- **Private Key**: `yODiKEy0Nd7HKizWnQQtEDMgmxPAsLYYiXYryAH8XXA=`

## NAT Status
- Server B handles NAT for 10.0.0.0/24 via eth0.

## OpenClaw Service (Server A)
- **Status**: Running as a user-level systemd service (\`openclaw-gateway\`).
- **Node.js**: v22.22.1
- **Working Directory**: \`~/.openclaw\`
- **Control Commands**:
  - \`systemctl --user status openclaw-gateway\`
  - \`systemctl --user restart openclaw-gateway\`
  - \`journalctl --user -u openclaw-gateway -f\`
