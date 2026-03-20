# RealmFlow

> 基于 nftables + Realm 的双引擎转发面板，支持 TCP/UDP 转发、多维度流量监控与 Telegram 通知

## 项目简介

RealmFlow 是一个完全重写的多引擎转发面板项目，支持 **nftables** 和 **realm** 两种转发引擎。

## 核心特性

- **多协议支持**: TCP / UDP 转发
- **转发模式**: 端口转发 + 隧道转发
- **双引擎支持**: nftables + realm
  - **nftables**: 内核级高性能转发，适合大量规则
  - **realm**: 用户态转发，配置灵活
- **转发级引擎选择**: 每个转发可独立选择引擎
- **多维度监控**: 用户/节点/隧道/转发流量监控
- **服务器监控**: CPU、内存、磁盘、网络状态
- **Telegram 通知**: 预设规则 + 用户自定义配置
- **权限管理**: 分组权限、流量配额
- **批量操作**: 批量下发、启停转发

## 架构概览

```
┌─────────────────────────────────────────────────┐
│         realm-flow-panel (Docker)               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Go API   │  │  React   │  │ 定时任务 │      │
│  │  (Gin)   │  │  前端    │  │  监控    │      │
│  └────┬─────┘  └──────────┘  └──────────┘      │
│       │                                            │
│  ┌────▼──────────────────────────────────────┐   │
│  │     PostgreSQL / SQLite                   │   │
│  │  (forward.engine 字段存储引擎选择)         │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                        │ HTTPS API
                        ▼
┌─────────────────────────────────────────────────┐
│         forward-agent (轻量客户端)               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │nftables  │  │  Realm   │  │ 指标采集 │      │
│  │ 引擎模块 │  │  引擎    │  │ 上报     │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│       │              │                            │
│       └──────┬───────┘                            │
│              ▼                                    │
│  ┌──────────────────────────────────────┐        │
│  │      统一转发管理层                   │        │
│  │ (根据 forward.engine 选择引擎)        │        │
│  └──────────────────────────────────────┘        │
│  ┌──────────┐  ┌──────────┐                      │
│  │ TG通知   │  │ 心跳上报 │                      │
│  └──────────┘  └──────────┘                      │
└─────────────────────────────────────────────────┘
```

## 快速开始

### 面板端部署

```bash
curl -L https://raw.githubusercontent.com/JackLuo1980/realm-flow/main/panel_install.sh | bash
```

### Agent 端部署

```bash
curl -L https://raw.githubusercontent.com/JackLuo1980/realm-flow/main/agent_install.sh | bash
```

## 默认端口

| 服务 | 端口 |
|------|------|
| 前端面板 | 6366 |
| 后端 API | 6365 |

## 默认账号

- 用户名: `admin_user`
- 密码: `admin_user`

⚠️ **首次登录后请立即修改默认密码！**

## 项目结构

```
realm-flow/
├── go-backend/          # Go 后端服务
├── react-frontend/      # React 前端
├── forward-agent/       # 转发 Agent (支持 nftables + realm)
│   ├── nftables/        # nftables 引擎模块
│   ├── realm/           # realm 引擎模块
│   ├── monitor/         # 流量采集
│   └── notify/          # 通知模块
├── docker/              # Docker 配置
├── scripts/             # 部署脚本
└── docs/                # 文档
```

## 功能模块

| 模块 | 描述 |
|------|------|
| 用户管理 | 登录认证、权限控制、流量配额 |
| 节点管理 | 节点注册、状态监控、心跳检测 |
| 隧道管理 | 隧道配置、流量统计、分组管理 |
| 转发管理 | TCP/UDP 转发、批量操作、启停控制 |
| 监控系统 | 多维度流量采集、服务器状态监控 |
| 通知系统 | Telegram 通知、预设规则、自定义配置 |

## 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Go 1.21+ / Gin |
| 前端 | React 18 / Vite / TypeScript |
| 数据库 | PostgreSQL (生产) / SQLite (开发) |
| 转发引擎 | nftables + realm |
| 部署 | Docker / Docker Compose |
| 通知 | Telegram Bot API |

## 文档

- [系统架构](docs/architecture.md)
- [API 文档](docs/api.md)
- [部署指南](docs/deploy.md)
- [开发指南](docs/development.md)

## 参考项目

- [FLVX](https://github.com/Sagit-chu/flvx) - 参考项目
- [Fork-Nft](https://github.com/JackLuo1980/Fork-Nft) - 多引擎参考
- [flux-panel](https://github.com/bqlpfy/flux-panel) - 原始项目
- [Realm](https://github.com/zhboner/realm) - 转发引擎
- [nftables](https://wiki.nftables.org/) - nftables 文档

## 免责声明

本项目仅供个人学习与研究使用。请仅在合法、合规、安全的前提下使用，任何滥用或违法行为后果由使用者自行承担。

## License

Apache License 2.0
