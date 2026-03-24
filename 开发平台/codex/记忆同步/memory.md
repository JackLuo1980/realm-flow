# memory.md

- 来源: `/Users/jack/Documents/Playground/memory.md`
- 同步时间: `2026-03-24 15:56:46 CST`

---

# memory.md

- 来源: `/Users/jack/Documents/Playground/memory.md`
- 同步时间: `2026-03-19 20:38:38 CST`

---

# memory.md

## User Profile
- Preferred language: Chinese.
- Main expectation: Codex should not forget previously stated preferences and decisions.

## Stable Preferences
- Use persistent project memory files instead of relying only on conversation context.
- Keep solutions practical and directly executable.
- Keep memory records and the Obsidian codex mirror aligned in the same concise Chinese style, so the same preference can be reconstructed from either source.
- For servers in mainland China network environments, install agents via offline workflow: download binary locally, upload with `scp`, then configure/start service manually (e.g., systemd), instead of relying on one-line remote install scripts.
- Sync memory files to Obsidian (`/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/codex/记忆同步`) so prior experience can be recovered quickly after server changes.
- Keep an "after-task learning" habit: summarize repeatable lessons into `memory.md` / `decision_log.md` and sync immediately.

## Update Protocol
When user says any of the following, add/update entries in this file:
- "记住这条"
- "更新记忆"
- "把这个写进记忆"

