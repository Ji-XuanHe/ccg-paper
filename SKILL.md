---
name: ccg-paper
description: 科研顶会论文的多模型协作工作流系统。对标 ccg 架构：多 reviewer 编排、writing subskills、质量关卡、领域知识包。Gemini=Deep Research（文献/SOTA/背景调研），Codex=Reviewer+Editor（审稿+改稿），Claude Code=Area Chair（编排+结构+Meta-Review）。触发：改论文 / 文献调研 / Related Work / 审稿回应 / 语言润色 / 投稿前终审 / LaTeX 格式 / Rebuttal / Camera Ready / 顶会投稿。
license: MIT
user-invocable: true
---

# CCG-Paper — 顶会论文多模型协作系统

> 结构对标 `~/.claude/skills/ccg/`：tools（verify 关卡）+ writing（subskill）+ orchestration（multi-reviewer）+ domains（知识包）。

## 目录结构

```
skills/ccg-paper/
├── SKILL.md                     本文件（主入口）
├── tools/                       质量关卡
│   ├── verify-novelty/              创新点独立性与强度
│   ├── verify-claims/               Abstract/Intro 的 claim 是否在实验中兑现
│   ├── verify-reproducibility/      可复现性（超参、数据、代码声明）
│   ├── verify-anonymization/        盲审匿名扫描
│   ├── verify-format/               LaTeX / 页数 / 模板
│   ├── verify-references/           引用完整性、断链、重复 key
│   ├── verify-style/                英文技术写作风格（agent-style 21 规则）
│   ├── gen-outline/                 生成目标会议的论文骨架
│   └── lib/
├── writing/                     21 个写作子技能（对标 Impeccable）
│   ├── tighten/    sharpen/    clarify/        hook/
│   ├── motivate/   contribution/  narrate/     mathify/
│   ├── figurize/   tablize/    cite/           anonymize/
│   ├── translate/  harmonize/  abbreviate/     americanize/
│   ├── venue-adapt/ page-fit/  section-balance/ headlinify/
│   ├── style-polish/            agent-style 21 规则润色
├── orchestration/
│   ├── multi-reviewer/              Chair/R1/R2/R3/Meta 角色系统
│   └── SKILL.md
├── domains/                     领域知识包
│   ├── venues/       NeurIPS/ICML/ICLR/ACL/EMNLP/CVPR/AAAI/KDD/TPAMI 审稿偏好
│   ├── writing-style/ 学术英语/被动语态/时态/连接词/冗余消除
│   ├── latex/        环境/引用/表格/符号/浮动体
│   ├── rebuttal/     结构/长度/抢救策略/语气
│   ├── ethics/       利益冲突/数据伦理/作者贡献/LLM 使用声明
│   ├── figures/      图例/色彩/可访问性/TikZ/matplotlib
│   ├── statistics/   置信区间/显著性/p-hacking 规避
│   └── literature/   搜索/筛选/引用管理/arXiv/SemanticScholar
└── prompts/                     各角色 prompt 文件
    ├── chair.md      area-chair
    ├── r1-novelty.md reviewer 1 — novelty/positioning
    ├── r2-technical.md reviewer 2 — technical soundness
    ├── r3-writing.md reviewer 3 — writing/presentation
    ├── researcher.md  gemini deep researcher
    ├── editor.md      codex editor
    └── meta.md        meta-reviewer
```

---

## 快速导航

