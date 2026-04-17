#!/usr/bin/env node
// ccg-paper quality gate runner
// Usage: node run_skill.js <tool> <paper.tex> [options]

const fs = require('fs');
const path = require('path');

const [,, tool, file, ...rest] = process.argv;
if (!tool) { console.error("usage: run_skill.js <tool> <paper.tex>"); process.exit(1); }

const paper = file && fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : '';
const report = { critical: [], major: [], info: [] };
const add = (lvl, msg) => report[lvl].push(msg);

function reByLine(re, flag='g') {
  const lines = paper.split('\n');
  const hits = [];
  lines.forEach((l,i) => {
    const m = l.match(new RegExp(re, flag));
    if (m) hits.push({ line: i+1, text: l.trim(), match: m });
  });
  return hits;
}

switch (tool) {
  case 'verify-anonymization': {
    const pats = [
      [/our (previous|prior|earlier) work/i, 'critical', 'self-reference phrase'],
      [/at (our|my) (institution|lab|university)/i, 'critical', 'affiliation hint'],
      [/github\.com\/[\w-]+\/[\w-]+/i, 'major', 'potentially identifying URL'],
      [/\\thanks\{/i, 'major', 'thanks block (remove for blind review)'],
      [/\\acknowl?edg/i, 'major', 'acknowledgment section (remove for blind review)'],
    ];
    pats.forEach(([re, lvl, desc]) => {
      reByLine(re, 'gi').forEach(h => add(lvl, `L${h.line} ${desc}: ${h.text}`));
    });
    break;
  }
  case 'verify-format': {
    const begins = (paper.match(/\\begin\{/g)||[]).length;
    const ends = (paper.match(/\\end\{/g)||[]).length;
    if (begins !== ends) add('critical', `\\begin(${begins}) vs \\end(${ends}) mismatch`);
    const labels = new Set((paper.match(/\\label\{([^}]+)\}/g)||[]).map(s=>s.slice(7,-1)));
    const refs = new Set((paper.match(/\\(?:eq)?ref\{([^}]+)\}/g)||[]).map(s=>s.replace(/.*\{|\}/g,'')));
    for (const r of refs) if (!labels.has(r)) add('major', `ref{${r}} has no matching label`);
    for (const l of labels) if (!refs.has(l)) add('info', `label{${l}} unused`);
    break;
  }
  case 'verify-references': {
    const bib = rest[0] || file.replace(/\.tex$/, '.bib');
    if (!fs.existsSync(bib)) { add('major', `bib file not found: ${bib}`); break; }
    const src = fs.readFileSync(bib, 'utf8');
    const keys = (src.match(/^@\w+\{([^,]+),/gm)||[]).map(s=>s.replace(/.*\{|,/g,''));
    const dup = keys.filter((k,i)=>keys.indexOf(k)!==i);
    dup.forEach(k => add('major', `duplicate bib key: ${k}`));
    const cites = new Set();
    (paper.match(/\\cite[a-z]*\{([^}]+)\}/g)||[]).forEach(c => {
      c.match(/\{([^}]+)\}/)[1].split(',').forEach(k => cites.add(k.trim()));
    });
    const keyset = new Set(keys);
    for (const c of cites) if (!keyset.has(c)) add('critical', `cite{${c}} missing in bib`);
    for (const k of keys) if (!cites.has(k)) add('info', `bib key ${k} never cited`);
    break;
  }
  case 'verify-claims':
  case 'verify-novelty':
  case 'verify-reproducibility':
    add('info', `${tool}: static scan only. Use Codex/Gemini reviewer for content-level audit.`);
    break;
  default:
    console.error(`unknown tool: ${tool}`); process.exit(2);
}

const fmt = (lvl, icon) => report[lvl].length
  ? `\n${icon} ${lvl.toUpperCase()} (${report[lvl].length}):\n` + report[lvl].map(m=>`  - ${m}`).join('\n')
  : '';
console.log(`# ${tool} report`);
console.log(fmt('critical','🔴'));
console.log(fmt('major','🟡'));
console.log(fmt('info','🟢'));
if (!report.critical.length && !report.major.length) console.log('\n✓ no critical/major issues.');
process.exit(report.critical.length ? 1 : 0);
