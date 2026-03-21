# memory.md

- 来源: `/Users/jack/Documents/Playground/memory.md`
- 同步时间: `2026-03-20 13:17:57 CST`

---

# memory.md

## User Profile
- Preferred language: Chinese.
- Main expectation: Codex should not forget previously stated preferences and decisions.

## Stable Preferences
- Use persistent project memory files instead of relying only on conversation context.
- Keep solutions practical and directly executable.
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
- Use `/Users/jack/Documents/Playground/capture_learning.sh` for standardized memory/decision capture.
- 国际互联测速时同时看 ping/HTTPS 时延/多地区100MB下载；并记录 remote_ip 判断是否走 IPv6，避免单一指标误判。
- Komari 面板实际服务器信息已更正：主机 IP 为 159.54.184.3；登录密码为 lpsz800203（按用户最新提供记录）。
- Komari 出现‘删除提示成功但实际未删除’时，先查磁盘空间；若根分区100%会导致写库异常。此次根因是 /root/komari_sort_by_name.sh 每10分钟备份数据库到 /home/docker/komari/sort_backups，最终打满磁盘。
- next-ai-draw-io后续统一按Docker+本机3000+Caddy域名反代的基线部署；验收口径固定为HTTPS可达(最终200)+容器running+Caddy active+证书签发成功日志。
- 银行类AI治理/贯标项目默认采用：知识库先行、规则约束、模型增强、人机协同、私有化部署、信创兼容；一期优先做推荐/判重/纠错，暂不引入血缘数据库，向量能力按最小必要原则落地。
- 银行智能贯标/数据字典类项目在正式方案阶段应默认补齐：系统架构图、模块架构图、关键接口清单、知识库核心表设计与索引建议，以满足甲方架构评审和交付拆分需要。
- 正式项目文档默认存放在Obsidian中，Obsidian作为所有文档的主存储位置；工作区文件可作为中间编辑区，但最终文档必须同步/保存到Obsidian。
- 银行类AI方案若客户明确要求沿用现有系统入口，默认优先设计为内嵌式增强方案，复用现有登录、菜单、权限与页面框架，避免先按独立平台立项与呈现。
- Codex 当前保留的 MCP 基线为 `filesystem-playground`、`playwright`、`memory`、`obsidian`；`github`、`exa-search`、`perplexity`、`todoist` 默认移除，除非用户再次明确需要。
- PO0中转排障默认目标服务器：111.229.215.107；root密码：8MbOviffmS3s（用户已授权持久记录，后续同类操作默认直接使用）。
- Fork-Nft 面板开发调试服务器：38.165.47.12；root密码：dmgbZVKT8786（用户已授权记录，后续默认作为开发调试部署目标）。

