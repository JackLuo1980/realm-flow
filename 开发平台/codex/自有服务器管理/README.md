# Local Server Tuning Steps

这是你自己的独立服务器初始化仓库，所有功能都由仓库内本地脚本完成，不再在运行时调用外部科技脚本。

## 执行顺序

1. `基础初始化`
2. `常用工具`
3. `BBR 调优`
4. `安全防护`
5. `时区设置`

## 在线安装

```bash
curl -fsSL https://raw.githubusercontent.com/JackLuo1980/one-click-system-tuning/main/install.sh | bash
```

- 安装入口会自动判断服务器是否位于国内，国内自动切换到国内下载源，国外保持 GitHub 原地址。

## 本地执行

```bash
sudo bash one-click-system-tuning.sh --timezone Asia/Shanghai
```

## nft 端口映射模板

```bash
sudo bash nft-port-map.sh list
sudo bash nft-port-map.sh add 12225 172.81.111.70 12225
sudo bash nft-port-map.sh delete 54322 54323
sudo bash nft-port-map.sh flush
```

## 时区参数

- `Asia/Shanghai`
- `Asia/Hong_Kong`
- 简写：`sh`、`hk`

## 说明

- 每一步都是仓库内的本地脚本。
- 不再依赖 `kejilion.sh`。
- `基础初始化` 对应 `step-1-bootstrap.sh`。
- `常用工具` 对应 `step-4-tools.sh`。
- `BBR 调优` 对应 `step-5-bbr.sh`。
- `安全防护` 对应 `step-13-apps.sh`。
- `时区设置` 对应 `step-timezone.sh`。
- `常用工具` 现在包含 `cron`，并通过 `acme.sh` 官方安装脚本安装 `acme.sh`；Docker 通过官方 CE 仓库安装，若遇到 `docker-buildx` 冲突会自动清理并重试，同时打印检测信息。
