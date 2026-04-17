# LaTeX Environments

- **figure**: `\begin{figure}[t]` preferred (top of page). Use `[!t]` to force.
- **table**: Use `booktabs` (`\toprule / \midrule / \bottomrule`). Avoid vertical rules.
- **algorithm**: `algorithm2e` or `algorithmic`. Caption above.
- **equation**: `equation` for numbered; `align` for multi-line; `gather` for centered stack.
- **proof**: `\begin{proof} ... \end{proof}` (amsthm). Ends with QED.

Never use `\\` for line break outside tabular/align.
