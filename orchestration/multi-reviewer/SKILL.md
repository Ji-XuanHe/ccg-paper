---
name: multi-reviewer
description: 论文多 reviewer 编排系统。5 角色模型（Chair / R1-Novelty / R2-Technical / R3-Writing / Researcher），并行调用，会话复用，冲突仲裁。
license: MIT
user-invocable: false
---

# Multi-Reviewer Orchestration

对标 ccg 的 multi-agent。论文场景的 5 角色：

| 角色 | 模型 | Prompt 文件 | 关注维度 |
|------|------|-------------|----------|
| **Chair** | Claude Code | `prompts/chair.md` | 编排 / 结构 / 冲突仲裁 / Meta-Review |
| **R1 — Novelty** | Codex | `prompts/r1-novelty.md` | 创新点强度、positioning、与 SOTA 的 delta |
| **R2 — Technical** | Codex | `prompts/r2-technical.md` | 方法严谨、实验完整、可复现、统计 |
| **R3 — Writing** | Codex | `prompts/r3-writing.md` | 写作质量、叙事、图表、组织 |
| **Researcher** | Gemini | `prompts/researcher.md` | Deep Research 文献 / SOTA / 背景 |

---

## 核心原则

1. **文件系统零写入**：除 Chair 外所有 reviewer/researcher 都是 read-only，修改由 Chair 通过 Codex-Editor（独立会话）执行
2. **会话复用**：首次调用保存 `SESSION_ID`，后续 `resume <id>` 继承上下文
3. **并行优先**：3 个 reviewer 无依赖，必须并行（`run_in_background: true`）
4. **超时不 Kill**：`TaskOutput timeout: 600000` 超时继续轮询；若用户要中止须 `AskUserQuestion` 确认

---

## 调用语法

```
Bash({
  command: "/Users/ji-xuanhe/.claude/bin/codeagent-wrapper --progress --backend <codex|gemini> - \"{{WORKDIR}}\" <<'EOF'
ROLE_FILE: <对应 prompts/*.md 绝对路径>
<TASK>
目标会议: <venue>
投稿阶段: <stage>
章节 / 范围: <section>
论文原文 (或文件路径):
<内容>
Deep Research 结果 (若已有):
<内容>
</TASK>
OUTPUT: 严格按 prompt 定义的输出格式
EOF",
  run_in_background: true,
  timeout: 3600000,
  description: "<角色名> review"
})
```

复用语法：
```
... codeagent-wrapper --progress --backend codex resume <SESSION_ID> - ...
```

---

## 典型编排模式

### 并行审稿（review 阶段）
```
TaskCreate("R1") + TaskCreate("R2") + TaskCreate("R3") + TaskCreate("Gemini")  # 同一消息内并行
→ 4× TaskOutput({ timeout: 600000 }) 依次等待
→ Chair 综合到 Meta-Review
```

### 串行改稿（revise 阶段）
```
for each P0 item:
  Codex-Editor (workspace-write, 新会话) → diff
  Chair Read 文件验证 → Grep 扫交叉引用
  记录到 plan
```

### 混合（rebuttal 阶段）
```
Chair 拆分审稿意见
→ 并行: Gemini 查证事实 + Codex 起草反驳
→ Chair 综合为统一 rebuttal
```

---

## 仲裁规则

当 reviewer 之间、reviewer 与 Chair 之间冲突：

| 冲突类型 | 胜者 | 理由 |
|---------|------|------|
| 文献事实 vs Reviewer 主观判断 | Gemini | 可引用 |
| 结构/叙事判断 vs 局部建议 | Chair | 全局视角 |
| 2/3 reviewer 一致 vs 1/3 异议 | 多数 + Chair 复核 | 置信度 |
| 用户明示偏好 vs 所有 reviewer | **用户** | 最终决策权 |

冲突必须写入 Meta-Review 的 "Disagreements" 小节供用户裁决，不得静默吞掉。

---

## 会话 ID 管理

每个论文任务的 session 存在 `$HOME/.claude/ccg-paper-plan.md` 顶部：
```
- Session IDs:
  - GEMINI_RESEARCHER: <id>
  - CODEX_R1_NOVELTY:  <id>
  - CODEX_R2_TECH:     <id>
  - CODEX_R3_WRITING:  <id>
  - CODEX_EDITOR:      <id>   # 改稿专用，与 R* 分离避免上下文污染
```

**约定**：改稿 Codex session 必须与审稿 Codex session 分开，防止审稿时的批评语气影响执行修改。
