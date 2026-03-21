# decision_log.md

- 来源: `/Users/jack/Documents/Playground/decision_log.md`
- 同步时间: `2026-03-21 16:13:27 CST`

---

# decision_log.md

- 来源: `/Users/jack/Documents/Playground/decision_log.md`
- 同步时间: `2026-03-19 20:38:38 CST`

---

# decision_log.md

## 2026-03-16 - Initialize External Memory System
- Background: User reported concern that Codex may forget earlier statements.
- Decision: Use four persistent files (`AGENTS.md`, `memory.md`, `project_context.md`, `decision_log.md`) as memory backbone.
- Why: File-based context is stable across sessions and easier to maintain than chat-only memory.
- Follow-up: In every new session, load these files first.

## 2026-03-16 - China-Network Agent Installation Strategy
- Background: One-line remote install script for komari-agent timed out on GitHub-related sources in a mainland China network environment.
- Decision: For similar domestic network servers, default to offline deployment: download binary locally, upload to server (`scp`), and create/start service manually (systemd/OpenRC as applicable).
- Why: Avoids external source reachability bottlenecks and improves installation success rate.
- Follow-up: Reuse this method as the first-choice approach for future domestic deployments.

## 2026-03-17 - Mirror Memory Files to Obsidian
- Background: User requested syncing memory to Obsidian so historical experience remains available after server migration/replacement.
- Decision: Maintain an Obsidian mirror for `AGENTS.md`, `memory.md`, `project_context.md`, and `decision_log.md` at `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/codex/记忆同步`.
- Why: Obsidian (iCloud) copy is easier to retrieve across environments and reduces memory loss risk when changing servers.
- Follow-up: Run `/Users/jack/Documents/Playground/sync_memory_to_ob.sh` after memory-related updates. (Superseded path: see 2026-03-17 "Move Obsidian Codex Base Path".)

## 2026-03-17 - Move Obsidian Codex Base Path
- Background: User requested changing Obsidian codex path from `/Jack Luo/codex/` to `/Jack Luo/开发平台/codex/`, and storing all future information in the new path.
- Decision: Use `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/codex/` as the canonical codex base path going forward.
- Why: Keep records centralized under the new Obsidian structure and avoid split history across old/new folders.
- Follow-up: Keep `sync_memory_to_ob.sh` and all future path references aligned to the new location.

## 2026-03-17 - Standardize Learning Capture Workflow
- Background: User wants Codex to retain and learn from prior operational experience more reliably.
- Decision: Standardize post-task learning capture by updating `memory.md` / `decision_log.md` and using `/Users/jack/Documents/Playground/capture_learning.sh` for one-command write-and-sync.
- Why: Reduces memory loss risk across sessions and lowers friction for continuously accumulating reusable lessons.
- Follow-up: After substantial tasks, run `capture_learning.sh` (or equivalent manual update) and keep Obsidian mirror synced.

## 2026-03-17 - Server International Interconnect Test Baseline
- Background: Needed a repeatable way to assess overseas connectivity quality of a server behind custom SSH port.
- Decision: Use a 3-step baseline: (1) ping loss/latency to 1.1.1.1/8.8.8.8 and major domains; (2) HTTPS connect+TLS+TTFB timings to Google/GitHub/Cloudflare/OpenAI; (3) multi-region 100MB download throughput from at least EU/US/AP endpoints.
- Why: Combining reachability, latency, and sustained throughput avoids false positives from single-metric checks.
- Follow-up: Reuse this baseline for future server quality checks and keep endpoint list refreshed if specific mirrors fail.

## 2026-03-17 - Correct Komari Panel Server Target
- Background: Troubleshooting initially used 111.229.215.107 (agent host), but user confirmed the actual panel server is different.
- Decision: For Komari admin issues (e.g., deletion anomalies), use 159.54.184.3 as the primary backend target; credential recorded from user: lpsz800203.
- Why: Avoids diagnosing the wrong machine and reduces turnaround time.
- Follow-up: Use the corrected server first in future Komari backend checks and keep this mapping in memory.

## 2026-03-17 - Fix Komari Fake-Delete Due to Full Disk
- Background: User reported delete success toast but node remained after previous sorting setup.
- Decision: Freed disk by removing massive sort backup files, manually deleted stuck client record, and disabled cron job */10 /root/komari_sort_by_name.sh.
- Why: Full root filesystem (100%) prevented reliable DB writes; repeated DB backups were the direct cause.
- Follow-up: Keep disk usage monitored and avoid high-frequency full DB backup jobs on production Komari DB.

