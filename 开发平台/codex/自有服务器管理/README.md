# One-Click System Tuning

一条命令完成 Linux 服务器基础调优、网络优化和常用安全设置。

## 一条龙内容

运行后会按顺序完成：

1. 优化 apt 更新源并更新系统
2. 清理系统垃圾文件
3. 创建 1G 虚拟内存
4. 安装并启用 `fail2ban`
5. 开放所有端口
6. 开启 BBR
7. 设置时区为 `Asia/Shanghai`
8. 自动优化 DNS
9. 设置 IPv4 优先
10. 安装基础工具
11. 自动应用内核和网络参数调优
12. 修改 SSH 端口为 `5522`

## 快速开始

在线安装：

```bash
curl -fsSL https://raw.githubusercontent.com/JackLuo1980/one-click-system-tuning/main/install.sh | bash
```

直接执行脚本：

```bash
sudo bash one-click-system-tuning.sh --yes
```

如果你想保留确认提示：

```bash
sudo bash one-click-system-tuning.sh
```

## 参数

- `--yes` 跳过确认提示
- `--timezone Asia/Shanghai` 指定时区

## 默认环境

- 目标系统：Debian / Ubuntu
- 默认时区：`Asia/Shanghai`
- 默认 SSH 端口：`5522`

## 说明

- 脚本会根据公网环境自动判断国内/海外优化策略。
- `install.sh` 负责在线拉取最新版主脚本。
- 如果你在远程 SSH 会话中执行，建议先开 `tmux`。

## 仓库

- 主脚本: `one-click-system-tuning.sh`
- 在线安装入口: `install.sh`
- 许可证: `LICENSE`
