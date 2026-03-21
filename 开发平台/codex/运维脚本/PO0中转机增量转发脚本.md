---
title: PO0中转机增量转发脚本
date: 2026-03-19
tags:
  - relay
  - nftables
  - 运维脚本
  - 端口转发
summary: 使用状态文件管理PO0中转机的nftables端口转发，支持增量新增、删除和重生成规则。
---

# PO0中转机增量转发脚本

脚本文件：

- `运维脚本/setup-relay-incremental.sh`

设计目标：

- 不再每次新增落地都重输全部旧线路
- 用 `/etc/relay-forwards.conf` 保存线路状态
- 每次 `add` / `delete` 后自动重生成 `/etc/nftables.conf`
- 保留统一的 nftables 规则结构，降低手改出错概率
- 支持填写动态域名，生成规则时自动解析为当前 IPv4

常用命令：

```bash
bash setup-relay-incremental.sh add
bash setup-relay-incremental.sh list
bash setup-relay-incremental.sh delete
bash setup-relay-incremental.sh apply
bash setup-relay-incremental.sh init
```

跨服务器使用方式：

```bash
scp setup-relay-incremental.sh root@<server_ip>:/root/
ssh root@<server_ip> 'chmod +x /root/setup-relay-incremental.sh'
```

首次接管旧机器建议：

1. 先备份现有 `/etc/nftables.conf`
2. 把现有线路整理录入 `/etc/relay-forwards.conf`
3. 执行 `bash /root/setup-relay-incremental.sh apply`
4. 再使用 `add` 做后续增量维护

补充说明：

- 脚本会自动检测默认网卡和当前内网 IP
- 状态文件里可以保存 IP 或域名；若是域名，执行 `apply` 时会重新解析 DDNS
- 会写入 `ip_forward`、BBR、conntrack 参数
- 会关闭 UFW，并启用 nftables
- relay 端口默认随机生成，但会避开状态文件中已存在的端口