## 2026-03-18 - Komari egress受限中转策略
- Background: 目标机可SSH但无法稳定直连外网443，agent安装后连接面板超时/断链。
- Decision: 采用RFC JP CO双层中转：先中转下载agent二进制，再在RFC上部署SNI TCP forward(systemd)并在目标机用nftables OUTPUT DNAT把tcp/443导向RFC转发端口。
- Why: agent运行期会访问多个443目标，单域名映射不够；SNI转发能按TLS主机名动态出站，稳定建立WebSocket。
- Follow-up: 新机器复用时优先检查日志是否出现Basic info uploaded successfully与WebSocket connected，并保留中转服务开机自启。

## 2026-03-18 - Komari 出站受限中转标准方案
- Background: 目标机可SSH但无法稳定访问外网，直接安装脚本会卡在GitHub下载，agent运行期也会因443受限导致面板连接不稳。
- Decision: 标准流程：1) 在RFC JP CO下载komari-agent二进制并中转到目标机安装；2) RFC上部署SNI TCP forward并做systemd常驻（/opt/sni_forward.py, 24445端口）；3) 目标机用nftables OUTPUT DNAT将tcp/443重定向到RFC:24445；4) agent使用-e/-t/--disable-web-ssh并建议加--disable-auto-update。
- Why: 单纯文件中转只能解决安装，不能解决运行期WebSocket；agent会访问多个443目标，SNI转发可动态按TLS主机名出站，稳定恢复Basic info上传和WebSocket连接。
- Follow-up: 后续同类机器先套此方案；验收以journalctl出现“Basic info uploaded successfully”和“WebSocket connected”为准；若面板IP异常则补--custom-ipv4。

## 2026-03-18 - Claude双角色插件基线
- Background: 用户同时承担开发与产品工作，需要低干扰高收益的插件组合
- Decision: 默认安装 superpowers、code-review、context7、claude-mem，并保留 pm-skills 三件套
- Why: 兼顾编码质量、文档时效、长期记忆与PM流程支持，避免一次性装过多插件
- Follow-up: 后续按真实使用频率再增补 pr-review-toolkit 或 everything-claude-code

## 2026-03-18 - Claude Code 智谱接入排障基线
- Background: 用户在Claude Code中出现Auth conflict与401/400报错，接入目标为Z.AI端点
- Decision: 先执行 claude auth logout 清理/login托管key；修复~/.claude/settings.json中重复拼接的ANTHROPIC_AUTH_TOKEN；再设置ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic 与 ANTHROPIC_MODEL=glm-4.7（并保留DEFAULT_*映射）
- Why: Auth conflict通常来自登录态+token并存；Unknown Model通常来自历史模型名（如MiniMax-M2.5）与当前端点不兼容
- Follow-up: 后续遇到同类问题优先按“auth冲突 -> token格式 -> 模型映射”三步检查，并重启Claude Code窗口生效。

## 2026-03-18 - VS Code Claude插件配置优先级
- Background: 用户在CLI已修复后，VS Code Claude插件仍报Unknown Model 1211
- Decision: 将~/Library/Application Support/Code/User/settings.json中的claudeCode.selectedModel与claudeCode.environmentVariables统一改为Z.AI配置（glm-4.7 + https://api.z.ai/api/anthropic + 当前token）
- Why: VS Code插件会优先使用其自身settings.json中的claudeCode配置，可能覆盖~/.claude/settings.json
- Follow-up: 后续同类问题先检查VS Code设置项claudeCode.selectedModel与claudeCode.environmentVariables

## 2026-03-18 - Komari域名Fake-IP与认证口令校验
- Background: 用户提供 leikwan.zlib4.eu.org:22 + 大写密码，连接前即被198.18.*断开且认证失败。
- Decision: 先验证DNS是否fake-ip；若域名无真实A记录则改用已确认公网IP(159.54.184.3)直连，并校验口令大小写后再执行离线安装。
- Why: 可避免在假IP和错误口令上反复重试，显著缩短排障时间。
- Follow-up: 后续遇到zlib4域名优先做dig+握手检查；安装完成以日志出现Basic info uploaded successfully与WebSocket connected为验收。

## 2026-03-18 - Komari重装后快速验收标准（RFC机）
- Background: 在172.81.111.70上按一键脚本重装komari-agent并更换-e/-t参数，需要快速确认是否真正上线。
- Decision: 安装后统一用journalctl按时间窗口检查三条日志：Get IPV4 Success、Basic info uploaded successfully、WebSocket connected。
- Why: 仅看systemctl active不足以证明面板可用，三条日志可直接确认注册与长连都正常。
- Follow-up: 后续同类安装都按该三条日志验收，再决定是否需要额外中转改造。

