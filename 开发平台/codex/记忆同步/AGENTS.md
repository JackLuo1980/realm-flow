# AGENTS.md

- 来源: `/Users/jack/Documents/Playground/AGENTS.md`
- 同步时间: `2026-03-21 16:13:27 CST`

---

# AGENTS.md

## Purpose
This file stores long-term collaboration preferences so Codex can stay consistent across sessions.

## Session Startup Checklist
At the start of each new chat, always read these files before doing work:
1. `AGENTS.md`
2. `memory.md`
3. `project_context.md`
4. `decision_log.md`

## Communication Preferences
- Prefer concise, practical answers.
- Ask clarifying questions only when needed.
- Provide actionable options when tradeoffs exist.

## Working Rules
- When user says "记住这条" or "更新记忆", update `memory.md` or `decision_log.md` immediately.
- Do not rely on chat history as the only source of truth.
- Treat the four memory files as highest-priority context.
- After substantial tasks, capture reusable lessons into `memory.md` or `decision_log.md`, then run `/Users/jack/Documents/Playground/sync_memory_to_ob.sh`.
- Prefer using `/Users/jack/Documents/Playground/capture_learning.sh` to standardize memory/decision updates and keep Obsidian mirror in sync.

## Current User Concern
- User wants stronger memory behavior because Codex may forget prior statements.
- Mitigation: externalize memory into persistent files and load them every session.

