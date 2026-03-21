# Fork-Nft 项目索引

> 项目文档同步时间: 2026-03-20
> 本项目遵循标准开发流程，所有文档同步到 Obsidian

## 快速导航

| 文档 | 描述 |
|------|------|
| [项目概述](01-%E9%A1%B9%E7%9B%AE%E6%A6%82%E8%BF%B0/README.md) | 项目定位、技术栈、核心功能 |
| [系统架构](02-%E6%9E%B6%E6%9E%84%E8%AE%BE%E8%AE%A1/%E7%B3%BB%E7%BB%9F%E6%9E%B6%E6%9E%84.md) | 组件关系、数据模型、通信协议 |
| [Bug 修复记录](04-%E5%BC%80%E5%8F%91%E6%97%A5%E5%BF%97/2026-03-20-Bug%E4%BF%AE%E5%A4%8D%E8%AE%B0%E5%BD%95.md) | 2026-03-20 三个 bug 修复详情 |

## 项目信息

| 项目 | 内容 |
|------|------|
| **仓库名** | Fork-Nft |
| **上游项目** | https://github.com/bqlpfy/flux-panel (FLVX) |
| **你的 Fork** | https://github.com/JackLuo1980/Fork-Nft |
| **本地路径** | `~/Fork-Nft` |
| **当前版本** | 2.1.9-alpha5 |
| **默认端口** | 前端 6366, 后端 6365 |

## 快速命令

```bash
# 进入项目
cd ~/Fork-Nft

# 部署
docker compose -f docker-compose-v4.yml up -d

# 测试
cd go-backend && go test ./...

# PO0 同步
bash scripts/sync-po0-forwards-to-panel.sh \
  --po0-host <ip> --po0-password '<pass>' \
  --panel-base 'http://<ip>:6365'
```

## 最近更新

### 2026-03-20
- ✅ BUG-01: 用户名同步修复
- ✅ BUG-02: 端口映射修复
- ✅ BUG-03: nft 流量统计修复
- ✅ 创建项目文档体系

## 目录结构

```
开发平台/Fork-Nft/
├── 01-项目概述/       # 项目定位、技术栈
├── 02-架构设计/       # 系统架构、数据模型
├── 03-功能模块/       # 功能说明
├── 04-开发日志/       # 开发记录、Bug 修复
├── 05-部署运维/       # 部署文档
└── README.md          # 本索引
```
