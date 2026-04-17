---
name: verify-novelty
description: 创新点独立性与强度扫描：与 top-5 相关工作 delta / claim 具体度 / 与现有 paradigm 的 taxonomy 位置
license: MIT
user-invocable: false
---
# verify-novelty
## 触发
创新点独立性与强度扫描：与 top-5 相关工作 delta / claim 具体度 / 与现有 paradigm 的 taxonomy 位置
## 检查项
- Abstract/Intro 中 claim 是否具体可验证\n- 是否有 related work 贬低表述\n- 核心贡献与最近 2 年顶会有无重合
## 执行
`node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js verify-novelty <paper.tex> [options]`
报告分级：🔴 Critical（阻止投稿）/ 🟡 Major / 🟢 Info。
