# Gemini Process Memory & Context

This file serves as the "Memory Anchor" for all AI interactions related to OpenClaw and development tasks. **Read this file before any operations.**

## Current Environment
- **Local Machine**: macOS
- **OpenClaw Location**: `~/.openclaw`
- **Obsidian Records**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/Gemini`

## Remote Servers
### Server A (OpenClaw Client)
- **IPv6**: `2a01:4f8:151:534a:6::a`
- **WireGuard IP**: `10.0.0.2`
- **User**: `root`
- **Password**: `9hXrzh4z8yBgbvIHVwki`
- **Status**: OpenClaw gateway running as `root` systemd service.
- **SSH**: Authorized key for passwordless access (from local `id_rsa.pub`).

### Server B (Network Gateway)
- **IPv4**: `95.169.166.185`
- **WireGuard IP**: `10.0.0.1`
- **Role**: Provides IPv4 NAT for Server A.

## Key Configurations
- **Local Bot**: `8405474295:AAEc5SY2rw5j6MwQQKaaWyny3_nxW7x_Hjs` (@jackmacaaabot)
  - **Primary Model**: `minimax/MiniMax-M2.7`
- **Cloud Bot**: `8322924053:AAEik4qp8ZJxCtaIMLvuWcDcKqI6u3H1Lnc` (@vps_openclaw_bot)
  - **Primary Model**: `zai/glm-5` (Zhipu GLM)
- **Zhipu AI Key**: `c33a...RnO` (Shared)
- **Telegram User ID**: `1603970047`

## Guidelines
1. All process logs and config updates must be documented in [gemini.md](file:///Users/jack/Library/Mobile%20Documents/iCloud~md~obsidian/Documents/Jack%20Luo/开发平台/Gemini/gemini.md).
2. Credentials and server details are kept in [server_wg_config.md](file:///Users/jack/Library/Mobile%20Documents/iCloud~md~obsidian/Documents/Jack%20Luo/开发平台/Gemini/server_wg_config.md).
3. **Always read this memory file at the start of a session.**
