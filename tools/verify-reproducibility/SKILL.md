---
name: verify-reproducibility
description: 可复现性：超参 / 随机种子 / 数据 / 代码 / 资源
license: MIT
user-invocable: false
---
# verify-reproducibility
## 触发
可复现性：超参 / 随机种子 / 数据 / 代码 / 资源
## 检查项
- 是否有超参表\n- 随机种子是否明示\n- 数据来源/版本是否可定位\n- 代码 URL 是否存在（盲审需匿名）\n- 硬件/运行时间是否交代
## 执行
`node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js verify-reproducibility <paper.tex> [options]`
报告分级：🔴 Critical（阻止投稿）/ 🟡 Major / 🟢 Info。
