---
name: narrate
description: 优化段落间衔接与叙事流
argument-hint: "[section or file]"
user-invocable: false
---

## MANDATORY PREPARATION
Read /Users/ji-xuanhe/.claude/skills/ccg-paper/SKILL.md 与 /Users/ji-xuanhe/.claude/skills/ccg-paper/prompts/editor.md，若涉及会议偏好先 Read `domains/venues/<venue>.md`。

---

## 目标
加逻辑连接词、补过渡句、消除跳跃

## 触发语（用户可能说）
叙事跳跃 / 段落断裂

## 操作
1. 读 plan 获取当前论文/章节
2. 构造 Codex 指令模板（ROLE_FILE=editor.md）并注入本 skill 的专用提示
3. mcp__codex__codex（sandbox=workspace-write）执行
4. Read 文件验证 + Grep 回验
5. 记录到 plan `## 润色记录`
