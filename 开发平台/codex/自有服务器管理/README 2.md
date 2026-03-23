# One-Click System Tuning

An open-source, serial one-line bootstrap script for Debian/Ubuntu servers.

## What it does

The script performs the following tasks in order:

1. Optimizes apt sources and updates the system
2. Cleans system junk files
3. Creates a 1G swap file
4. Installs and enables fail2ban for SSH brute-force protection
5. Disables common firewalls to open all ports
6. Enables BBR
7. Sets timezone to `Asia/Shanghai`
8. Optimizes DNS automatically for overseas or domestic environments
9. Sets IPv4 priority
10. Installs base tools: `docker`, `wget`, `sudo`, `tar`, `unzip`, `socat`, `btop`, `nano`, `vim`
11. Applies kernel and network sysctl tuning
12. Changes the SSH port to `5522`

## Usage

```bash
sudo bash one-click-system-tuning.sh --yes
```

If you want to keep the confirmation prompt:

```bash
sudo bash one-click-system-tuning.sh
```

## Notes

- The script is designed for Debian and Ubuntu servers.
- It makes aggressive networking and firewall changes by design.
- If you run it over SSH, consider using `tmux` or a local console.

## License

MIT
