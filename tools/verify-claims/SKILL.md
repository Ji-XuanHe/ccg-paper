---
name: verify-claims
description: Abstract/Intro 每条 claim 是否在 Method/Experiments 中兑现
license: MIT
user-invocable: false
---
# verify-claims
## 触发
Abstract/Intro 每条 claim 是否在 Method/Experiments 中兑现
## 检查项
- 逐条提取 claim → 扫 Method/Experiments 匹配\n- 未兑现 claim → 🔴\n- 部分兑现 → 🟡 + 建议
## 执行
`node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js verify-claims <paper.tex> [options]`
报告分级：🔴 Critical（阻止投稿）/ 🟡 Major / 🟢 Info。
