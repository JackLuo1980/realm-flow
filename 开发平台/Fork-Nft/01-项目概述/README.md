# Fork-Nft 项目概述

> 创建时间: 2026-03-20
> 来源: Claude Code 项目分析
> 仓库: https://github.com/JackLuo1980/Fork-Nft

## 项目定位

**Fork-Nft** 是 FLVX 的通用转发面板分支，面向 `nftables / realm` 多引擎场景，并兼容现有面板管理体验。

- 控制面继续使用 FLVX 面板模型（用户/节点/隧道/转发）
- 数据面支持按转发选择引擎（当前可选 `gost` / `nftables` / `realm`）
- 提供一键部署、增量同步、联调测试与迁移能力

## 基本信息

| 项目 | 内容 |
|------|------|
| **仓库名** | Fork-Nft |
| **上游项目** | https://github.com/bqlpfy/flux-panel (FLVX) |
| **你的 Fork** | https://github.com/JackLuo1980/Fork-Nft |
| **本地路径** | `~/Fork-Nft` |
| **许可证** | Apache License 2.0 |
| **主要语言** | Go, TypeScript, Python, Shell |
| **当前分支** | main |
| **当前版本** | 2.1.9-alpha5 |

## 技术栈

### 后端
- **语言**: Go 1.24
- **框架**: GORM + net/http
- **数据库**: SQLite / PostgreSQL
- **认证**: JWT (无 Bearer 前缀)

### 前端
- **框架**: React + Vite (rolldown-vite)
- **UI**: shadcn bridge + Tailwind v4
- **状态**: H5 模式检测

### 节点代理
- **语言**: Go 1.23
- **核心**: forked GOST v3
- **通信**: WebSocket + AES 加密

## 核心功能

- ✅ 支持 TCP / UDP 转发
- ✅ 支持端口转发与隧道转发
- ✅ 支持节点分享（面板对接面板）
- ✅ 支持分组权限管理（隧道分组、用户分组）
- ✅ 支持批量下发、批量启停等运维操作
- ✅ 支持按隧道账号控制转发与流量策略
- ✅ 支持转发级引擎选择（`gost` / `nftables` / `realm`）
- ✅ 支持从 PO0 增量同步转发到面板（可锁定 `nftables`）

## 近期核心改动

### 1) 转发引擎字段全链路打通
- `forward.engine` 已贯通后端模型、API、列表展示、导入导出与迁移
- 后端下发节点运行命令时会显式携带 `forwarder.engine`
- 前端转发配置页支持选择引擎并持久化

### 2) PO0 增量同步能力（nft-only）
- 新增脚本：`scripts/sync-po0-forwards-to-panel.sh`
- 从 PO0 的 `/etc/relay-forwards.conf` 读取现有转发，自动同步到面板
- 同步时强制写入 `engine=nftables`

### 3) 引擎联调脚本
- 新增脚本：`scripts/e2e-engine-check.sh`
- 一键验证引擎持久化与下发

### 4) 回归测试补强
- 新增/补强 `engine` 相关单元与契约测试
- 新增脚本级测试：`tests/scripts/test_sync_po0_forwards.sh`

### 5) nft 模式流量统计补齐
- 新增 `scripts/nft-flow-exporter.py`
- 新增 `scripts/install-nft-flow-exporter.sh`
- `go-gost` nftables 规则模板已加入 `counter`

## 默认端口与登录

- 前端面板：`http://<server_ip>:6366/`
- 后端 API：`http://<server_ip>:6365`
- 默认管理员：
  - 用户名：`admin_user`
  - 密码：`admin_user`

> 首次登录后请立即修改默认密码

## 相关链接

- 原项目: https://github.com/bqlpfy/flux-panel
- 仓库: https://github.com/JackLuo1980/Fork-Nft
- Discord: https://discord.gg/Jd8Vphy9jq (Superpowers)