## 2026-03-18 - 节点表仅筛选服务器资料
- Background: 用户要求筛选服务器资料并更新节点管理表/动态表，原规则会扫描整个Vault
- Decision: 将静态导出与动态Dataview统一改为仅扫描个人资料/服务器资料，并用export_nodes.py重导出节点管理表
- Why: 统一数据口径，避免非服务器笔记混入节点统计
- Follow-up: 后续节点表刷新默认沿用该目录范围；如需全库扫描再显式切回

## 2026-03-18 - 节点管理表同步MiSub增删策略
- Background: 用户需要把节点管理表定期同步到MiSub，并要求新增创建、删除同步删除、已有保持不变
- Decision: 新增sync_misub_nodes.py与run_misub_sync.sh：读取节点管理导出CSV，登录/api/login后读/api/data并写/api/misubs；仅删除历史由脚本创建的节点
- Why: 避免误删MiSub中手工维护的数据，同时满足节点表到MiSub的增量同步
- Follow-up: 后续每次整理节点后运行run_misub_sync.sh；首次建议先--dry-run确认统计

## 2026-03-18 - MiSub API同步需浏览器UA
- Background: 使用Python脚本访问nodemisub.pages.dev时登录接口返回Cloudflare 1010 browser_signature_banned
- Decision: sync_misub_nodes.py 请求默认携带浏览器风格User-Agent并支持--user-agent覆盖
- Why: 避免Python-urllib默认UA被WAF拦截，保证自动同步可执行
- Follow-up: 后续若再次出现1010，优先检查站点WAF规则与脚本UA

## 2026-03-19 - 节点同步前连通性筛选
- Background: 用户希望节点管理表先测速/连通检测，仅把通的节点同步到MiSub，并在Ob保留最后一次测试结果
- Decision: 升级sync_misub_nodes.py为默认先做TCP连通测试并写节点测试结果.md/csv（含是否同步列），仅同步连通节点；run_misub_sync.sh新增测试参数
- Why: 把不通节点自动挡在同步前，且结果可追溯并保持单次最新快照
- Follow-up: 后续若需全量不筛选同步可用--skip-test；常规保持默认测试模式

## 2026-03-19 - Next-AI-Draw-IO Docker+Caddy 部署基线
- Background: 用户要求在 Debian 服务器通过域名提供 next-ai-draw-io 服务并使用 Caddy 反代
- Decision: 采用官方 ghcr 镜像运行在 127.0.0.1:3000，Caddy 负责 draw.lottery.eu.org 的自动 HTTPS 与反向代理
- Why: 避免本地编译耗时，缩短上线时间；由 Caddy 自动签发/续期证书
- Follow-up: 后续同类部署先核对域名解析到服务器公网 IP，再用 journalctl -u caddy 确认证书签发日志

## 2026-03-19 - Next-AI-Draw-IO 标准部署流程（Docker + Caddy）
- Background: 用户要求把本次 draw.lottery.eu.org 的实战部署沉淀为后续统一参考
- Decision: 标准流程固定为：1) 先核对域名A记录指向目标公网IP；2) 服务器用Docker拉取 ghcr.io/dayuanjiang/next-ai-draw-io:latest；3) 容器仅绑定127.0.0.1:3000并设置--restart unless-stopped；4) 用Caddy配置域名反代127.0.0.1:3000并启用自动HTTPS；5) 验收用curl看HTTP->HTTPS跳转与HTTPS最终200、并查journalctl -u caddy证书签发日志
- Why: 该流程无需本地编译、上线快、回滚简单，且TLS证书由Caddy自动签发续期，适合后续同类快速交付
- Follow-up: 后续所有同类搭建默认先按此流程执行；若用户提供OPENAI_API_KEY则写入/opt/next-ai-draw-io/.env后重启容器完成AI能力开通

## 2026-03-19 - Caddy反代先校验权威DNS
- Background: 配置pdf.lottery.eu.org反代时，HTTPS握手失败且证书未就绪。
- Decision: 部署前先用公共DNS(如8.8.8.8)确认域名A记录直指服务器公网IP；若返回198.18.*等fake-ip，先修正DNS再验证Caddy自动证书。
- Why: Caddy自动HTTPS依赖公网可达与正确解析，fake-ip会导致ACME验证失败并出现443握手异常。
- Follow-up: 后续同类部署先做dig权威解析+80/443连通验证，再进入服务配置步骤。

