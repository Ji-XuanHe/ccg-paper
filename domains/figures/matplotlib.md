# matplotlib for Papers

- `plt.rcParams.update({'font.size': 9, 'font.family': 'serif'})` to match LaTeX
- Save as PDF: `plt.savefig('fig.pdf', bbox_inches='tight')`
- Use `tight_layout()` to avoid clipping
- `fig.set_size_inches(3.5, 2.5)` for column-width figure
- Label every axis (with units); grid only if it helps reading