| 类别 | 说明 | 入口 |
|------|------|------|
| **核心工作流** | 研究→审查→计划→修改→润色→终审 | [核心工作流](#核心工作流) |
| **Writing Subskills** | 21 个针对性写作改进命令 | [Writing Subskills](#writing-subskills) |
| **Quality Gates** | 6 个强制质量关卡 | [Quality Gates](#quality-gates) |
| **Multi-Reviewer** | Chair / R1 / R2 / R3 / Meta 编排 | [Multi-Reviewer](#multi-reviewer-orchestration) |
| **Domain Packs** | 会议 / 写作 / LaTeX / Rebuttal / … | [Domain Packs](#domain-packs) |

---

## 核心工作流

```
┌───────────────┐
│  0. teach     │  → 告知 skill 当前论文目标会议/阶段/重点
│               │     检查并启用 agent-style
└───────┬───────┘
        ▼
┌───────────────┐  ┌───────────────┐
│  1. research  │  │  1'. outline  │  并行可选
│   (Gemini)    │  │   (Claude)    │
└───────┬───────┘  └───────┬───────┘
        └─────────┬─────────┘
                  ▼
         ┌───────────────┐
         │  2. review    │  多 reviewer 并行
         │  R1 / R2 / R3 │  R3 应用 agent-style 规则
         └───────┬───────┘
                 ▼
         ┌───────────────┐
         │  3. meta      │  Chair 综合 → Meta-Review
         │               │  包含 style scorecard
         └───────┬───────┘
                 ▼
         ┌───────────────┐
         │  4. plan      │  P0/P1/P2/P3 修改路线图
         │               │  包含 style violations 修复
         └───────┬───────┘
                 ▼
         ┌───────────────┐
         │  5. revise    │  Codex 执行修改
         │               │  遵循 agent-style 规则
         └───────┬───────┘
                 ▼
         ┌───────────────┐
         │  6. polish    │  writing subskills 组合应用
         │               │  + style-polish (agent-style)
         └───────┬───────┘
                 ▼
         ┌───────────────┐
         │  7. verify-*  │  质量关卡（强制）
         │               │  + verify-style
         └───────┬───────┘
                 ▼
         ┌───────────────┐
         │  8. submit    │  投稿前终审 checklist
         └───────────────┘
```

阶段与命令对应：

| 阶段 | 命令 | 主力模型 |
|------|------|----------|
| 0 | `/ccg-paper:teach` | Claude（收集上下文） |
| 1 | `/ccg-paper:research <topic>` | **Gemini** |
| 1' | `/ccg-paper:outline` | Claude |
| 2 | `/ccg-paper:review [section]` | **Codex × 3 + Claude** |
| 3 | `/ccg-paper:meta` | Claude |
| 4 | `/ccg-paper:plan` | Claude |
| 5 | `/ccg-paper:revise [P0\|section]` | **Codex** |
| 6 | `/ccg-paper:polish` 或任一 writing subskill | Codex |
| 7 | `/ccg-paper:verify-*` | Claude（scripts）+ Codex |
| 8 | `/ccg-paper:submit` | Claude |
| — | `/ccg-paper:status` / `:rollback` / `:diff` | Claude |

---

## Writing Subskills

**对标 ccg 的 Impeccable 子技能系统**。每个 subskill 解决一种具体的论文写作问题，由 Codex 执行。

| 命令 | 目标 | 典型触发语 |
|------|------|-----------|
| `/ccg-paper:tighten` | 压缩冗余、降低字数 | "太长了" / "超页" |
| `/ccg-paper:sharpen` | 强化用词、提升学术感 | "太平淡" / "不够有力" |
| `/ccg-paper:clarify` | 消除歧义、简化复杂句 | "读不懂" / "晦涩" |
| `/ccg-paper:hook` | 优化 Abstract / Intro 首段的吸引力 | "开头平淡" |
| `/ccg-paper:motivate` | 强化 motivation 与 problem significance | "动机不清" |
| `/ccg-paper:contribution` | 把贡献列表化、具体化、可验证 | "贡献模糊" |
| `/ccg-paper:narrate` | 优化段落间衔接与叙事流 | "跳跃" / "断裂" |
| `/ccg-paper:mathify` | 符号一致性 / 公式排版 / 定义/定理格式 | "符号乱" |
| `/ccg-paper:figurize` | 图例 / 配色 / caption / 引用 | "图不好看" |
| `/ccg-paper:tablize` | 表格排版 / 粗体最优 / 显著性标注 | "表混乱" |
| `/ccg-paper:cite` | 规范引用 / 补漏引 / BibTeX 清洗 | "citation missing" |
| `/ccg-paper:anonymize` | 盲审匿名化 | "forgot to anon" |
| `/ccg-paper:translate` | 中文草稿 → 学术英文 | 中文稿 |
| `/ccg-paper:harmonize` | 术语 / 符号 / 缩写全文一致 | "不一致" |
| `/ccg-paper:abbreviate` | 首次全写 + 后续缩写 | — |
| `/ccg-paper:americanize` | 英式 ↔ 美式统一 | — |
| `/ccg-paper:venue-adapt` | 按目标会议改语气/结构/格式 | 改投 |
| `/ccg-paper:page-fit` | 压到限定页数 / 字数 | 超页 |
| `/ccg-paper:section-balance` | 调整各章节篇幅比例 | "Intro 过长" |
| `/ccg-paper:headlinify` | Section/subsection 标题精炼 | "标题长" |
| `/ccg-paper:style-polish` | agent-style 21 规则润色 | "AI 味太重" / "润色" |

每个 subskill 单独有 `writing/<name>/SKILL.md` 描述操作步骤与原则。

---

## Quality Gates

**强制质量关卡，对标 ccg 的 `verify-*` 系列**。

| 关卡 | 检查内容 | 触发时机 |
|------|---------|---------|
| `/ccg-paper:verify-novelty` | 创新点区分度、与 top-5 相关工作的 delta | review 后 / submit 前 |
| `/ccg-paper:verify-claims` | Abstract/Intro 每条 claim 是否被实验证实 | revise 后 |
| `/ccg-paper:verify-reproducibility` | 超参 / 数据 / 代码声明 / 随机种子 | submit 前 |
| `/ccg-paper:verify-anonymization` | 自引 / URL / Acknowledgment / 元数据 | 盲审会议必跑 |
| `/ccg-paper:verify-format` | LaTeX 编译 / 页数 / 模板合规 | submit 前必跑 |
| `/ccg-paper:verify-references` | Ref 完整性、断链、重复 key、年份 | polish 后 |
| `/ccg-paper:verify-style` | 英文技术写作风格（agent-style 21 规则） | polish 后 / submit 前 |

### 运行方式

```bash
node /Users/ji-xuanhe/.claude/skills/ccg-paper/tools/run_skill.js <tool> [args]

# 示例
node .../run_skill.js verify-anonymization paper.tex
node .../run_skill.js verify-format paper.tex --venue neurips
node .../run_skill.js verify-references paper.tex refs.bib
```

输出严重度：🔴 Critical（阻止投稿）/ 🟡 Major / 🟢 Info。

---

## Multi-Reviewer Orchestration

**对标 ccg 的 multi-agent 系统**。论文审稿场景下使用 **5 角色模型**：

| 角色 | 模型 | 职责 |
|------|------|------|
| **Chair** | Claude | 编排、分派、仲裁、综合 Meta-Review |
| **R1 — Novelty** | Codex | 从创新性与 positioning 角度审稿 |
| **R2 — Technical** | Codex | 方法推导、实验严谨、可复现 |
| **R3 — Writing** | Codex | 写作、叙事、图表、组织 |
| **Researcher** | Gemini | Deep Research 文献与事实核查 |

### 并行调用规范

见 [`orchestration/multi-reviewer/SKILL.md`](orchestration/multi-reviewer/SKILL.md)。核心要点：
- 用 `Bash` 执行 `pwd` 得 `{{WORKDIR}}`
- 3 个 Codex reviewer 并行 (`run_in_background: true`)，Gemini 独立一路
- 每个 reviewer 首次返回的 `SESSION_ID` 保存（`CODEX_R1_SESSION` 等）
- 等待用 `TaskOutput({ timeout: 600000 })`，超时轮询，**禁止 Kill**
- 冲突仲裁：文献事实(Gemini) > 结构/逻辑(Claude Chair) > Reviewer 单方意见

---

## Domain Packs

**对标 ccg 的 `domains/` 系统**。根据任务自动加载对应知识包。

| 知识包 | 触发关键词 | 路径 |
|--------|-----------|------|
| **venues** | NeurIPS/ICML/ICLR/ACL/CVPR/… 会议名 | `domains/venues/<venue>.md` |
| **writing-style** | 学术英语/语态/时态/连接词/冗余 | `domains/writing-style/*.md` |
| **latex** | tex/环境/浮动体/符号/算法 | `domains/latex/*.md` |
| **rebuttal** | rebuttal/审稿回应/反驳 | `domains/rebuttal/*.md` |
| **ethics** | 伦理/利益冲突/LLM 声明 | `domains/ethics/*.md` |
| **figures** | 图/配色/TikZ/matplotlib | `domains/figures/*.md` |
| **statistics** | 显著性/p-value/置信区间 | `domains/statistics/*.md` |
| **literature** | 文献搜索/引用管理/arXiv | `domains/literature/*.md` |

### 自动路由规则

见 `~/.claude/rules/ccg-paper-routing.md`。当用户提到触发关键词时，Claude 必须先 Read 对应知识包再响应，不得凭训练数据臆造。

---

## 状态与上下文

论文任务上下文持久化在 `$HOME/.claude/ccg-paper-plan.md`：

```markdown
# 论文任务: <标题>
- 文件: <path>
- 目标会议: <venue>
- 投稿阶段: <stage>
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

---

## 命令目录（60+）

### 工作流骨架
`teach / research / outline / review / meta / plan / revise / polish / submit / status / rollback / diff`

### Writing Subskills（21）
`tighten / sharpen / clarify / hook / motivate / contribution / narrate / mathify / figurize / tablize / cite / anonymize / translate / harmonize / abbreviate / americanize / venue-adapt / page-fit / section-balance / headlinify / style-polish`

### Quality Gates（8）
`verify-novelty / verify-claims / verify-reproducibility / verify-anonymization / verify-format / verify-references / verify-style / gen-outline`

### 高级场景
`rebuttal / camera-ready / extend-journal / split-workshop / merge-papers`

### 领域速查
`venue <name>  → 打印目标会议审稿偏好`
`latex-help <topic>` / `stat-help <topic>` / `fig-help <topic>`

---

## 最佳实践

1. **先 teach 后开工**：新论文必跑 `/ccg-paper:teach` 初始化上下文
2. **research 先行**：让 Gemini Deep Research 跑一轮，降低审查盲点
3. **并行 reviewer**：3 个 Codex reviewer 并行而非串行，节省时间
4. **小步迭代**：每次只改一条 P0/P1，便于回退与 diff
5. **writing 正交**：多个 writing subskill 可组合，但一次只应用一个
6. **verify 强制**：submit 前必须过完所有 verify-*，🔴 Critical 未清零不得投稿
7. **引用必回验**：改术语/公式后用 Grep 扫全仓
8. **冲突仲裁**：Gemini 文献 > Chair 结构 > Reviewer 单方意见