## 2026-03-19 - Caddy验收以外部HTTP/HTTPS实测为准
- Background: 本地dig受代理DNS劫持返回198.18.*，但权威DNS已正确，容易误判部署失败。
- Decision: Caddy反代部署后优先用公网curl验证：HTTP应308到HTTPS，HTTPS应200且响应头包含Via: 1.1 Caddy，再结合后端响应头确认已反代到目标端口。
- Why: 直接以真实访问链路验收可绕过本地DNS污染导致的假阴性。
- Follow-up: 后续域名部署默认执行这组验收；若本地DNS异常，改查dns.google或权威NS。

## 2026-03-19 - next-ai-draw-io 记录归档与API嵌入基线
- Background: 用户要求在Obsidian建立next-ai-draw-io项目档案，并评估是否可嵌入其他开发系统调用
- Decision: 在Obsidian codex路径创建next-ai-draw-io文件夹并建立README/API评估文档；集成上以 /api/chat 为核心流式接口，配合 /api/verify-access-code 做鉴权，建议外层再封装稳定BFF接口
- Why: 可将部署、运维、接口结论集中归档；同时降低业务系统对项目内部API协议变更的耦合风险
- Follow-up: 后续同类项目默认先在Ob建立项目档案，再输出API可用路由、鉴权方案与BFF封装建议

## 2026-03-19 - PO0中转脚本增量化基线
- Background: 原始setup-relay.sh每次执行都会覆盖/etc/nftables.conf并flush ruleset，新增落地时必须重录全部旧线路，运维风险高。
- Decision: 改为状态文件驱动的增量脚本：以/etc/relay-forwards.conf保存线路，新增/删除时只改状态文件，再重生成nftables配置；默认提供add/list/delete/apply/init子命令。
- Why: 把新增落地从整表重录变成单条追加，降低误删旧转发和端口变更风险，同时保留统一生成的规则结构。
- Follow-up: 后续同类中转机优先使用setup-relay-incremental.sh；首次迁移时先把现有线路整理进状态文件，再用apply接管。

## 2026-03-19 - PO0中转脚本支持动态域名落地
- Background: 用户的落地地址使用DDNS域名，原增量脚本只接受IPv4，导致add时报invalid IP。
- Decision: 将状态文件中的目标地址改为保存原始IP或域名；add时允许域名输入并先做解析校验，apply/generate_nftables时再把域名解析为当前IPv4写入nftables。
- Why: nftables规则本身必须使用IP，按apply时解析可兼容DDNS场景，同时保留状态文件中的域名便于后续刷新到新IP。
- Follow-up: 后续遇到动态域名落地时直接使用该版本；当DDNS变更后执行setup-relay-incremental.sh apply即可刷新规则。

## 2026-03-19 - Codex MCP 保留精简基线
- Background: 用户要求恢复之前的 MCP 后，又明确表示 `github`、`exa-search`、`perplexity`、`todoist` 当前用不到，需要移除。
- Decision: Codex 默认仅保留 `filesystem-playground`、`playwright`、`memory`、`obsidian` 四个 MCP；其余四个服务从 `~/.codex/config.toml` 中删除并卸载对应全局包。
- Why: 保持当前环境精简，减少无效配置、占位 API Key 和不必要的 MCP 加载。
- Follow-up: 后续若用户再次需要外部搜索、任务管理或 GitHub 集成，再按需单独恢复对应 MCP。


## 2026-03-20 - Fork-Nft 转发引擎字段全链路接通
- Background: 需要让面板可选择 gost/auto/nftables/realm 并在后端稳定持久化，避免仅运行时生效。
- Decision: 在 forward 模型新增 engine 并打通 create/update/list/export/import/migration，同时前端新增引擎选择并随请求提交。
- Why: 保证引擎策略可配置、可回放、可迁移，降低升级和导入导出时的配置丢失风险。
- Follow-up: 后续批次优先补充 e2e：创建/编辑 engine 后校验节点侧 ApplyPortForwards 实际执行路径。

## 2026-03-20 - Fork-Nft 引擎改造必须配套四类回归测试
- Background: 在 engine 字段打通后，需要防止后续变更导致创建/更新/导入/迁移链路回退。
- Decision: 固定增加四类测试：handler参数归一化、repo增改回滚、列表归一化、迁移归一化。
- Why: 覆盖最容易在重构时被破坏的关键路径，避免线上因默认值或历史数据触发中断。
- Follow-up: 后续每次新增转发引擎能力时，先补对应回归用例再合并。

## 2026-03-20 - Forward 下发配置应显式携带 engine
- Background: 仅在数据库保存 engine 不足以保证节点端按预期执行不同引擎。
- Decision: 在 UpdateService/AddService 构造的 forwarder payload 中显式增加 engine，并对空值回退 gost。
- Why: 让控制面与执行面配置一致，减少节点侧推断导致的不确定行为。
- Follow-up: 后续若引擎参数扩展，统一从 forwarder payload 透传并补对应回归测试。

