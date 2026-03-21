# RealmFlow API 设计

## 认证相关

```
POST   /api/auth/login        # 用户登录
POST   /api/auth/logout       # 用户登出
GET    /api/auth/me           # 获取当前用户信息
```

### 登录请求

```json
POST /api/auth/login
{
  "username": "admin_user",
  "password": "admin_user"
}
```

### 登录响应

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "admin_user",
    "role": "admin"
  }
}
```

---

## 用户管理

```
GET    /api/users             # 获取用户列表
POST   /api/users             # 创建用户
GET    /api/users/:id         # 获取用户详情
PUT    /api/users/:id         # 更新用户
DELETE /api/users/:id         # 删除用户
GET    /api/users/:id/traffic # 获取用户流量统计
PUT    /api/users/:id/notify  # 更新通知配置
```

---

## 节点管理

```
GET    /api/nodes             # 获取节点列表
POST   /api/nodes             # 创建节点
GET    /api/nodes/:id         # 获取节点详情
PUT    /api/nodes/:id         # 更新节点
DELETE /api/nodes/:id         # 删除节点
GET    /api/nodes/:id/status  # 获取节点状态
GET    /api/nodes/:id/traffic # 获取节点流量统计
```

## 节点 / 服务器生命周期

```
POST   /api/nodes/:id/install     # 下发安装命令 / 安装包
POST   /api/nodes/:id/update      # 更新节点或服务端
POST   /api/nodes/:id/uninstall   # 卸载节点或服务端
GET    /api/nodes/:id/version     # 获取当前版本
POST   /api/nodes/:id/autoupdate  # 触发自动升级检查
GET    /api/nodes/:id/upgrade-log # 获取升级日志
```

### 说明

- 节点端和服务器端都需要支持安装、更新、卸载
- 节点端应支持根据服务器端版本变化自动升级
- 安装/升级流程需要在测试环境先验证，再纳入正式部署流程

---

## 隧道管理

```
GET    /api/tunnels           # 获取隧道列表
POST   /api/tunnels           # 创建隧道
GET    /api/tunnels/:id       # 获取隧道详情
PUT    /api/tunnels/:id       # 更新隧道
DELETE /api/tunnels/:id       # 删除隧道
GET    /api/tunnels/:id/forwards  # 获取隧道的转发列表
GET    /api/tunnels/:id/traffic   # 获取隧道流量统计
```

---

## 转发管理

```
GET    /api/forwards          # 获取转发列表
POST   /api/forwards          # 创建转发
GET    /api/forwards/:id      # 获取转发详情
PUT    /api/forwards/:id      # 更新转发
DELETE /api/forwards/:id      # 删除转发
POST   /api/forwards/:id/start   # 启动转发
POST   /api/forwards/:id/stop    # 停止转发
POST   /api/forwards/batch        # 批量操作
GET    /api/forwards/:id/traffic  # 获取转发流量统计
```

### 批量操作请求

```json
POST /api/forwards/batch
{
  "action": "start",  // start/stop/delete
  "ids": [1, 2, 3, 4, 5]
}
```

---

## 监控相关

```
GET    /api/monitor/traffic           # 获取流量统计
GET    /api/monitor/traffic/user/:id  # 获取用户流量
GET    /api/monitor/traffic/node/:id  # 获取节点流量
GET    /api/monitor/traffic/tunnel/:id # 获取隧道流量
GET    /api/monitor/traffic/forward/:id # 获取转发流量
GET    /api/monitor/server            # 获取服务器状态列表
GET    /api/monitor/server/:id        # 获取节点服务器状态
GET    /api/monitor/dashboard         # 仪表盘数据汇总
```

### 流量统计响应

```json
GET /api/monitor/traffic/user/1?from=2026-03-01&to=2026-03-20
{
  "user_id": 1,
  "upload": 1073741824,     // 字节
  "download": 2147483648,
  "total": 3221225472,
  "records": [
    {
      "date": "2026-03-01",
      "upload": 536870912,
      "download": 1073741824
    }
  ]
}
```

---

## Agent 接口

```
POST   /api/agent/register     # Agent 注册
POST   /api/agent/heartbeat    # 心跳上报
POST   /api/agent/traffic      # 流量上报
POST   /api/agent/status       # 服务器状态上报
GET    /api/agent/config/:node # 获取节点配置
```

### Agent 心跳

```json
POST /api/agent/heartbeat
{
  "node_id": 1,
  "api_key": "xxx",
  "status": "online",
  "version": "1.0.0"
}
```

### 流量上报

```json
POST /api/agent/traffic
{
  "node_id": 1,
  "api_key": "xxx",
  "records": [
    {
      "forward_id": 1,
      "tunnel_id": 1,
      "upload": 1024000,
      "download": 2048000
    }
  ]
}
```

### 服务器状态上报

```json
POST /api/agent/status
{
  "node_id": 1,
  "api_key": "xxx",
  "cpu": 45.5,
  "memory": 62.3,
  "disk": 78.9,
  "network_in": 1048576000,
  "network_out": 2097152000
}
```

---

## 通知相关

```
GET    /api/notify/settings   # 获取通知设置
PUT    /api/notify/settings   # 更新通知设置
POST   /api/notify/test       # 发送测试通知
GET    /api/notify/logs       # 获取通知日志
```

### 测试通知

```json
POST /api/notify/test
{
  "type": "traffic_alert"
}
```

---

## 响应格式

### 成功响应

```json
{
  "code": 0,
  "message": "success",
  "data": { ... }
}
```

### 错误响应

```json
{
  "code": 40001,
  "message": "用户不存在",
  "data": null
}
```

### 错误码

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 40001 | 参数错误 |
| 40002 | 资源不存在 |
| 40101 | 未认证 |
| 40102 | Token 过期 |
| 40301 | 无权限 |
| 50001 | 服务器错误 |
