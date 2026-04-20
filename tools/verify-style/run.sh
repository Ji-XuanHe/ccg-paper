#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# verify-style 关卡执行脚本

set -euo pipefail

FILE="${1:?Usage: verify-style <paper.tex|paper.md>}"

# 检查 agent-style 是否安装
if ! command -v agent-style &>/dev/null; then
  echo "❌ agent-style not installed"
  echo ""
  echo "Install with:"
  echo "  pip install agent-style"
  echo "  # or"
  echo "  npm install -g agent-style"
  exit 1
fi

# 检查文件是否存在
if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

echo "Running style audit on $FILE..."
echo ""

# 执行审计（只检测机械规则，语义规则需要 LLM）
RESULT=$(agent-style review --mechanical-only --audit-only "$FILE" 2>&1) || {
  echo "❌ agent-style review failed"
  echo "$RESULT"
  exit 1
}

# 解析 JSON 输出
CRITICAL=$(echo "$RESULT" | jq -r '[.rules[] | select(.severity == "critical") | .violations] | add // 0' 2>/dev/null || echo "0")
HIGH=$(echo "$RESULT" | jq -r '[.rules[] | select(.severity == "high") | .violations] | add // 0' 2>/dev/null || echo "0")
MEDIUM=$(echo "$RESULT" | jq -r '[.rules[] | select(.severity == "medium") | .violations] | add // 0' 2>/dev/null || echo "0")
LOW=$(echo "$RESULT" | jq -r '[.rules[] | select(.severity == "low") | .violations] | add // 0' 2>/dev/null || echo "0")

# 提取 Critical 和 High 违规详情
CRITICAL_DETAILS=$(echo "$RESULT" | jq -r '.rules[] | select(.severity == "critical" and .violations > 0) | "  \(.id) (\(.name)): \(.violations)"' 2>/dev/null || echo "")
HIGH_DETAILS=$(echo "$RESULT" | jq -r '.rules[] | select(.severity == "high" and .violations > 0) | "  \(.id) (\(.name)): \(.violations)"' 2>/dev/null || echo "")

# 输出报告
echo "Style Audit (agent-style v0.2.0)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$CRITICAL" -gt 0 ]; then
  echo "🔴 Critical: $CRITICAL violations"
  echo "$CRITICAL_DETAILS"
else
  echo "✅ Critical: 0 violations"
fi

if [ "$HIGH" -gt 0 ]; then
  echo "🟡 High: $HIGH violations"
  echo "$HIGH_DETAILS"
else
  echo "✅ High: 0 violations"
fi

echo "🟢 Medium: $MEDIUM violations"
echo "🟢 Low: $LOW violations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 判断是否通过
if [ "$CRITICAL" -gt 0 ]; then
  echo "Status: ❌ BLOCKED ($CRITICAL Critical)"
  echo ""
  echo "Recommendation: Run /style-review $FILE to generate polished draft"
  exit 1
elif [ "$HIGH" -gt 0 ]; then
  echo "Status: ⚠️  WARNING ($HIGH High)"
  echo ""
  echo "Recommendation: Consider running /style-review $FILE"
  exit 0
else
  echo "Status: ✅ PASS"
  exit 0
fi
