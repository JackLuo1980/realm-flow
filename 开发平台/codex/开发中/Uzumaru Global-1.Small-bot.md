# Uzumaru Global-1.Small-bot

- 记录时间: 2026-03-21
- 状态: 开发中（已完成双环境脚本统一）

## 服务器信息

### Server A（主调试环境）
- 地址: `198.176.54.180`
- SSH端口: `21003`
- 用户: `root`
- 密码: `lpsz800203!`
- 脚本路径: `/opt/tg-exit-bot/bot.py`
- 进程方式: `python3 /opt/tg-exit-bot/bot.py`（单实例）

### Server B（升级目标环境）
- 地址: `198.176.54.180`
- SSH端口: `22009`
- 用户: `root`
- 密码: `lpsz800203!`
- 脚本路径: `/opt/tg-exit-bot/bot.py`
- 服务方式: `rc-service tg-exit-bot`（supervise-daemon 托管）

## 最终版本口径（当前生效）

- `/nm` 顶部同一行展示当前节点与总节点数。
- 当前节点前自动带国旗。
- 节点总数数字加粗。
- 当前模板（核心片段）:

```text
📍 当前：*{cur}*                  📊 共 *{total}* 个节点
```

- Telegram 能力限制：不支持单独设置字体颜色，也不支持单独放大字号。

## 本次升级结果（22009）

- 来源脚本哈希（21003）: `a0750697df7261bafee17b400d2cc32a3847321e41bed0c393c6e21c6ca8effd`
- 升级后脚本哈希（22009）: `a0750697df7261bafee17b400d2cc32a3847321e41bed0c393c6e21c6ca8effd`
- 行数: `314`
- 验收: `rc-service tg-exit-bot restart` 成功，日志出现 `Application started`。
