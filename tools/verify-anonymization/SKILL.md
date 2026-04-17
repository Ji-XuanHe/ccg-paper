---
name: verify-anonymization
description: 盲审匿名扫描：作者 / 机构 / URL / 致谢 / 自引措辞 / 元数据
license: MIT
user-invocable: false
---
# verify-anonymization
## 触发
盲审匿名扫描：作者 / 机构 / URL / 致谢 / 自引措辞 / 元数据
## 检查项
- 'our previous work'/'at X university' 字符串\n- GitHub/Twitter/personal URL\n- Acknowledgement 未删除\n- PDF metadata author 字段
## 执行
`node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js verify-anonymization <paper.tex> [options]`
报告分级：🔴 Critical（阻止投稿）/ 🟡 Major / 🟢 Info。
