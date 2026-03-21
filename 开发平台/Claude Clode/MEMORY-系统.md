# Claude Code 记忆索引

> 最后更新: 2026-03-19
> 来源: 从 Obsidian Claude Clode 记忆迁移

## 用户偏好

### 通信风格
- **语言**: 中文
- **风格**: 简洁直接，不说废话
- **Emoji**: 避免使用（除非明确要求）
- **代码引用格式**: `[filename.ts](path/to/file.ts#L42)`

### 工作流程
1. **复杂任务使用计划模式**: 多种实现方案时使用 EnterPlanMode
2. **使用 TodoWrite 跟踪进度**: 多步骤任务使用 todo list
3. **优先使用专用工具**: Read/Grep/Edit 而非 bash
4. **避免过度工程**: 只做必要改动

### 技术环境
- **Shell**: zsh
- **平台**: macOS (Darwin 25.3.0)
- **工作目录**: /Users/jack
- **API**: MiniMax M2.5
- **API 基础 URL**: https://api.minimaxi.com/anthropic

## 重要路径

- **Obsidian Vault**: `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/`
- **开发平台**: `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/`
  - `Claude Clode/` - Claude Code 工作内容
  - `codex/` - Codex 工作内容
  - `智谱/` - 智谱工作内容
- **新记忆系统**: `/Users/jack/.claude/projects/-Users-jack/memory/`

## 服务器清单

详细服务器信息见: `servers.md`

| 服务器 | 用途 | 状态 |
|--------|------|------|
| leikwan.zlib4.eu.org | 主中转 + 策略路由 | 活跃 |
| 111.229.215.107 | 备用中转 | 活跃 |
| 159.54.184.3 | Komari 监控 | 活跃 |

## 工作约定

### 记忆同步
- **所有开发内容和工作内容必须同步保存到 Obsidian**
- 每次完成重要任务后，同步记忆到 Obsidian
- 触发关键词: "记住这条", "更新记忆", "把这个写进记忆"

### Obsidian 工作内容存储
- 工作内容保存在: `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/`
- 使用合适的文件夹结构组织工作内容
- 代码变更、决策、问题解决都应记录

### 安全考虑
- 不主动执行 git push
- 不修改 git config
- destructive 操作前确认

### 中国大陆服务器部署
- 使用离线部署方式（本地下载 → scp 上传 → 手动配置）
- 避免依赖 GitHub 等外部源的超时问题

## 主题文件

- `servers.md` - 服务器详细配置和维护命令
