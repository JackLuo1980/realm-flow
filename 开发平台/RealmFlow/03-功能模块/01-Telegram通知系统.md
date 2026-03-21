# Telegram 通知系统

## 通知类型

```go
const (
    NotifyTrafficAlert    = "traffic_alert"     // 流量告警
    NotifyTrafficExceed   = "traffic_exceed"    // 流量超限
    NotifyNodeDown        = "node_down"         // 节点离线
    NotifyNodeOnline      = "node_online"       // 节点上线
    NotifyForwardDown     = "forward_down"      // 转发故障
    NotifyServerHighLoad  = "server_high_load"  // 服务器高负载
)
```

## 预设规则

| 角色 | 通知类型 |
|------|----------|
| **admin** | 全部通知 |
| **user** | traffic_alert, traffic_exceed, forward_down |

```go
var PresetRules = map[string][]string{
    "admin": {
        NotifyTrafficAlert,
        NotifyTrafficExceed,
        NotifyNodeDown,
        NotifyNodeOnline,
        NotifyForwardDown,
        NotifyServerHighLoad,
    },
    "user": {
        NotifyTrafficAlert,
        NotifyTrafficExceed,
        NotifyForwardDown,
    },
}
```

## 通知触发条件

| 场景 | 触发条件 | 通知对象 |
|------|----------|----------|
| 流量告警 | 使用量 > 阈值的 80% | 隧道所属用户 |
| 流量超限 | 使用量 >= 配额 | 隧道所属用户 + 管理员 |
| 节点离线 | 心跳超时 > 3 分钟 | 管理员 |
| 节点上线 | 离线后恢复上线 | 管理员 |
| 转发故障 | Realm 进程异常退出 | 隧道所属用户 |
| 服务器高负载 | CPU > 90% 或 内存 > 90% | 管理员 |

## 消息模板

### 流量告警

```
📊 流量告警

用户: admin_user
隧道: MyTunnel
已用: 8.5 GB / 10 GB
占比: 85%

时间: 2026-03-20 15:30:00
```

### 流量超限

```
⚠️ 流量超限

用户: admin_user
隧道: MyTunnel
已用: 10.5 GB
配额: 10 GB
超限: 0.5 GB

时间: 2026-03-20 15:35:00
```

### 节点离线

```
🔴 节点离线

节点: HK-Node-1
IP: 154.37.223.172
最后上线: 2026-03-20 15:20:00

时间: 2026-03-20 15:23:00
```

### 节点上线

```
🟢 节点上线

节点: HK-Node-1
IP: 154.37.223.172

时间: 2026-03-20 15:30:00
```

### 转发故障

```
❌ 转发故障

转发: test-forward
节点: HK-Node-1
监听: 0.0.0.0:8080
目标: 1.2.3.4:80

时间: 2026-03-20 15:25:00
```

### 服务器高负载

```
⚡ 负载告警

节点: HK-Node-1
CPU: 95%
内存: 92%
磁盘: 78%

时间: 2026-03-20 15:28:00
```

## 通知配置

### 用户配置

```json
{
  "enabled": true,
  "events": ["traffic_alert", "forward_down"],
  "traffic_threshold": 80
}
```

### Telegram 绑定

用户在面板中输入 Telegram UserID，系统发送验证消息确认绑定。

## 实现流程

```
┌─────────────────────────────────────────────────────┐
│  1. 定时任务检查告警规则                            │
│     └─ 流量检查、心跳检查、负载检查                 │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  2. 发现告警条件                                    │
│     └─ 查询受影响用户的通知配置                     │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  3. 生成通知消息                                    │
│     └─ 使用模板渲染消息内容                         │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  4. 调用 Telegram Bot API                          │
│     └─ sendMessage API                             │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  5. 记录通知日志                                    │
│     └─ notification_logs 表                        │
└─────────────────────────────────────────────────────┘
```

## Telegram Bot 配置

```bash
# 环境变量
TG_BOT_TOKEN=your_bot_token
TG_BOT_API_URL=https://api.telegram.org/bot

# 或使用代理
TG_BOT_API_URL=https://api.telegram.org/bot
TG_PROXY_URL=http://proxy:port
```

## 测试通知

面板提供测试接口，用户可手动触发测试通知验证配置。

```bash
POST /api/notify/test
{
  "type": "traffic_alert"
}
```
