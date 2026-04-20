---
name: style-polish
description: 使用 agent-style 的 21 条规则润色论文英文。调用 /style-review 生成 .reviewed 版本。
license: MIT
user-invocable: true
category: writing
---

# style-polish

## 用法

```bash
/ccg-paper:style-polish <file>
```

## 工作流

1. 调用 `/style-review <file>`
2. style-review 会：
   - 审计文件 against 21 条规则
   - 显示 per-rule scorecard
   - 询问："Produce a polished draft at FILE.reviewed.md?"
3. 如用户确认，生成润色稿并显示 before → after scorecard
4. 询问是否替换原文件：
   - Yes → `mv <file>.reviewed.md <file>`
   - No → 保留两个版本，用户手动 merge

## 与其他 writing subskills 的关系

`style-polish` 是通用英文技术写作润色，应在以下 subskills **之后**运行：

```
/ccg-paper:tighten         # 压缩冗余
  ↓
/ccg-paper:clarify         # 消除歧义
  ↓
/ccg-paper:sharpen         # 强化用词
  ↓
/ccg-paper:harmonize       # 术语一致性
  ↓
/ccg-paper:style-polish    # agent-style 21 规则润色 ← 你在这里
```

## 规则覆盖

agent-style 21 条规则与 ccg-paper subskills 的映射：

| agent-style 规则 | ccg-paper subskill | 说明 |
|------------------|-------------------|------|
| RULE-01 (curse of knowledge) | clarify | agent-style 更机械化 |
| RULE-04 (redundancy) | tighten | ccg-paper 更语境化 |
| RULE-06 (AI-tell words) | sharpen | 互补 |
| RULE-F (term consistency) | harmonize | 互补 |
| RULE-08 (overclaiming) | motivate | agent-style 检测，ccg-paper 修复 |
| RULE-H (unsupported facts) | cite | agent-style 检测，ccg-paper 修复 |

**集成策略**：
- ccg-paper subskills 处理**语境化**问题（学术论文特定）
- agent-style 处理**机械化**问题（通用技术写作）
- 两者互补，不冲突

## 依赖

需要安装 agent-style 并启用 style-review skill：

```bash
pip install agent-style
agent-style enable style-review
```

## 示例

```bash
# 完整润色流程
/ccg-paper:tighten paper.tex
/ccg-paper:clarify paper.tex
/ccg-paper:sharpen paper.tex
/ccg-paper:harmonize paper.tex
/ccg-paper:style-polish paper.tex    # 最后一步

# 或使用 polish 命令（自动调用所有 subskills）
/ccg-paper:polish paper.tex
```

## 输出示例

```
Running /style-review paper.tex...

Style Audit Results:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Critical: 2 violations
  RULE-01: 1 @ line 45
  RULE-H: 1 @ line 89
High: 5 violations
  RULE-06: 3 @ lines 12, 34, 67
  RULE-F: 2 @ lines 23, 56
Medium: 12 violations
Low: 3 violations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Produce a polished draft at paper.reviewed.tex? (y/n)
> y

Generating polished draft...
✅ Written to paper.reviewed.tex

Before → After:
  Critical: 2 → 0 (-2)
  High: 5 → 1 (-4)
  Medium: 12 → 8 (-4)
  Low: 3 → 2 (-1)

Replace original file? (y/n)
> y

✅ paper.tex updated
```