## Recent Confirmed Decisions
- In VS Code, use the `CLAUDE CODE` tab (not the generic `聊天` tab) for this workflow.
- Model/provider path confirmed working: Claude Code + MiniMax M2.5 (China endpoint).
- Keep current MiniMax key unchanged unless user explicitly asks to rotate or switch regions.
- Komari-agent install preference confirmed: use offline deployment method for China-network servers.
- Keep Obsidian memory mirror up to date by running `/Users/jack/Documents/Playground/sync_memory_to_ob.sh` after memory updates.
- Obsidian codex base path is now `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/codex/`; new records should be saved under this path.
- When updating memory, keep the phrasing terse and operational so it can be mirrored cleanly into Obsidian without rewriting the meaning.
- Use `/Users/jack/Documents/Playground/capture_learning.sh` for standardized memory/decision capture.
- 服务器巡检默认顺序固定为：先看代理进程和对外监听端口，再对该端口做 15 秒短窗口抓包，最后结合日志判断是否存在持续入站；抓包工具缺失时先补装 `tcpdump`。
- 服务器巡检要把 SSH 端口和 Xray/代理端口分开记录；例如 191.96.11.239 的 SSH 端口是 41153，而对外 Xray 端口是 41155。
- 107.172.231.70:48356 是少数在短抓包里抓到真实活跃会话的机器，`xray` 端口 `52912` 曾出现来自 `14.145.170.36` 的连接，后续优先复查。
- 45.127.35.233:48981 的 `sing-box` 端口 `48982` 在短抓包里出现多条活跃会话，后续复查时优先看这个入口。
- 140.99.243.151:50203 的 `xray` 端口 `50204` 在短抓包里没有流量，属于空闲监听型。
- 154.7.179.43:2333 的 `xray` 端口 `25572` 在短抓包里没有流量，属于空闲监听型。
- 这批机器的管理口补查里，`87.83.*` 的 `x-ui` 端口和 `45.141.36.130:80/59745`、`23.141.52.67:24854`、`140.99.243.151:10085`、`191.96.11.239:41154`、`202.73.4.182:41001` 都没有抓到持续入站。
- 长抓包结论：`45.127.35.233:48982` 与 `202.73.4.182:41003` 持续有会话，`107.172.231.70:52912` 则不是持续高频流量但曾确认真实活跃会话。
- 45.127.35.233 与 202.73.4.182 的活跃流量更像正常代理使用：前者日志里目标是 Google / Apple / gstatic，后者会话源始终是 14.145.170.36，且都没有 banned 记录。
- 国际互联测速时同时看 ping/HTTPS 时延/多地区100MB下载；并记录 remote_ip 判断是否走 IPv6，避免单一指标误判。
- Komari 面板实际服务器信息已更正：主机 IP 为 159.54.184.3；登录密码为 lpsz800203（按用户最新提供记录）。
- Komari 出现‘删除提示成功但实际未删除’时，先查磁盘空间；若根分区100%会导致写库异常。此次根因是 /root/komari_sort_by_name.sh 每10分钟备份数据库到 /home/docker/komari/sort_backups，最终打满磁盘。
- next-ai-draw-io后续统一按Docker+本机3000+Caddy域名反代的基线部署；验收口径固定为HTTPS可达(最终200)+容器running+Caddy active+证书签发成功日志。
- 银行类AI治理/贯标项目默认采用：知识库先行、规则约束、模型增强、人机协同、私有化部署、信创兼容；一期优先做推荐/判重/纠错，暂不引入血缘数据库，向量能力按最小必要原则落地。
- 银行智能贯标/数据字典类项目在正式方案阶段应默认补齐：系统架构图、模块架构图、关键接口清单、知识库核心表设计与索引建议，以满足甲方架构评审和交付拆分需要。
- 正式项目文档默认存放在Obsidian中，Obsidian作为所有文档的主存储位置；工作区文件可作为中间编辑区，但最终文档必须同步/保存到Obsidian。
- 银行类AI方案若客户明确要求沿用现有系统入口，默认优先设计为内嵌式增强方案，复用现有登录、菜单、权限与页面框架，避免先按独立平台立项与呈现。
- Codex 当前保留的 MCP 基线为 `filesystem-playground`、`playwright`、`memory`、`obsidian`；`github`、`exa-search`、`perplexity`、`todoist` 默认移除，除非用户再次明确需要。
- FLVX/Fork-Nft 面板调试服务器：`38.165.47.12`，root 密码 `dmgbZVKT8786`（用户已授权保存，后续会话可直接使用）。
- PO0 中转服务器：`111.229.215.107`，root 密码 `8MbOviffmS3s`（用户已授权保存，后续会话可直接使用）。
- Fork-Nft 面板当前登录账号已更新为：用户名 `jack`，密码 `lpsz800203`（用户 2026-03-20 最新提供）。
- Fork-Nft 2026-03-20 联调结论：`/etc/relay-forwards.conf` 字段顺序为 `name|host|target_port|relay_port`；若同步脚本按 `in_port|target_port` 解析会导致端口错位（诊断失败、面板映射错误）。
- Fork-Nft 2026-03-20 线上修复结论：PO0 同步后应保持 `JP-CO 31000->198.176.52.9:55894`、`HK-Jinx 31001->172.81.111.70:13608`、`Boil HKT 12071->hktnat.jung.eu.org:23202`。
- nft-only 场景流量统计基线：开启 nft `counter` 并部署 `nft-flow-exporter`（10s 定时上报 `/flow/upload`）后，面板 `forward.inFlow` 可持续增长。
- Uzumaru Bot 当前最终展示基线：/nm 顶部同一行显示当前节点与总数（当前含国旗，总数数字加粗），文本为『📍 当前：*{cur}*                  📊 共 *{total}* 个节点』；Telegram 不支持单独字体颜色与字号放大。
- Cloudflare DDNS 若出现‘域名与IP不符’，先核对：root crontab/systemd是否在跑；再对比 Cloudflare API 记录与权威 NS（两个 NS）返回，避免只看单个解析器误判。
- 当域名SSH失败且日志显示连接到198.18.x.x时，优先判断本地代理Fake-IP污染；可在~/.ssh/config为该域名固定HostName真实IP与Port，绕过本地DNS改写。
- Cloudflare DDNS 出现同一记录反复跳IP时，先查 user/audit_logs 按 resource.id 看 actor.ip；若不同IP交替写入即为多客户端抢写。
- 38.207.191.187:5522 的 `xray` 对外端口是 `44312`，`x-ui` 监听 `2096/51685`，`tcpdump` 已可用，15 秒短抓包未见持续入站。
- 109.107.137.44 全端口 TCP 扫描未扫到任何开放端口，暂时无法继续按 SSH -> 代理端口 -> 短抓包的流程巡检。
- 45.129.9.96 全端口 TCP 扫描未扫到任何开放端口，暂时无法继续按 SSH -> 代理端口 -> 短抓包的流程巡检。
- 45.129.9.96 实际可从 `22` 登录；`xray` 对外端口是 `14060`，`x-ui` 监听 `2096/46949`，安装 `tcpdump` 后对这两个口短抓包未见持续入站。

