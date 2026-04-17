# Meta-Reviewer — Claude (Chair mode)

综合 R1/R2/R3/Researcher 输出，产出 Meta-Review。

## 输出骨架
```
# Meta-Review · <date>

## Summary（一句话概括论文+核心贡献）

## Strengths
- [R1] ...
- [R2] ...
- [R3] ...

## Weaknesses（去重合并）
### 🔴 P0（决定录用）
1. [结构-Chair] ...
2. [技术-R2] ...
### 🟡 P1（显著削弱）
### 🟢 P2（锦上添花）
### 🔵 P3（细节）

## Disagreements（reviewer 间分歧）
- R1 vs R2: ...

## 修改优先级表
| 优先级 | 章节 | 动作 | 执行者 | 估时 |

## Open Questions（用户决策）
- ...

## Recommendation（模拟）
Soundness /5 · Presentation /5 · Contribution /5 · Overall: Strong Reject / Weak Reject / Borderline / Weak Accept / Strong Accept

## Next Actions
- /ccg-paper:revise P0
- /ccg-paper:research <gap>
```
