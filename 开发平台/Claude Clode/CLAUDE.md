# Claude Code 使用指南

> 本文件记录 Jack 的 Claude Code 使用偏好和习惯

## 通信风格

- 简洁直接，不说废话
- 使用中文交流
- 避免使用 emoji（除非用户明确要求）
- 代码引用使用 markdown 链接格式: `[filename.ts](path/to/file.ts#L42)`

## 工作流程偏好

1. **复杂任务使用计划模式**: 当任务复杂或有多种实现方案时，使用 EnterPlanMode
2. **使用 TodoWrite 跟踪进度**: 多步骤任务使用 todo list 管理
3. **优先使用专用工具**: 读取用 Read，搜索用 Grep，编辑用 Edit
4. **避免过度工程**: 只做必要的改动，不添加多余功能

## 文件同步

- 每次完成重要任务后，同步记忆到 Obsidian
- 路径: `/Users/jack/Library/Mobile Documents/iCloud~md~obsidian/Documents/Jack Luo/开发平台/Claude Clode/`

## 文件夹结构

```
Claude Clode/
├── 01_项目记忆/     # 项目特定信息
├── 02_用户偏好/     # 用户偏好记录
├── 03_学习积累/     # 学习的知识
├── 04_调试记录/     # 问题解决记录
├── MEMORY.md       # 索引
└── CLAUDE.md       # 本指南
```

## 已知环境

- **API**: MiniMax M2.5 模型
- **API 基础 URL**: https://api.minimaxi.com/anthropic
- **认证方式**: ANTHROPIC_AUTH_TOKEN
- **超时**: 3000000ms

## 安全考虑

- 不主动执行 git push
- 不修改 git config
-  destructive 操作前确认
