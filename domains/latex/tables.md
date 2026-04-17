# LaTeX Tables

- Use `booktabs`: `\toprule / \midrule / \bottomrule`. Never `\hline`.
- Align numbers at decimal: `siunitx` package with `S[table-format=2.2]`
- Bold best: `\textbf{0.92}`. Underline runner-up: `\underline{0.89}`.
- Caption ABOVE table.
- `\resizebox{\linewidth}{!}{...}` for wide tables (last resort — reduces font).
- Multi-column: `\multicolumn{3}{c}{Header}` + `\cmidrule(lr){2-4}`.
