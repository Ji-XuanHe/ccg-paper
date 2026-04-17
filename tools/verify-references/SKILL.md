---
name: verify-references
description: 引用完整性 / 断链 / 重复 key / 年份 / 会议名
license: MIT
user-invocable: false
---
# verify-references
## 触发
引用完整性 / 断链 / 重复 key / 年份 / 会议名
## 检查项
- BibTeX 重复 key\n- 未引用 label / 断裂 ref\n- arXiv 链接有效性（可选）\n- 会议全称/缩写一致
## 执行
`node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js verify-references <paper.tex> [options]`
报告分级：🔴 Critical（阻止投稿）/ 🟡 Major / 🟢 Info。
