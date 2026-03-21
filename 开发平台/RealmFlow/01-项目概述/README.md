# RealmFlow 项目概述

> 基于 Go-Gost 的高性能转发面板，前端 UI 风格对齐 FLVX，支持 TCP/UDP 转发、多维度流量监控与 Telegram 通知

## 项目信息

| 项目 | 内容 |
|------|------|
| **名称** | RealmFlow |
| **仓库** | https://github.com/JackLuo1980/realm-flow |
| **创建日期** | 2026-03-20 |
| **参考项目** | https://github.com/Sagit-chu/flvx (FLVX) |
| **状态** | 从头重写中 (2026-03-21 决定抛弃昨天代码) |

## 项目定位

基于 FLVX 功能全集的**独立重写**转发面板，保留 FLVX 全部功能，UI 风格与 FLVX 相似但可优化。独立实现，非 Fork。

### 与 FLVX 的关系

- **功能**: 完全保留 FLVX 所有功能
- **前端 UI**: 尽可能与 FLVX 相似，可优化提升
- **后端**: 独立实现，架构参考 FLVX
- **转发引擎**: 使用 go-gost（与 FLVX 相同）
- **不 Fork 的原因**: 自主可控，可按需扩展

### FLVX 功能清单 (全部保留)

| 页面 | 功能 |
|------|------|
| Dashboard | 总览面板、公告横幅、流量图表、指标卡片 |
| Forward | 转发管理、批量操作、导入导出、诊断、排序 |
| Tunnel | 隧道管理、链式隧道、诊断、IP偏好、流量倍率 |
| Node | 节点管理、安装命令、系统监控、到期续费、双栈 |
| Node / Server Lifecycle | 安装、更新、卸载、版本检测、自动升级 |
| User | 用户管理、角色权限、流量配额、到期管理 |
| Group | 用户组/隧道组、权限分配 |
| Monitor | 节点监控、隧道监控、服务监控 |
| Limit | 限速管理 |
| Config | 面板配置 |
| Panel Sharing | 面板共享 (联邦) |
| Profile | 个人资料 |
| Settings | 主题设置 |

## 技术栈 (对齐 FLVX)

| 层级 | 技术 |
|------|------|
| 后端 | Go 1.24+ / 标准库 net/http + gorilla/websocket |
| ORM | GORM (支持 SQLite + PostgreSQL) |
| 前端 | React 18 / Vite / TypeScript |
| UI 框架 | Radix UI + Tailwind CSS 4 + shadcn/ui 风格 |
| 图表 | Recharts |
| 动画 | Framer Motion |
| 图标 | Lucide React |
| 通知 | Sonner (toast) |
| 转发引擎 | go-gost |
| 部署 | Docker / Docker Compose |

## 架构概览

```
┌─────────────────────────────────────────────────┐
│          realm-flow-panel (Docker)              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Go API   │  │  React   │  │ 定时任务 │     │
│  │(net/http)│  │  前端    │  │  监控    │     │
│  └────┬─────┘  └──────────┘  └──────────┘     │
│       │                                         │
│  ┌────▼─────────────────────────────────────┐  │
│  │        GORM (SQLite / PostgreSQL)        │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                    │ HTTPS API + WebSocket
                    ▼
┌─────────────────────────────────────────────────┐
│              go-gost (转发引擎)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ TCP/UDP  │  │ 链式隧道 │  │ 指标采集 │     │
│  │ 转发     │  │ 管理     │  │ 上报     │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└─────────────────────────────────────────────────┘
```

## 项目结构 (对齐 FLVX)

```
realm-flow/
├── go-backend/                 # Go 后端服务
│   ├── cmd/paneld/main.go      # 入口
│   ├── internal/
│   │   ├── app/                # 应用初始化
│   │   ├── auth/               # JWT 认证
│   │   ├── config/             # 配置管理
│   │   ├── health/             # 健康检查
│   │   ├── http/
│   │   │   ├── handler/        # HTTP 处理器
│   │   │   ├── middleware/     # 中间件 (JWT/CORS/日志/恢复)
│   │   │   ├── response/       # 响应封装
│   │   │   └── router.go       # 路由
│   │   ├── metrics/            # 指标采集
│   │   ├── monitoring/         # 监控限制
│   │   ├── security/           # 加密工具
│   │   ├── store/
│   │   │   ├── model/          # 数据模型
│   │   │   └── repo/           # 数据仓库
│   │   └── ws/                 # WebSocket
│   └── tests/                  # 测试
│
├── go-gost/                    # Gost 转发引擎
│
├── vite-frontend/              # React 前端
│   ├── src/
│   │   ├── api/                # API 调用
│   │   ├── components/         # 通用组件
│   │   │   └── ui/             # UI 基础组件 (shadcn风格)
│   │   ├── hooks/              # 自定义 hooks
│   │   ├── layouts/            # 布局 (admin/h5)
│   │   ├── pages/              # 页面
│   │   ├── themes/             # 主题系统
│   │   ├── types/              # 类型定义
│   │   └── utils/              # 工具函数
│   └── package.json
│
├── docker-compose.yml
├── install.sh                  # 一键安装脚本
└── panel_install.sh            # 面板安装脚本
```

## 测试服务器

| 项目 | 值 |
|------|---|
| **地址** | 91.233.10.38 / 2602:fb54:1801:24::a |
| **端口** | 22 |
| **用户** | root |
| **密码** | 8ldnSIgH86xCRQczqQYi |
| **用途** | 开发测试、部署验证 |

> 注意: 本机不做任何测试，所有测试都在测试服务器上进行

## 部署信息

| 项目 | 默认值 |
|------|--------|
| 前端端口 | `6366` |
| 后端端口 | `6365` |
| 默认管理员 | `admin / admin` |

## 测试入口

- 前端入口: `http://91.233.10.38:16366`
- 后端健康检查: `http://91.233.10.38:16365/api/health`
- 说明: 当前测试环境已完成 Docker 分装部署，但登录页仍处于模块壳子阶段，尚未实现完整的账号登录界面与认证流程

## 参考项目

- **FLVX**: https://github.com/Sagit-chu/flvx
- **Realm**: https://github.com/zhboner/realm
- **go-gost**: https://github.com/go-gost/gost

## 免责声明

本项目仅供个人学习与研究使用。
