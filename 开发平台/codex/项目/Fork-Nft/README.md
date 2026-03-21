# Fork-Nft 项目记录

- 项目时间: 2026-03-20 10:10:49 CST
- GitHub: https://github.com/JackLuo1980/Fork-Nft
- 上游参考: https://github.com/Sagit-chu/flvx
- 目标: 保留 FLVX 面板与一键部署体验，支持可选转发引擎（nftables/realm/auto）并建立高强度测试体系。

## 已完成
1. 创建并推送开源仓库 `JackLuo1980/Fork-Nft`（public）。
2. 同步 FLVX 代码到主分支 `main`。
3. 新增开发基线文档：
   - `docs/architecture/engine-abstraction-plan.md`
   - `docs/testing/test-strategy.md`
   - `docs/deploy/one-click-roadmap.md`

## 当前基线提交
- main: `f657518`

## 下一步
1. 定义 engine adapter 接口和目录结构。
2. 先落地 nftables adapter（含 dry-run/apply/rollback）。
3. 补齐 realm adapter 与 auto selector。
4. 建立 CI 测试流水线（unit/integration/e2e/reliability smoke）。
5. 输出迁移工具与一键安装脚本增强。

## 2026-03-20 开发面板部署（调试服务器）
- 目标服务器：38.165.47.12
- 部署路径：`/opt/Fork-Nft`
- 启动方式：`docker-compose -f docker-compose-v4.yml up -d`
- 访问地址：
  - 前端面板：`http://38.165.47.12:6366`
  - 后端健康：`http://38.165.47.12:6365/flow/test`
- 容器：`vite-frontend`、`flux-panel-backend`、`flux-panel-postgres`
- 状态：全部 running/healthy

### 运维命令
```bash
cd /opt/Fork-Nft
docker-compose -f docker-compose-v4.yml ps
docker-compose -f docker-compose-v4.yml logs -f --tail=100 backend
docker-compose -f docker-compose-v4.yml restart
```

### 备注
- 默认管理员账号可登录，首次登录后需改密（后端返回 `requirePasswordChange=true`）。
- 当前为开发调试环境，后续可再接入域名+HTTPS。

## 2026-03-20 第一批代码改造（Engine Adapter Bootstrap）
- 提交: `b85388d`
- 仓库: `JackLuo1980/Fork-Nft`

### 本次新增
1. `go-gost/x/socket/forward_engine.go`
- 引入转发引擎抽象 `ForwardEngine` 与 `ForwardEngineManager`
- 增加引擎选择逻辑：请求参数优先，其次 `FORKNFT_FORWARD_ENGINE`，默认 `gost`
- 预注册 `nftables` 适配器与 `realm` 占位适配器

2. `go-gost/x/socket/forward_engine_nftables.go`
- 新增 `nftables` 适配器（DryRun / Apply）
- 支持：
  - 规则合法性校验
  - 目标域名解析为 IPv4
  - 生成 nftables 配置
  - 安全防护：规则缩减保护（allowShrink=false时阻断）
  - 失败回滚：apply 检查失败时回滚 state/nft 文件

3. `go-gost/x/socket/websocket_reporter.go`
- 新增命令 `ApplyPortForwards`
- 支持参数：`engine`、`dryRun`、`allowShrink`、`forwards[]`

4. 测试
- `go-gost/x/socket/forward_engine_test.go`
- 通过测试覆盖：
  - 引擎解析优先级
  - 防误缩减阻断
  - apply失败回滚

### 验证结果
- `cd go-gost/x && go test ./socket` 通过

## 2026-03-20 第二批代码改造（Realm + Auto）
- 提交: `69a7559`

### 本次新增
1. `realm` 适配器落地
- 文件: `go-gost/x/socket/forward_engine_realm.go`
- 能力: `DryRun/Apply`、realm配置渲染、失败回滚

2. `auto` 策略选择
- 文件: `go-gost/x/socket/forward_engine.go`
- 策略: 规则中含 `udp` -> `nftables`，否则 -> `realm`

3. 命令入口默认回退到 `auto`
- 文件: `go-gost/x/socket/websocket_reporter.go`
- 对 `ApplyPortForwards` 命令，当 engine 为空/默认值时自动走 `auto`

4. 测试
- `go-gost/x/socket/forward_engine_test.go`
- 新增测试: `TestSelectAutoEngineName`、`TestRealmAdapterApplyWritesConfig`

### 验证结果
- `cd go-gost/x && go test ./socket` 通过

## 2026-03-20 第三批代码改造（Forward Engine 全链路）
- 提交: `03934c1`

