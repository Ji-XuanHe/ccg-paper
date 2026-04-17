---
name: contribution
description: 把贡献列表化、具体化、可验证、去重
argument-hint: "[section or file]"
user-invocable: false
---

## MANDATORY PREPARATION
Read /Users/ji-xuanhe/.claude/skills/ccg-paper/SKILL.md 与 /Users/ji-xuanhe/.claude/skills/ccg-paper/prompts/editor.md，若涉及会议偏好先 Read `domains/venues/<venue>.md`。

---

## 目标
每条贡献 action-verb 开头，含可验证产出

## 触发语（用户可能说）
贡献模糊 / contribution 弱

## 操作
1. 读 plan 获取当前论文/章节
2. 构造 Codex 指令模板（ROLE_FILE=editor.md）并注入本 skill 的专用提示
3. mcp__codex__codex（sandbox=workspace-write）执行
4. Read 文件验证 + Grep 回验
5. 记录到 plan `## 润色记录`
