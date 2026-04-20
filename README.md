# CCG-Paper · 顶会论文多模型协作系统

> **Claude Code · Codex · Gemini 三模型协作** · 面向 NeurIPS / ICML / ICLR / ACL / EMNLP / CVPR / AAAI / KDD / TPAMI 等顶会顶刊的论文写作、审稿、润色、Rebuttal 全流程自动化工作流。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blue)](https://claude.com/claude-code)
[![Multi-Model](https://img.shields.io/badge/Multi--Model-Claude%20%2B%20Codex%20%2B%20Gemini-green)](#)

---

## 目录

- [理念](#理念)
- [三模型分工](#三模型分工)
- [目录结构](#目录结构)
- [安装](#安装)
  - [详细安装指南](#详细安装指南)
- [快速上手](#快速上手)
- [核心工作流（8 阶段）](#核心工作流8-阶段)
- [完整命令清单（60+）](#完整命令清单60)
- [Writing Subskills（20 个写作子技能）](#writing-subskills20-个写作子技能)
- [Quality Gates（7 个质量关卡）](#quality-gates7-个质量关卡)
- [Multi-Reviewer Orchestration](#multi-reviewer-orchestration)
- [Domain Packs（领域知识包）](#domain-packs领域知识包)
- [高级场景](#高级场景)
- [状态与上下文管理](#状态与上下文管理)
- [最佳实践](#最佳实践)
- [常见问题](#常见问题)
- [贡献](#贡献)
- [License](#license)

---

## 理念

学术论文的写作与投稿是高复杂度、高风险、高反复的工作。CCG-Paper 把它拆成 **8 个可验证阶段**，每个阶段由最擅长的模型执行，并通过 **质量关卡（verify-\*）** 强制收敛。

设计参考自：
- **ccg**（~/.claude/skills/ccg）的 tools + writing + orchestration + domains 四层架构
- 顶会（NeurIPS / ICML / ACL 等）审稿流程中的 Area Chair / Reviewer / Meta-Review 机制
- Impeccable 的 20+ 写作子技能拆分法

不是又一个 "ChatGPT 改论文" 脚本，而是一个**带质量关卡、可回滚、可复现、多模型互相核验**的工程化系统。

---

## 三模型分工

| 模型 | 角色 | 强项场景 |
|------|------|---------|
| **Claude Code** | Area Chair · 编排者 | 结构规划、Meta-Review 综合、阶段编排、冲突仲裁、verify 脚本驱动 |
| **Codex** | Reviewer × 3 + Editor | 代码级审查（R1 Novelty / R2 Technical / R3 Writing）+ 具体文本修改 |
| **Gemini** | Deep Researcher | 文献调研、SOTA 核查、BibTeX 清洗、相关工作定位、事实核验 |

**冲突仲裁优先级**：`Gemini（文献事实）> Chair（结构/逻辑）> 单个 Reviewer（意见）`。

---

## 目录结构

```
ccg-paper/
├── SKILL.md                       主入口（Claude Code Skill 元数据）
├── README.md                      本文件
│
├── tools/                         ◆ 质量关卡（verify-*）
│   ├── verify-novelty/            创新点独立性与强度扫描
│   ├── verify-claims/             Abstract/Intro 的 claim 是否在实验中兑现
│   ├── verify-reproducibility/    超参 / 随机种子 / 数据 / 代码声明
│   ├── verify-anonymization/      盲审匿名扫描（作者 / 机构 / URL / 自引）
│   ├── verify-format/             LaTeX 编译 / 页数 / 模板合规
│   ├── verify-references/         Ref 完整性 / 断链 / 重复 key / 年份
│   ├── gen-outline/               生成目标会议论文骨架
│   └── run_skill.js               统一调度入口
│
├── writing/                       ◆ 20 个写作子技能（对标 Impeccable）
│   ├── tighten/   sharpen/   clarify/        hook/
│   ├── motivate/  contribution/ narrate/      mathify/
│   ├── figurize/  tablize/   cite/            anonymize/
│   ├── translate/ harmonize/ abbreviate/      americanize/
│   ├── venue-adapt/ page-fit/ section-balance/ headlinify/
│   └── */SKILL.md                每个子技能独立描述原则与步骤
│
├── orchestration/
│   └── multi-reviewer/            ◆ Chair / R1 / R2 / R3 / Meta 编排协议
│       └── SKILL.md               并行调用规范、Session 管理、冲突仲裁
│
├── domains/                       ◆ 领域知识包（自动路由）
│   ├── venues/                    neurips / icml / iclr / acl / emnlp / cvpr / aaai / kdd / tpami
│   ├── writing-style/             academic-english / tense / connectors / redundancy
│   ├── latex/                     environments / math / figures / tables / algorithms
│   ├── rebuttal/                  structure / tone / salvage-strategies / length-limits
│   ├── ethics/                    conflict-of-interest / llm-usage-declaration / data-ethics
│   ├── figures/                   colormap / tikz / matplotlib / accessibility
│   ├── statistics/                significance / confidence-intervals / p-hacking / ablation
│   └── literature/                search / citation-management / arxiv-workflow / semanticscholar
│
└── prompts/                       ◆ 角色 Prompt 定义
    ├── chair.md                   Area Chair（Claude）
    ├── r1-novelty.md              Reviewer 1 — 创新性 & positioning（Codex）
    ├── r2-technical.md            Reviewer 2 — 方法 & 实验严谨（Codex）
    ├── r3-writing.md              Reviewer 3 — 写作 & 叙事（Codex）
    ├── researcher.md              Deep Researcher（Gemini）
    ├── editor.md                  Editor / 修改执行者（Codex）
    └── meta.md                    Meta-Reviewer（Claude）
```

---

## 安装

### 作为 Claude Code Skill 使用（推荐）

```bash
# 克隆到 Claude Code Skills 目录
git clone git@github.com:xuanNULL/ccg-paper.git ~/.claude/skills/ccg-paper

# 验证
ls ~/.claude/skills/ccg-paper/SKILL.md
```

Claude Code 会自动识别 `SKILL.md` 中的 `user-invocable: true` 并注册所有子命令。

### 启用自动路由（可选）

将下面的规则文件放到 `~/.claude/rules/ccg-paper-routing.md`（见仓库根 `SKILL.md`），使 Claude Code 在命中触发关键词时自动加载对应 domain 知识包。

### 依赖

- **Claude Code CLI** ≥ 2.x
- **Codex MCP**（用于 reviewer / editor 角色）
- **Gemini CLI 或 MCP**（用于 deep research）
- **Node.js** ≥ 18（用于 `tools/run_skill.js`）
- **LaTeX 工具链**（`pdflatex` / `biber`，`verify-format` 需要）

### 详细安装指南

> **新手推荐**：如果你是第一次配置，推荐阅读 [SETUP.md](./SETUP.md) —— 包含从零开始的分步安装教程、API Key 获取步骤、常见问题排查。

一键安装（推荐）：
```bash
curl -fsSL https://raw.githubusercontent.com/xuanNULL/ccg-paper/main/setup.sh | bash
```
该脚本会自动检测已有组件、检测操作系统（macOS / Linux），并按需安装缺失依赖。

---

## 快速上手

### 3 分钟跑通一篇论文审查

```bash
# Step 0: 告诉系统你在做什么
/ccg-paper:teach
# → 交互式问：论文路径、目标会议、阶段（draft/review/rebuttal/camera-ready）、重点诉求

# Step 1: 文献调研（Gemini 后台跑）
/ccg-paper:research "自监督表示学习 SOTA"

# Step 2: 三个 Codex Reviewer 并行审稿
/ccg-paper:review

# Step 3: Chair 综合 Meta-Review
/ccg-paper:meta

# Step 4: 生成 P0/P1/P2/P3 修改路线图
/ccg-paper:plan

# Step 5: Codex 执行修改
/ccg-paper:revise P0

# Step 6: 组合润色
/ccg-paper:polish

# Step 7: 跑完所有 verify-*
/ccg-paper:submit
```

---

## 核心工作流（8 阶段）

```
┌──────────────┐
│ 0. teach     │  Claude：收集论文上下文（标题/路径/venue/阶段/重点）
└──────┬───────┘
       ▼
┌──────────────┐   ┌──────────────┐
│ 1. research  │   │ 1'. outline  │  可并行
│  (Gemini)    │   │  (Claude)    │
└──────┬───────┘   └──────┬───────┘
       └───────┬──────────┘
               ▼
       ┌──────────────┐
       │ 2. review    │  Codex × 3（R1/R2/R3 并行）
       └──────┬───────┘
              ▼
       ┌──────────────┐
       │ 3. meta      │  Claude 综合 → Meta-Review（P0-P3 + Disagreements）
       └──────┬───────┘
              ▼
       ┌──────────────┐
       │ 4. plan      │  Claude：可执行修改路线图
       └──────┬───────┘
              ▼
       ┌──────────────┐
       │ 5. revise    │  Codex：按路线图执行文本修改
       └──────┬───────┘
              ▼
       ┌──────────────┐
       │ 6. polish    │  Codex：组合应用 writing subskills
       └──────┬───────┘
              ▼
       ┌──────────────┐
       │ 7. verify-*  │  强制质量关卡（6 个）
       └──────┬───────┘
              ▼
       ┌──────────────┐
       │ 8. submit    │  Claude：投稿前终审 checklist
       └──────────────┘
```

| 阶段 | 命令 | 主力模型 | 产出 |
|------|------|----------|------|
| 0 | `/ccg-paper:teach` | Claude | `~/.claude/ccg-paper-plan.md` 初始化 |
| 1 | `/ccg-paper:research <topic>` | **Gemini** | 文献调研报告 + BibTeX |
| 1' | `/ccg-paper:outline` | Claude | 论文骨架 outline |
| 2 | `/ccg-paper:review [section]` | **Codex × 3** | R1/R2/R3 审查报告 |
| 3 | `/ccg-paper:meta` | Claude | Meta-Review（P0/P1/P2/P3） |
| 4 | `/ccg-paper:plan` | Claude | 修改路线图 |
| 5 | `/ccg-paper:revise [P0\|section]` | **Codex** | 修改 diff + 记录 |
| 6 | `/ccg-paper:polish` 或单个 writing subskill | Codex | 润色后稿件 |
| 7 | `/ccg-paper:verify-*` | Claude + Codex | 🔴/🟡/🟢 分级报告 |
| 8 | `/ccg-paper:submit` | Claude | Submission checklist |

---

## 完整命令清单（60+）

### 🧭 工作流骨架（12）

| 命令 | 说明 |
|------|------|
| `/ccg-paper` | 主入口 · 8 阶段工作流导航 |
| `/ccg-paper:teach` | 初始化论文任务上下文 |
| `/ccg-paper:research <topic>` | Gemini Deep Research 文献调研 |
| `/ccg-paper:outline` | 生成论文骨架 outline |
| `/ccg-paper:review [section]` | 并行多 reviewer 审查 |
| `/ccg-paper:meta` | Chair 综合生成 Meta-Review |
| `/ccg-paper:plan` | 生成可执行修改路线图 |
| `/ccg-paper:revise [P0\|section]` | Codex 按路线图修改 |
| `/ccg-paper:polish` | 组合应用 writing subskills 最终润色 |
| `/ccg-paper:submit` | 投稿前终审 checklist |
| `/ccg-paper:status` | 查看论文任务进度 |
| `/ccg-paper:rollback` | 回滚上一次 Codex 修改 |
| `/ccg-paper:diff` | 查看最近 N 次修改的 diff 汇总 |

### ✍️ Writing Subskills（20）

`tighten / sharpen / clarify / hook / motivate / contribution / narrate / mathify / figurize / tablize / cite / anonymize / translate / harmonize / abbreviate / americanize / venue-adapt / page-fit / section-balance / headlinify`

### ✅ Quality Gates（7）

`verify-novelty / verify-claims / verify-reproducibility / verify-anonymization / verify-format / verify-references / gen-outline`

### 🎯 高级场景（5）

| 命令 | 场景 |
|------|------|
| `/ccg-paper:rebuttal` | 审稿意见回应（审稿人聚类 → Gemini 查证 + Codex 起草 → Chair 综合 + 字数检查） |
| `/ccg-paper:camera-ready` | Camera-Ready 处理（加作者/致谢、Final version 引用、版权声明） |
| `/ccg-paper:extend-journal` | 会议论文扩展为期刊版本（扩章节 / 补实验 / 更深理论） |
| `/ccg-paper:split-workshop` | 拆出 workshop short paper（4–6 页，聚焦一个 claim） |
| `/ccg-paper:merge-papers` | 把 2 篇相关论文合并为更强的投稿 |

### 📚 领域速查（4）

| 命令 | 用途 |
|------|------|
| `/ccg-paper:venue <name>` | 打印目标会议审稿偏好（如 `neurips`） |
| `/ccg-paper:latex-help <topic>` | LaTeX 写作速查 |
| `/ccg-paper:stat-help <topic>` | 统计与实验严谨性速查 |
| `/ccg-paper:fig-help <topic>` | 图表制作速查 |

---

## Writing Subskills（20 个写作子技能）

> 对标 ccg 的 Impeccable 系统。每个子技能解决**一种**具体问题，正交可组合，但**一次只应用一个**以便 diff 追踪。

| 命令 | 目标 | 典型触发语 |
|------|------|-----------|
| `/ccg-paper:tighten` | 压缩冗余、降低字数（不丢信息） | "太长了" / "超页" |
| `/ccg-paper:sharpen` | 强化用词、提升学术感 | "太平淡" / "不够有力" |
| `/ccg-paper:clarify` | 消除歧义、简化复杂句 | "读不懂" / "晦涩" |
| `/ccg-paper:hook` | 优化 Abstract / Intro 首段（10 秒抓住问题） | "开头平淡" |
| `/ccg-paper:motivate` | 强化 motivation 与 problem significance | "动机不清" |
| `/ccg-paper:contribution` | 把贡献列表化、具体化、可验证、去重 | "贡献模糊" |
| `/ccg-paper:narrate` | 优化段落间衔接与叙事流 | "跳跃" / "断裂" |
| `/ccg-paper:mathify` | 符号一致性 / 公式排版 / 定义定理格式 | "符号乱" |
| `/ccg-paper:figurize` | 图例 / 配色 / caption / 引用 | "图不好看" |
| `/ccg-paper:tablize` | 表格排版 / 粗体最优解 / 显著性标注 | "表混乱" |
| `/ccg-paper:cite` | 规范引用 / 补漏引 / BibTeX 清洗 | "citation missing" |
| `/ccg-paper:anonymize` | 盲审匿名化（作者/机构/URL/自引/致谢） | "forgot to anon" |
| `/ccg-paper:translate` | 中文草稿 → 学术英文 | 中文稿 |
| `/ccg-paper:harmonize` | 术语 / 符号 / 缩写全文一致 | "不一致" |
| `/ccg-paper:abbreviate` | 首次全写 + 后续缩写规范 | — |
| `/ccg-paper:americanize` | 英式 ↔ 美式统一 | — |
| `/ccg-paper:venue-adapt` | 按目标会议改语气 / 结构 / 格式 | 改投 |
| `/ccg-paper:page-fit` | 压到限定页数 / 字数 | 超页 |
| `/ccg-paper:section-balance` | 调整各章节篇幅比例 | "Intro 过长" |
| `/ccg-paper:headlinify` | Section/subsection 标题精炼、平行结构 | "标题长" |

每个子技能在 `writing/<name>/SKILL.md` 有独立操作步骤与原则。

---

## Quality Gates（7 个质量关卡）

> **强制**：`submit` 前必须过完所有 verify-\*，**🔴 Critical 未清零不得投稿**。

| 关卡 | 检查内容 | 触发时机 |
|------|---------|---------|
| `/ccg-paper:verify-novelty` | 创新点独立性与强度（与 top-5 相关工作的 delta、claim 具体度、taxonomy 位置） | review 后 / submit 前 |
| `/ccg-paper:verify-claims` | Abstract/Intro 每条 claim 是否在 Method/Experiments 中兑现 | revise 后 |
| `/ccg-paper:verify-reproducibility` | 超参 / 随机种子 / 数据集 / 代码声明 / 资源需求 | submit 前 |
| `/ccg-paper:verify-anonymization` | 作者 / 机构 / URL / 致谢 / 自引措辞 / PDF 元数据 | 盲审会议必跑 |
| `/ccg-paper:verify-format` | LaTeX 编译 / 页数 / 模板 / 字号 / 边距 / 字体 | submit 前必跑 |
| `/ccg-paper:verify-references` | Ref 完整性、断链、重复 key、年份、会议名 | polish 后 |

### 命令行调用

```bash
node ~/.claude/skills/ccg-paper/tools/run_skill.js <tool> [args]

# 示例
node ~/.claude/skills/ccg-paper/tools/run_skill.js verify-anonymization paper.tex
node ~/.claude/skills/ccg-paper/tools/run_skill.js verify-format paper.tex --venue neurips
node ~/.claude/skills/ccg-paper/tools/run_skill.js verify-references paper.tex refs.bib
```

### 输出严重度

- 🔴 **Critical** — 阻止投稿（必须修复）
- 🟡 **Major** — 强烈建议修复
- 🟢 **Info** — 提示

---

## Multi-Reviewer Orchestration

### 5 角色模型

| 角色 | 模型 | 职责 | Prompt 文件 |
|------|------|------|------------|
| **Chair** | Claude | 编排、分派、仲裁、综合 Meta-Review | `prompts/chair.md` |
| **R1 — Novelty** | Codex | 创新性与 positioning 角度 | `prompts/r1-novelty.md` |
| **R2 — Technical** | Codex | 方法推导、实验严谨、可复现 | `prompts/r2-technical.md` |
| **R3 — Writing** | Codex | 写作、叙事、图表、组织 | `prompts/r3-writing.md` |
| **Researcher** | Gemini | Deep Research、文献与事实核查 | `prompts/researcher.md` |

### 并行调用规范（核心要点）

- 用 `Bash` 执行 `pwd` 得 `{{WORKDIR}}`
- **3 个 Codex reviewer 并行**（`run_in_background: true`），Gemini 独立一路
- 每个 reviewer 首次返回的 `SESSION_ID` 保存（`CODEX_R1_SESSION` / `CODEX_R2_SESSION` / `CODEX_R3_SESSION`）
- 等待用 `TaskOutput({ timeout: 600000 })`，超时轮询，**禁止 Kill**
- **冲突仲裁**：`Gemini（文献事实） > Claude Chair（结构/逻辑） > Reviewer 单方意见`

详见 [`orchestration/multi-reviewer/SKILL.md`](orchestration/multi-reviewer/SKILL.md)。

---

## Domain Packs（领域知识包）

> 对标 ccg 的 `domains/` 系统。Claude 在命中关键词时**必须先 Read 对应知识包再响应**，不得凭训练数据臆造。

| 知识包 | 触发关键词 | 路径 |
|--------|-----------|------|
| **venues** | NeurIPS / ICML / ICLR / ACL / EMNLP / CVPR / AAAI / KDD / TPAMI | `domains/venues/<venue>.md` |
| **writing-style** | 学术英语 / 语态 / 时态 / 连接词 / 冗余 | `domains/writing-style/*.md` |
| **latex** | tex / 环境 / 浮动体 / 符号 / 算法 | `domains/latex/*.md` |
| **rebuttal** | rebuttal / 审稿回应 / 反驳 / 字数限制 | `domains/rebuttal/*.md` |
| **ethics** | 利益冲突 / LLM 声明 / 数据伦理 | `domains/ethics/*.md` |
| **figures** | 图 / 配色 / TikZ / matplotlib / 色盲 | `domains/figures/*.md` |
| **statistics** | 显著性 / p-value / 置信区间 / 消融 / p-hacking | `domains/statistics/*.md` |
| **literature** | 文献搜索 / 引用管理 / arXiv / Semantic Scholar / BibTeX | `domains/literature/*.md` |

### 自动路由规则

将 `rules/ccg-paper-routing.md` 放到 `~/.claude/rules/` 即可启用。规则示例（节选）：

```markdown
# CCG-Paper Domain Knowledge — Auto-routing Rules

## Venues (`domains/venues/`)
| Trigger | File |
|---------|------|
| NeurIPS | `domains/venues/neurips.md` |
| ICML | `domains/venues/icml.md` |
| ...

## Routing Rules
1. 触发词 fuzzy 匹配 — 匹配意图而非字符串
2. 多重匹配 — 跨领域请求读多个
3. 会话内不重复读同一文件
4. 知识文件为准，冲突时文件胜过训练数据
```

---

## 高级场景

### 1. Rebuttal（审稿回应）

```bash
/ccg-paper:rebuttal
```

流程：
1. 按审稿人聚类所有 comments
2. Gemini 查证声称有误的文献/事实
3. Codex 按 `domains/rebuttal/structure.md` 起草
4. Chair 综合 + 字数检查（`domains/rebuttal/length-limits.md`）

### 2. Camera-Ready

```bash
/ccg-paper:camera-ready
```

- 加回作者信息 + 致谢
- Final version 引用更新
- 按会议要求加版权声明
- 扩展讨论 / 附录（如允许）

### 3. 会议论文 → 期刊扩展

```bash
/ccg-paper:extend-journal
```

扩章节 / 补实验 / 扩展相关工作 / 更深理论。目标 TPAMI / TMLR 等。

### 4. 拆 Workshop Short Paper

```bash
/ccg-paper:split-workshop
```

从大论文拆出 4–6 页、聚焦一个 claim 的 workshop paper。

### 5. 合并论文

```bash
/ccg-paper:merge-papers
```

把 2 篇相关论文合并为更强的投稿（常见于 rebuttal / re-submit）。

---

## 状态与上下文管理

论文任务上下文持久化在 `~/.claude/ccg-paper-plan.md`：

```markdown
# 论文任务: <标题>
- 文件: <path>
- 目标会议: <venue>
- 投稿阶段: <draft|review|rebuttal|camera-ready>
- 重点诉求: <focus>
- Session IDs: GEMINI=<id> CODEX_R1=<id> CODEX_R2=<id> CODEX_R3=<id>

## Deep Research 记录
## 审查报告（R1 / R2 / R3）
## Meta-Review
## 修改路线图
## 修改记录
## 润色记录
## 格式/匿名/引用检查
## Rebuttal 记录
```

### 查看进度

```bash
/ccg-paper:status
```

### 回滚

```bash
/ccg-paper:rollback          # 回滚上一次 Codex 修改
/ccg-paper:diff [N]          # 查看最近 N 次 diff（默认 N=5）
```

---

## 最佳实践

1. **先 teach 后开工** — 新论文必跑 `/ccg-paper:teach` 初始化上下文
2. **research 先行** — 让 Gemini Deep Research 跑一轮，降低审查盲点
3. **并行 reviewer** — 3 个 Codex reviewer 并行而非串行，节省时间
4. **小步迭代** — 每次只改一条 P0/P1，便于回退与 diff
5. **writing 正交** — 多个 writing subskill 可组合，但**一次只应用一个**
6. **verify 强制** — submit 前必须过完所有 verify-\*，🔴 Critical 未清零不得投稿
7. **引用必回验** — 改术语/公式后用 Grep 扫全仓
8. **冲突仲裁** — Gemini 文献 > Chair 结构 > Reviewer 单方意见
9. **盲审优先** — 盲审会议每次 revise 后都跑 `verify-anonymization`
10. **会议适配** — 改投前跑 `venue-adapt` + 对应 `domains/venues/<name>.md`

---

## 常见问题

**Q: 和 ChatGPT 改论文有什么不一样？**
A: ChatGPT 是单模型一次性建议；CCG-Paper 是**多模型、多阶段、带质量关卡、可回滚**的工程化流程。3 个 Codex Reviewer 独立审稿，Gemini 查文献，Claude 综合 Meta-Review，再按 P0/P1/P2/P3 逐条修。

**Q: 必须装 Codex 和 Gemini 吗？**
A: 推荐全装。如果只有 Claude，可以跑 outline / plan / polish / verify-\*，但 review 会退化为单模型。

**Q: 支持哪些会议？**
A: `domains/venues/` 目前覆盖 NeurIPS / ICML / ICLR / ACL / EMNLP / CVPR / AAAI / KDD / TPAMI。其他会议可用 `venue-adapt` 通用模式，或者按现有格式加一个 `<venue>.md`。

**Q: LaTeX 编译失败怎么办？**
A: `verify-format` 会给出具体行号与报错。常见问题见 `domains/latex/environments.md`。

**Q: 可以只用其中一部分吗？**
A: 可以。所有 subskill 和 verify-\* 都可独立调用。例如改别人的论文，只跑 `/ccg-paper:polish` + `/ccg-paper:verify-references` 完全 OK。

**Q: 中文稿怎么投英文会议？**
A: `/ccg-paper:translate` 把中文稿转学术英文，再跑标准 8 阶段流程。

---

## 贡献

欢迎 PR：
- 新会议的 `domains/venues/<venue>.md`
- 新 writing subskill
- 新 verify-\* 关卡
- Prompt 优化

建议：
1. Fork → 新 branch
2. 新增文件遵循现有目录与 frontmatter 规范
3. 附一个实际使用案例（跑通的 demo）

---

## License

MIT License · 详见 `LICENSE`。

---

## 致谢

- 架构参考 [ccg](https://github.com/) 的 tools + writing + orchestration + domains 四层系统
- Writing subskills 设计参考 Impeccable
- Multi-Reviewer 角色模型参考 NeurIPS / ICML 审稿流程

---

**作者**：[@Ji-XuanHe](https://github.com/Ji-XuanHe)
**仓库**：<https://github.com/Ji-XuanHe/ccg-paper>
