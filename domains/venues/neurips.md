# NeurIPS — Reviewer Preferences

- **Format**: 9 pages main + unlimited references/appendix. Double blind. NeurIPS style file (2024+ uses `neurips_2024.sty`).
- **Scoring**: Soundness / Presentation / Contribution (1-4) + Overall (1-10).
- **What gets accepted**:
  - Strong empirical rigor (error bars, >3 seeds, proper baselines)
  - Novel but well-positioned (not incremental)
  - Honest limitations section (required)
- **Common rejects**:
  - Cherry-picked results / missing std
  - Unfair baselines / no ablation
  - Overclaiming in abstract
- **Rebuttal**: 6000 chars, 1 week. Reviewers update scores.
- **Ethics**: Broader Impact section required. Datasheet / Model Card encouraged.
- **Reproducibility checklist**: Mandatory — filled during submission.

## Reviewer reading pattern
Abstract → Intro last paragraph (contributions) → Figures/Tables → Method skim → Experiments tables → Limitations.

## Unique asks
- "Why does this work?" — mechanistic understanding preferred over benchmark chasing
- Theorems should have intuition paragraphs
- Compute disclosure (hours / GPU type) required
