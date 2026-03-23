# Kejilion Server Bootstrap

把你常用的服务器初始化流程合并成一个脚本：

1. `apt-get install curl`
2. `apt-get update`
3. 下载 `kejilion.sh`
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
- `install.sh` 只是在线入口，会拉起主脚本执行。
