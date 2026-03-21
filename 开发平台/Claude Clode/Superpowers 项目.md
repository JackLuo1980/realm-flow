# Superpowers 项目

> 项目记忆创建时间: 2026-03-20
> 来源: Claude Code 记忆系统

## 项目概述

**Superpowers** 是一个 AI 编程代理的工作流增强系统，提供了一套可组合的"技能"(skills)来指导 AI 代理按照最佳实践进行软件开发。

### 基本信息

| 项目 | 内容 |
|------|------|
| **上游仓库** | https://github.com/obra/superpowers |
| **你的 Fork** | https://github.com/JackLuo1980/superpowers |
| **版本** | 5.0.4 |
| **作者** | Jesse Vincent (@obra) - Prime Radiant |
| **许可证** | MIT |
| **本地路径** | `~/.codex/superpowers/` |
| **当前分支** | `dev` |
| **支持平台** | Claude Code, Cursor, Codex, OpenCode, Gemini CLI |

## 核心工作流

```
brainstorming → using-git-worktrees → writing-plans →
executing-plans/subagent-driven-development →
test-driven-development → code-review →
finishing-a-development-branch
```

### 工作流详解

1. **brainstorming** - 构思阶段，通过问题细化想法，探索替代方案
2. **using-git-worktrees** - 创建隔离的 git worktree 工作区
3. **writing-plans** - 编写详细的实现计划（2-5分钟/任务）
4. **executing-plans** - 批量执行计划，带人工检查点
5. **test-driven-development** - 红绿重构 TDD 循环
6. **requesting-code-review** - 代码审查
7. **finishing-a-development-branch** - 合并/PR 决策

## 技能库结构

```
~/.codex/superpowers/
├── skills/
│   ├── systematic-debugging/      # 系统化调试
│   ├── verification-before-completion/  # 完成前验证
│   ├── brainstorming/             # 构思
│   ├── writing-plans/             # 编写计划
│   ├── executing-plans/           # 执行计划
│   ├── dispatching-parallel-agents/  # 并行代理
│   ├── requesting-code-review/    # 请求代码审查
│   ├── receiving-code-review/     # 接收代码审查
│   ├── using-git-worktrees/       # Git Worktree
│   ├── finishing-a-development-branch/  # 完成开发分支
│   ├── subagent-driven-development/  # 子代理驱动开发
│   ├── test-driven-development/   # TDD
│   └── writing-skills/            # 编写技能
├── agents/
├── commands/
├── hooks/
├── tests/
└── docs/
```

## 设计哲学

- **Test-Driven Development** - 先写测试
- **Systematic over ad-hoc** - 流程胜过猜测
- **Complexity reduction** - 简单是首要目标
- **Evidence over claims** - 声称成功前先验证

## 相关链接

- Discord: https://discord.gg/Jd8Vphy9jq
- Issues: https://github.com/obra/superpowers/issues
- Marketplace: https://github.com/obra/superpowers-marketplace
- 博客: https://blog.fsck.com/2025/10/09/superpowers/

---

## 工作日志

### 2026-03-20
- 创建项目记忆
- 学习项目结构和核心工作流
- Fork 项目到 https://github.com/JackLuo1980/superpowers
- 设置开发环境：添加 fork 远程仓库，创建 dev 分支
- 准备开始 bug 修复和开发工作

## Git 工作流

```bash
# 远程仓库配置
origin  -> https://github.com/obra/superpowers.git (上游)
fork    -> https://github.com/JackLuo1980/superpowers.git (你的 fork)

# 推送到你的 fork
git push fork dev

# 从上游同步更新
git fetch origin
git merge origin/main
```
