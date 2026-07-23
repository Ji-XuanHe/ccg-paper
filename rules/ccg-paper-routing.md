# CCG-Paper Domain Knowledge — Auto-routing Rules

When the user's paper-related request matches trigger keywords below, automatically READ the corresponding knowledge file BEFORE responding. Knowledge lives at `/Users/ji-xuanhe/.claude/skills/ccg-paper/domains/`.

**IMPORTANT**: Read the file FIRST, then respond. Do NOT fabricate from training data.

## Venues (`domains/venues/`)

| Trigger | File |
|---------|------|
| NeurIPS | `domains/venues/neurips.md` |
| ICML | `domains/venues/icml.md` |
| ICLR / OpenReview | `domains/venues/iclr.md` |
| ACL / NAACL | `domains/venues/acl.md` |
| EMNLP | `domains/venues/emnlp.md` |
| CVPR / ICCV / ECCV | `domains/venues/cvpr.md` |
| AAAI | `domains/venues/aaai.md` |
| KDD | `domains/venues/kdd.md` |
| TPAMI / TMLR / journal extension | `domains/venues/tpami.md` |

## Writing Style (`domains/writing-style/`)

| Trigger | File |
|---------|------|
| 学术英语 / hedging / passive voice | `academic-english.md` |
| 时态 / tense | `tense.md` |
| 连接词 / connectors / transitions | `connectors.md` |
| 冗余 / wordy / redundancy | `redundancy.md` |

## LaTeX (`domains/latex/`)

| Trigger | File |
|---------|------|
| LaTeX env / figure/table env | `environments.md` |
| 公式 / math / equation / symbols | `math.md` |
| 图 / figure / subfigure | `figures.md` |
| 表 / table / booktabs | `tables.md` |
| 算法 / algorithm / pseudocode | `algorithms.md` |

## Rebuttal (`domains/rebuttal/`)

| Trigger | File |
|---------|------|
| rebuttal 结构 | `structure.md` |
| rebuttal 语气 / 反驳措辞 | `tone.md` |
| 抢救 / salvage / weak reviewer | `salvage-strategies.md` |
| 字数限制 / char limit | `length-limits.md` |

## Ethics (`domains/ethics/`)

| Trigger | File |
|---------|------|
| COI / conflict of interest | `conflict-of-interest.md` |
| LLM 声明 / ChatGPT disclosure | `llm-usage-declaration.md` |
| 数据伦理 / IRB / consent | `data-ethics.md` |

## Figures (`domains/figures/`)

| Trigger | File |
|---------|------|
| 配色 / colormap | `colormap.md` |
| TikZ / pgfplots | `tikz.md` |
| matplotlib | `matplotlib.md` |
| 色盲 / accessibility | `accessibility.md` |

## Statistics (`domains/statistics/`)

| Trigger | File |
|---------|------|
| 显著性 / p-value / t-test | `significance.md` |
| 置信区间 / CI / bootstrap | `confidence-intervals.md` |
| p-hacking / pre-register | `p-hacking.md` |
| 消融 / ablation | `ablation.md` |

## Literature (`domains/literature/`)

| Trigger | File |
|---------|------|
| 文献搜索 / Google Scholar | `search.md` |
| 引用管理 / BibTeX | `citation-management.md` |
| arXiv workflow | `arxiv-workflow.md` |
| Semantic Scholar | `semanticscholar.md` |

## Routing Rules

1. 触发词 fuzzy 匹配 — 匹配意图而非字符串
2. 多重匹配 — 跨领域请求读多个
3. 会话内不重复读同一文件
4. 知识文件为准，冲突时文件胜过训练数据
