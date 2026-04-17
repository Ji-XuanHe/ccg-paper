---
name: verify-format
description: LaTeX 编译 / 页数 / 模板 / 字号 / 边距 / 字体
license: MIT
user-invocable: false
---
# verify-format
## 触发
LaTeX 编译 / 页数 / 模板 / 字号 / 边距 / 字体
## 检查项
- begin/end 环境匹配\n- 页数是否超限\n- 模板是否匹配目标会议\n- 是否有未定义 label/ref
## 执行
`node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js verify-format <paper.tex> [options]`
报告分级：🔴 Critical（阻止投稿）/ 🟡 Major / 🟢 Info。
