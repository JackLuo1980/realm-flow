# RealmFlow 部署说明

## 已完成的功能

### 后端 API (Go)
- ✅ 用户管理（CRUD）
- ✅ 节点管理（CRUD）
- ✅ 隧道管理（CRUD）
- ✅ 转发管理（CRUD）
- ✅ 监控 API（流量统计、仪表盘）
- ✅ 通知 API（Telegram 通知）
- ✅ JWT 认证
- ✅ Agent 接口（心跳、流量上报）
- ✅ 默认 Admin 用户初始化（admin_user / admin_user）

### 前端 (React + TypeScript)
- ✅ Dashboard 页面（集成实时监控 API）
- ✅ 登录页面
- ✅ 用户管理页面
- ✅ 节点管理页面
- ✅ 隧道管理页面
- ✅ 转发管理页面
- ✅ 监控页面

### Forward Agent
- ✅ nftables 引擎（基础实现）
- ✅ realm 引擎（基础实现）
- ✅ 监控数据采集模块
- ✅ Telegram 通知模块

## 部署步骤

### 1. 构建项目

```bash
# 构建后端
cd go-backend
go mod tidy
go build -o ../bin/panel ./cmd/server

# 构建前端
cd ../react-frontend
npm install
npm run build

# 构建 Agent
cd ../forward-agent
go mod tidy
go build -o ../bin/agent .
```

### 2. 本地测试

```bash
# 启动数据库
docker-compose up -d postgres

# 启动后端
cd go-backend
../bin/panel

# 启动前端（另开终端）
cd react-frontend
npm run dev
```

访问 http://localhost:6366

默认登录：admin_user / admin_user

### 3. 远程部署到测试环境 (91.233.10.38)

#### 方法一：Docker Compose 部署（推荐）

```bash
# 将代码推送到 Git 仓库
git add .
git commit -m "更新代码"
git push

# SSH 登录到服务器
ssh root@91.233.10.38

# 在服务器上执行
cd /opt/realm-flow
git pull
docker-compose down
docker-compose up -d --build
```

#### 方法二：使用部署脚本

```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. 访问测试环境

- 前端地址：http://91.233.10.38:6366
- 后端 API：http://91.233.10.38:6365/api
- 默认登录：admin_user / admin_user

## 已知问题和解决方案

### 问题 1：Go 二进制文件在远程服务器无法运行
**原因**：远程服务器是 musl libc 系统，Go 默认编译为 glibc

**解决方案**：
```bash
# 交叉编译到 Linux
cd go-backend
GOOS=linux GOARCH=amd64 go build -o ../bin/panel ./cmd/server
```

### 问题 2：前端 API 跨域
**解决方案**：使用 nginx 反向代理（已在 docker-compose.yml 中配置）

### 问题 3：数据库连接失败
**解决方案**：确保 postgres 服务先启动，设置 depends_on 和 healthcheck

## 功能测试清单

### 基础功能
- [ ] 用户登录/登出
- [ ] 创建/编辑/删除用户
- [ ] 创建/编辑/删除节点
- [ ] 创建/编辑/删除隧道
- [ ] 创建/编辑/删除转发规则
- [ ] 启动/停止转发

### 监控功能
- [ ] 查看仪表盘统计
- [ ] 查看用户流量
- [ ] 查看节点流量
- [ ] 查看隧道流量
- [ ] 查看转发流量

### Agent 功能
- [ ] Agent 心跳上报
- [ ] Agent 流量上报
- [ ] 节点状态同步
- [ ] 规则下发

### 通知功能
- [ ] Telegram 通知配置
- [ ] 发送测试通知
- [ ] 流量告警通知
- [ ] 节点状态通知

## 技术栈

### 后端
- Go 1.21+
- Gin (Web 框架)
- GORM (ORM)
- PostgreSQL 14
- JWT (认证)

### 前端
- React 18
- TypeScript
- Vite
- Ant Design 5
- Axios

### Agent
- Go 1.21+
- nftables / realm (转发引擎)
- Telegram Bot API (通知)

## 后续优化方向

1. **性能优化**
   - 数据库查询优化
   - API 响应缓存
   - 前端代码分割

2. **功能完善**
   - 实时 WebSocket 推送
   - 更详细的日志记录
   - 审计日志

3. **安全加固**
   - HTTPS 支持
   - API 限流
   - 输入验证增强

4. **用户体验**
   - 错误提示优化
   - 加载状态优化
   - 操作确认提示

## 错误记录

### 错误 1：monitor.go 编译错误
- **错误**：h.repos.DB undefined
- **原因**：Repository 模式不允许直接访问 DB
- **解决**：添加 GetDB() 方法到所有 Repository

### 错误 2：前端构建错误
- **错误**：DownloadOutlined 未使用
- **原因**：导入了但未使用的图标
- **解决**：移除未使用的导入

### 错误 3：notify.go 导入错误
- **错误**：缺少 bytes 包导入
- **原因**：使用 bytes.NewReader 但未导入
- **解决**：添加 import "bytes"
