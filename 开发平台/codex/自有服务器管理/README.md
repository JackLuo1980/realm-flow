# Kejilion Server Bootstrap

把你常用的服务器初始化流程合并成一个独立脚本仓库，运行时不会再去拉外部 `kejilion.sh`。

1. `apt-get install curl`
2. `apt-get update`
3. 使用仓库自带的 `kejilion.sh`
4. 自动执行 `4 -> 32`
5. 自动执行 `5 -> 11`
6. 自动执行 `13 -> 22`
7. 设置时区为 `Asia/Shanghai` 或 `Asia/Hong_Kong`

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
- 也支持简写：`sh`、`hk`

## 说明

- 脚本只做上面的这些步骤，不额外加入其他调优项。
- `kejilion.sh` 已经 vendored 到本仓库，运行时不再访问外部科技脚本地址。
- `install.sh` 会把主脚本和 `kejilion.sh` 一起下载到临时目录再执行。
- 第三方来源说明见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
