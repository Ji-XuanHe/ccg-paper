---
name: verify-style
description: 英文技术写作风格审查关卡。检测 agent-style 21 条规则违规，Critical/High 违规阻塞提交。
license: MIT
user-invocable: true
---

# verify-style

## 触发时机

- `/ccg-paper:submit` — 投稿前终审
- `/ccg-paper:polish` — 润色后验证
- 手动调用：`/ccg-paper:verify-style <file>`

## 检查项

基于 agent-style 21 条规则：

**Critical 规则**（阻塞提交）：
- RULE-01: 未定义术语/缩写（curse of knowledge）
- RULE-08: 声明超出证据强度（overclaiming）
- RULE-H: 无引用支持的事实/数据

**High 规则**（强烈建议修复）：
- RULE-02: 主语重要时使用被动语态
- RULE-03: 抽象语言替代具体术语
- RULE-04: 冗余词语
- RULE-06: AI-tell 词汇（leverage, facilitate, utilize 等）
- RULE-F: 术语不一致

**Medium/Low 规则**（记录，不阻塞）：
- RULE-12: 句子超过 30 词
- RULE-A: 过度使用 bullet points
- RULE-B: em-dash 滥用
- RULE-C: 连续句子相同开头
- RULE-E: 每段落用总结句结尾
- 其他 9 条规则

## 执行

```bash
node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js verify-style <paper.tex|paper.md>
```

## 输出格式

```
Style Audit (agent-style v0.2.0)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Critical: 2 violations
  RULE-01 (curse of knowledge): 1 @ line 45
  RULE-H (unsupported claims): 1 @ line 89
High: 5 violations
  RULE-06 (AI-tell words): 3 @ lines 12, 34, 67
  RULE-F (term inconsistency): 2 @ lines 23, 56
Medium: 12 violations
Low: 3 violations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: ❌ BLOCKED (2 Critical)

Recommendation: Run /style-review <file> to generate polished draft
```

报告分级：🔴 Critical（阻止投稿）/ 🟡 High（警告）/ 🟢 Medium/Low（记录）

## 与 style-review 的关系

- `verify-style` — 只审计，不修改（质量关卡）
- `/style-review` — 审计 + 生成润色稿（writing subskill）

## 依赖

需要安装 agent-style：

```bash
pip install agent-style
```

或

```bash
npm install -g agent-style
```