## 2026-03-20 - PO0 转发同步到面板并锁定 nftables
- Background: 用户要求将 PO0 现有 `/etc/relay-forwards.conf` 三条转发同步到 Fork-Nft 面板，且明确禁止使用 gost。
- Decision: 新增 `scripts/sync-po0-forwards-to-panel.sh` 与 `tests/scripts/test_sync_po0_forwards.sh`，同步时强制 `engine=nftables`；若面板后端不支持 engine 持久化则视为失败并先切换到 Fork 后端镜像。
- Why: 避免“看似同步成功但运行时回退到 gost”的隐性风险，保证协议策略与用户要求一致。
- Follow-up: 后续新增/删除 PO0 转发后，直接重跑同步脚本；在面板侧持续复用 `node=PO0-111.229.215.107`、`tunnel=PO0-NFT-SYNC`。

## 2026-03-20 - PO0 节点离线导致隧道创建失败的修复基线
- Background: 面板创建 PO0 隧道时报“部分节点不在线”；PO0 对 GitHub 下载超时，在线安装 agent 卡死。
- Decision: 采用离线安装：本地下载 `gost-amd64` 二进制并上传 PO0，手工写入 `/etc/flux_agent/config.json`、systemd 服务后启动；并在面板配置 `ip=38.165.47.12:6365` 以支持 `node/install` 流程。
- Why: 离线安装不依赖 PO0 访问 GitHub，能够稳定恢复节点在线状态并解除隧道创建阻塞。
- Follow-up: 同类受限网络机器默认优先离线安装 agent，再执行转发同步。

## 2026-03-20 - Fork-Nft 引擎联调需使用同网络 mock 远程节点
- Background: 直接用宿主机127.0.0.1做remoteUrl会在容器内回环，导致联调误判失败。
- Decision: 联调时在gost-network内启动mock-fed容器，并将remoteUrl设为http://mock-fed:18080，再抓取/api/v1/federation/runtime/command payload。
- Why: 保证请求路径与生产一致，可直接验证UpdateService下发体中的forwarder.engine。
- Follow-up: 后续联调统一复用该模式，并优先确认开发机后端镜像已切到Fork构建版本。

## 2026-03-20 - Fork-Nft 引擎联调脚本应默认自动回滚环境
- Background: 联调验证需要临时切换后端镜像和创建测试资源，手动回滚容易漏步骤。
- Decision: 新增 scripts/e2e-engine-check.sh，默认自动清理资源并恢复基础compose后端，仅在显式参数下保留测试镜像。
- Why: 减少联调后环境污染，保证同一开发机可重复验收。
- Follow-up: 后续所有引擎联调优先用该脚本，避免手工执行长命令。

## 2026-03-20 - Fork-Nft 三类线上问题修复基线（用户名、端口映射、nft流量统计）
- Background: 用户反馈用户名改为 `jack` 后界面仍显示 `admin_user`，PO0 转发诊断失败，且实际有流量但面板显示 0。
- Decision:
  1) 后端用户名更新链路统一同步 `forward.user_name`（`UpdateUserNameAndPassword/UpdateUserWithPassword/UpdateUserWithoutPassword`）。
  2) 修复 `sync-po0-forwards-to-panel.sh` 的状态文件端口解析，按 `name|host|target_port|relay_port` 映射为 `inPort=relay_port, remoteAddr=host:target_port`。
  3) nft-only 模式补齐流量可见性：nft 规则启用 `counter`，并部署 `nft-flow-exporter` 定时上报 `/flow/upload`。
- Why: 这三项共同解决了“显示身份错误 + 路径诊断误报 + nft模式统计缺失”的线上核心痛点，并减少后续迁移遗漏风险。
- Follow-up:
  - 每次同步后先跑 `tests/scripts/test_sync_po0_forwards.sh`；
  - 验证转发映射与诊断成功；
  - 确认 `nft-flow-exporter.timer` active 且 `forward.inFlow/outFlow` 有增量。

## 2026-03-21 - 统一本地记忆与 Obsidian 镜像记录风格
- Background: User wants Codex memory and the Obsidian codex path to feel like one continuous record, not two separate note styles.
- Decision: Keep `memory.md` and `decision_log.md` in the same concise Chinese operational style, and mirror the same content into `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/codex/记忆同步`.
- Why: Unified wording makes preferences easier to reconstruct after session resets or environment changes, and reduces drift between local and Obsidian copies.
- Follow-up: After future memory updates, run the sync script immediately and preserve the same terse, actionable phrasing in both places.

