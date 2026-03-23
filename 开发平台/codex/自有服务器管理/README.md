# Local Server Tuning Steps

这是你自己的独立服务器初始化仓库，所有功能都由仓库内本地脚本完成，不再在运行时调用外部科技脚本。

## 执行顺序

1. `01 基础初始化`
2. `04 常用工具`
3. `05 BBR 调优`
4. `13 安全防护`
5. `time 时区设置`

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
- 不再依赖 `kejilion.sh`。
- `01 基础初始化` 对应 `step-1-bootstrap.sh`。
- `04 常用工具` 对应 `step-4-tools.sh`。
- `05 BBR 调优` 对应 `step-5-bbr.sh`。
- `13 安全防护` 对应 `step-13-apps.sh`。
- `time 时区设置` 对应 `step-timezone.sh`。