### 本次改造
1. 后端数据层接通 `forward.engine`
- `go-backend/internal/store/model/model.go`
  - `Forward` 增加 `Engine` 字段（default `gost`）
  - `ForwardBackup` / `ForwardRecord` / `UserForwardDetail` 增加 `engine`
- `go-backend/internal/store/repo/repository_mutations.go`
  - `CreateForwardTx` / `UpdateForward` / `RollbackForwardFields` 新增 `engine` 入参与持久化
- `go-backend/internal/store/repo/repository.go`
  - `ListForwards`、`GetUserPackageForwards` 返回 `engine`
  - `exportForwards/importForwards` 支持 `engine`
  - schema 版本升级到 `7`，迁移时归一化空 `engine` 为 `gost`

2. 后端接口层接通 `engine`
- `go-backend/internal/http/handler/mutations.go`
  - `forwardCreate/forwardUpdate` 支持读取 `engine`
  - 增加 `normalizeForwardEngine`（`gost/auto/nftables/realm`）
- `go-backend/internal/http/handler/handler.go`
  - 用户套餐 forwards 响应新增 `engine`

3. 前端可视化配置接通 `engine`
- `vite-frontend/src/api/types.ts`
  - `ForwardApiItem`、`ForwardMutationPayload` 增加 `engine`
- `vite-frontend/src/pages/forward.tsx`
  - Forward/ForwardForm 增加 `engine`
  - 新增表单项“转发引擎”（gost/auto/nftables/realm）
  - 新增/编辑请求携带 `engine`

### 验证结果
- `cd go-backend && go test ./...` 通过
- `cd go-gost/x && go test ./socket` 通过
- `cd vite-frontend && npm run build` 通过

### 备注
- 本批完成后，面板可以按单条转发选择引擎，并且该配置可持久化、可导入导出、可迁移归一化。

## 2026-03-20 第四批代码改造（Engine 回归测试）
- 提交: `e696d9d`

### 新增测试
1. Handler 层
- `go-backend/internal/http/handler/mutations_engine_test.go`
- 覆盖 `normalizeForwardEngine`：空值、大小写、非法值回退、四种合法值。

2. Repository 层
- `go-backend/internal/store/repo/repository_forward_engine_test.go`
- 覆盖场景：
  - `CreateForwardTx/UpdateForward/RollbackForwardFields` 的 engine 持久化与回滚
  - `ListForwards` 对空 engine 归一化为 `gost`
  - `importForwards` 对空 engine 的默认值处理
  - `migrateSchema`（ver=6->7）对空 engine 的归一化

### 验证结果
- `cd go-backend && go test ./...` 通过

## 2026-03-20 第五批代码改造（下发 payload 带 engine）
- 提交: `947ec24`

### 改造内容
- 文件: `go-backend/internal/http/handler/control_plane.go`
- 在 `buildForwardServiceConfigs` 的 `forwarder` 中新增字段 `engine`：
  - 优先使用 `forward.engine`
  - 空值默认回退 `gost`

### 新增测试
- 文件: `go-backend/internal/http/handler/control_plane_test.go`
- `TestBuildForwardServiceConfigs_IncludesForwardEngine`
- `TestBuildForwardServiceConfigs_DefaultEngineGost`

### 验证结果
- `cd go-backend && go test ./...` 通过

## 2026-03-20 第六批联调验证（开发机实测）
- 目标机: `38.165.47.12`
- 验证方式: 在开发机创建远程mock节点+隧道+转发，触发真实 `UpdateService` 下发，抓取运行时命令体。

### 关键结果
- 实际抓到的命令类型: `UpdateService`
- 抓到的 `forwarder.engine`: `['realm', 'realm']`（tcp/udp 两条服务）
- 面板 `forward/list` 返回 `engine=realm`
- 验证结论: `面板选择engine -> 后端持久化 -> 节点下发payload携带engine` 链路已贯通。

### 现场调整
- 开发机后端已临时切换为本仓库构建镜像：`fork-nft-backend:engine-e2e`
- 切换文件：`/opt/Fork-Nft/docker-compose.engine-test.yml`

## 2026-03-20 第七批交付（联调脚本固化）
- 提交: `5d548d8`

### 新增脚本
- `scripts/e2e-engine-check.sh`
- 功能:
  - 远程自动切换到 Fork 后端镜像（可选跳过构建）
  - 自动创建 mock-fed 远程节点、隧道、转发
  - 自动断言 `UpdateService` payload 中 `forwarder.engine`
  - 自动断言 `forward/list` 中 `engine` 字段
  - 自动清理测试资源，并默认恢复为基础 compose 后端镜像

### 实测
- 已在 `38.165.47.12` 执行 `--skip-build` 成功通过。
