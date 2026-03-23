# Kejilion Bootstrap, Rebuilt

这是你自己的独立服务器初始化仓库，不再在运行时调用外部科技脚本。

## 执行顺序

1. `01-bootstrap-curl-update.sh`
2. `02-install-base-tools.sh`
3. `03-enable-bbr.sh`
4. `04-install-fail2ban.sh`
5. `05-set-timezone.sh`

## 在线安装

```bash
curl -fsSL https://raw.githubusercontent.com/JackLuo1980/one-click-system-tuning/main/install.sh | bash
```

## 本地执行

```bash
sudo bash one-click-system-tuning.sh --timezone Asia/Shanghai
```

## 时区参数

- `Asia/Shanghai`
- `Asia/Hong_Kong`
- 简写：`sh`、`hk`

## 说明

- 每一步都是仓库内的本地脚本。
- 不再依赖 `kejilion.sh` 的在线地址。
- 只保留你要的基础工具、BBR、fail2ban 和时区设置。
