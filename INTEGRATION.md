# agent-style × ccg-paper 集成完成

## 集成概述

已成功将 agent-style 的 21 条英文技术写作规则集成到 ccg-paper 科研论文工作流中。

## 已完成的集成点

### 1. ✅ verify-style 质量关卡

**位置**：`~/.claude/skills/ccg-paper/tools/verify-style/`

**文件**：
- `SKILL.md` — 关卡定义与说明
- `run.sh` — 执行脚本（调用 agent-style CLI）

**功能**：
- 在投稿前终审自动触发
- 检测 agent-style 21 条规则违规
- Critical/High 违规阻塞提交
- 输出分级报告（🔴 Critical / 🟡 High / 🟢 Medium/Low）

**使用**：
```bash
/ccg-paper:verify-style paper.tex
```

---

### 2. ✅ style-polish 写作子命令

**位置**：`~/.claude/skills/ccg-paper/writing/style-polish/`

**文件**：
- `SKILL.md` — 子命令定义

**功能**：
- 封装 `/style-review` 调用
- 审计 + 生成润色稿
- 显示 before → after scorecard
- 可选替换原文件

**使用**：
```bash
/ccg-paper:style-polish paper.tex
```

**推荐顺序**：
```
/ccg-paper:tighten         # 压缩冗余
  ↓
/ccg-paper:clarify         # 消除歧义
  ↓
/ccg-paper:sharpen         # 强化用词
  ↓
/ccg-paper:harmonize       # 术语一致
  ↓
/ccg-paper:style-polish    # agent-style 21 规则润色
  ↓
/ccg-paper:verify-style    # 终审
```

---

### 3. ✅ R3-writing reviewer 增强

**位置**：`~/.claude/skills/ccg-paper/prompts/r3-writing.md`

**修改**：
- 在审查 prompt 开头添加 agent-style 规则引用
- 输出格式包含 Style Audit scorecard
- Critical/High 违规自动归入对应严重度

**效果**：
- R3 审查时自动应用 21 条规则
- Meta-Review 包含 style scorecard
- 修改路线图包含 style violations 修复任务

---

### 4. ✅ Codex editor prompt 增强

**位置**：`~/.claude/skills/ccg-paper/prompts/editor.md`

**修改**：
- 添加"写作指南（agent-style）"章节
- 列出学术论文优先规则（6 条）
- 要求修改文本时检查规则

**效果**：
- Codex 在生成时就遵循规则
- 减少后期修改成本

---

### 5. ✅ 主工作流更新

**位置**：`~/.claude/skills/ccg-paper/SKILL.md`

**修改**：
- 工作流图添加 agent-style 集成点
- Writing Subskills 从 20 个增至 21 个
- Quality Gates 从 7 个增至 8 个
- 更新命令目录和最佳实践

**新增内容**：
- 目录结构包含 `verify-style/` 和 `style-polish/`
- 核心工作流标注 agent-style 触发点
- Quality Gates 表格添加 verify-style 行

---

## 集成架构

```
ccg-paper 工作流
├── 0. teach          → 检查并启用 agent-style
├── 1. research       → Gemini prompt 包含 RULES.md
├── 2. review         → R3-writing 应用 agent-style 规则
├── 3. meta           → Meta-review 包含 style scorecard
├── 4. plan           → 路线图包含 style violations 修复
├── 5. revise         → Codex 遵循 agent-style 规则
├── 6. polish         → 自动调用 style-polish
└── 7. verify-*       → verify-style 作为终审关卡
```

---

## 规则映射

| agent-style 规则 | ccg-paper 对应 | 优先级 |
|------------------|----------------|--------|
| RULE-01 (curse of knowledge) | clarify | Critical |
| RULE-04 (redundancy) | tighten | High |
| RULE-06 (AI-tell words) | sharpen | High |
| RULE-F (term consistency) | harmonize | High |
| RULE-08 (overclaiming) | motivate | Critical |
| RULE-H (unsupported facts) | cite | Critical |

**集成策略**：
- ccg-paper subskills 处理**语境化**问题（学术论文特定）
- agent-style 处理**机械化**问题（通用技术写作）
- 两者互补，不冲突

---

## 使用示例

### 场景 1：投稿前终审

```bash
# 1. 初始化（自动检查 agent-style）
/ccg-paper:teach
# 输入：paper.tex, NeurIPS, 投稿前终审, writing

# 2. 多 reviewer 审查（R3 自动应用 agent-style）
/ccg-paper:review paper.tex

# 3. 生成 Meta-Review（包含 style scorecard）
/ccg-paper:meta

# 4. 生成修改路线图（包含 style violations）
/ccg-paper:plan

# 5. Codex 执行修改（遵循 agent-style 规则）
/ccg-paper:revise

# 6. 最终润色（自动调用 style-polish）
/ccg-paper:polish paper.tex

# 7. 终审（verify-style 作为关卡）
/ccg-paper:submit
```

### 场景 2：快速风格检查

```bash
# 只检查，不修改
/ccg-paper:verify-style paper.tex

# 检查 + 生成润色稿
/ccg-paper:style-polish paper.tex
```

### 场景 3：A/B 对比

```bash
# 在 revise 前后对比
cp paper.tex paper-before.tex
/ccg-paper:revise paper.tex
/style-review paper-before.tex paper.tex
# 输出 per-rule delta table
```

---

## 依赖要求

### 必需

```bash
# 安装 agent-style
pip install agent-style

# 或
npm install -g agent-style
```

### 可选（用于 style-review skill）

```bash
# 启用 style-review skill
agent-style enable style-review
```

---

## 验证集成

### 1. 检查文件结构

```bash
ls ~/.claude/skills/ccg-paper/tools/verify-style/
# 期望：SKILL.md, run.sh

ls ~/.claude/skills/ccg-paper/writing/style-polish/
# 期望：SKILL.md
```

### 2. 测试 verify-style

```bash
# 使用 agent-style fixture 测试
cd /Users/ji-xuanhe/setup/internship/code/agent-style
cp skills/style-review/references/fixture-prose/mixed.md /tmp/test-paper.md

/ccg-paper:verify-style /tmp/test-paper.md
# 期望：检测到违规
```

### 3. 测试 style-polish

```bash
/ccg-paper:style-polish /tmp/test-paper.md
# 期望：生成 test-paper.reviewed.md
```

---

## 性能优化

### 1. 规则缓存

agent-style 规则文件（RULES.md）在会话中只加载一次，避免重复读取。

### 2. 并行审查

R3-writing 的 agent-style 审查与 R1/R2 并行执行，不增加总时间。

---

## 未来扩展

### 1. 中文学术论文支持

agent-style 当前只支持英文规则。未来可扩展：
- 添加中文技术写作规则
- 在 ccg-paper 的 `translate` subskill 中集成

### 2. LaTeX 特定规则

agent-style 当前主要针对 Markdown。未来可添加：
- LaTeX 环境检测（不在 `\begin{equation}` 内应用 RULE-12）
- BibTeX 引用完整性检查（与 RULE-H 集成）

### 3. 会议特定规则

不同会议对写作风格有不同偏好。未来可在 `domains/venues/<venue>.md` 中添加：
- NeurIPS：偏好主动语态（RULE-02 权重 +1）
- ICML：偏好简洁（RULE-12 阈值降至 25 词）
- ACL：偏好具体示例（RULE-01 权重 +1）

---

## 故障排除

### agent-style 未安装

```
❌ agent-style not installed

Install with:
  pip install agent-style
  # or
  npm install -g agent-style
```

### verify-style 失败

检查 agent-style CLI 是否可用：
```bash
which agent-style
agent-style --version
```

### style-review skill 不可用

确保已启用：
```bash
agent-style enable style-review
```

---

## 总结

集成完成后的 ccg-paper 工作流：

**核心价值**：
- **生成时引导**：Codex/Gemini 在生成时就遵循规则，减少后期修改
- **事后审查**：style-review 捕获生成时遗漏的违规
- **质量关卡**：verify-style 确保投稿前达到写作质量标准
- **A/B 对比**：量化修改前后的风格改进

**文件清单**：
- ✅ `tools/verify-style/SKILL.md`
- ✅ `tools/verify-style/run.sh`
- ✅ `writing/style-polish/SKILL.md`
- ✅ `prompts/r3-writing.md`（已修改）
- ✅ `prompts/editor.md`（已修改）
- ✅ `SKILL.md`（已修改）
- ✅ `INTEGRATION.md`（本文件）

**下一步**：
1. 在真实论文上测试完整工作流
2. 收集用户反馈
3. 根据反馈调整规则权重和阈值
