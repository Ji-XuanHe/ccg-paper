#!/usr/bin/env bash
#===============================================================================
# CCG-Paper 一键安装脚本
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/xuanNULL/ccg-paper/main/setup.sh | bash
#   # 或下载后本地运行:
#   bash setup.sh
#
# 兼容: macOS, Linux (Ubuntu/Debian)
#===============================================================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

ok()  { echo -e "${GREEN}✓${NC} $1"; }
info(){ echo -e "${BLUE}ℹ${NC} $1"; }
warn(){ echo -e "${YELLOW}⚠${NC} $1"; }
fail(){ echo -e "${RED}✗${NC} $1"; }
step(){ echo -e "${CYAN}→${NC} $1"; }

# 打印分隔线
hr() { echo "────────────────────────────────────────────"; }

# 检测操作系统
detect_os() {
  case "$(uname -s)" in
    Darwin)  echo "macOS";;
    Linux)
      if [ -f /etc/debian_version ]; then echo "Debian/Ubuntu"
      elif [ -f /etc/redhat-release ]; then echo "RedHat/CentOS"
      else echo "Linux"; fi;;
    *) echo "Unknown";;
  esac
}

# 检测是否已有 Homebrew (macOS)
has_brew() { command -v brew &> /dev/null; }
# 检测是否已有 nvm
has_nvm() { [ -d "$HOME/.nvm" ] || [ -s "$HOME/.nvm/nvm.sh" ]; }
# 检测是否已有 git
has_git() { command -v git &> /dev/null; }

#===============================================================================
# 第一阶段：检测已有环境
#===============================================================================
echo ""
hr
echo "  CCG-Paper 一键安装"
echo "  检测现有环境..."
hr

OS=$(detect_os)
info "操作系统: $OS"

# 检查各组件
check_claude()  { command -v claude &> /dev/null && claude --version 2>/dev/null | head -1; }
check_codex()    { command -v codex &> /dev/null && codex --version 2>/dev/null | head -1; }
check_gemini()   { command -v gemini &> /dev/null && gemini --version 2>/dev/null | head -1; }
check_node()     { command -v node &> /dev/null && node --version; }
check_npm()      { command -v npm &> /dev/null && npm --version; }
check_pdflatex() { command -v pdflatex &> /dev/null && pdflatex --version 2>/dev/null | head -1; }
check_biber()    { command -v biber &> /dev/null && biber --version 2>/dev/null | head -1; }

declare -A status
status[claude]="未安装"
status[codex]="未安装"
status[gemini]="未安装"
status[node]="未安装"
status[latex]="未安装"
status[skill]="未安装"

[ -n "$(check_claude)" ]   && status[claude]="已安装 $(check_claude)"
[ -n "$(check_codex)" ]     && status[codex]="已安装 $(check_codex)"
[ -n "$(check_gemini)" ]    && status[gemini]="已安装 $(check_gemini)"
[ -n "$(check_node)" ]       && status[node]="已安装 $(check_node)"
[ -n "$(check_pdflatex)" ]  && status[latex]="已安装 $(check_pdflatex)"
[ -d "$HOME/.claude/skills/ccg-paper" ] && status[skill]="已安装 ✓"

echo ""
printf "  %-12s %s\n" "Claude Code" "${status[claude]}"
printf "  %-12s %s\n" "Codex"       "${status[codex]}"
printf "  %-12s %s\n" "Gemini"      "${status[gemini]}"
printf "  %-12s %s\n" "Node.js"     "${status[node]}"
printf "  %-12s %s\n" "LaTeX"       "${status[latex]}"
printf "  %-12s %s\n" "CCG-Paper"   "${status[skill]}"
echo ""

#===============================================================================
# 第二阶段：安装缺失组件
#===============================================================================
install_needed=false

# --- Git ---
if ! has_git; then
  install_needed=true
  hr
  step "安装 Git..."
  if [ "$OS" = "macOS" ]; then
    if has_brew; then brew install git;
    else xcode-select --install; fi
  elif [ "$OS" = "Debian/Ubuntu" ]; then
    sudo apt-get update && sudo apt-get install -y git
  fi
  ok "Git 已安装: $(git --version)"
fi

# --- Node.js ---
if [ -z "${status[node]}" ] || [ "${status[node]}" = "未安装" ]; then
  install_needed=true
  hr
  step "安装 Node.js 20..."
  if [ "$OS" = "macOS" ]; then
    if has_brew; then
      brew install node@20
    else
      warn "建议先安装 Homebrew: https://brew.sh"
      # 尝试下载安装
      curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0.pkg -o /tmp/node.pkg && \
        sudo installer -pkg /tmp/node.pkg -target /
    fi
  elif [ "$OS" = "Debian/Ubuntu" ]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && \
      sudo apt-get install -y nodejs
  fi
  ok "Node.js 已安装: $(node --version)"
fi

# --- LaTeX ---
if [ "${status[latex]}" = "未安装" ]; then
  install_needed=true
  hr
  step "安装 LaTeX（可选但推荐）..."
  if [ "$OS" = "macOS" ]; then
    if has_brew; then
      read -p "  MacTeX 完整版(5GB)还是 BasicTeX 精简版(100MB)? [m/b] " choice
      if [ "$choice" = "b" ] || [ "$choice" = "" ]; then
        brew install --cask basictex
        # 添加到 PATH
        TEXBIN="/Library/TeX/texbin"
        if ! grep -q "$TEXBIN" ~/.zshrc 2>/dev/null; then
          echo "export PATH=\"$TEXBIN:\$PATH\"" >> ~/.zshrc
          export PATH="$TEXBIN:$PATH"
        fi
      else
        brew install --cask mactex
      fi
      sudo tlmgr update --self 2>/dev/null || true
    else
      warn "建议先安装 Homebrew 或手动下载 MacTeX"
    fi
  elif [ "$OS" = "Debian/Ubuntu" ]; then
    sudo apt-get install -y texlive-latex-base texlive-latex-extra \
      texlive-bibtex-extra biber
  fi
  if command -v pdflatex &> /dev/null; then
    ok "LaTeX 已安装"
  else
    warn "LaTeX 安装失败，但不影响其他功能"
  fi
fi

# --- Claude Code ---
if [ "${status[claude]}" = "未安装" ]; then
  install_needed=true
  hr
  step "安装 Claude Code..."
  if [ "$OS" = "macOS" ]; then
    if has_brew; then
      brew install anthropic/claude-code/claude-code
    else
      warn "建议安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://brew.sh)\""
      echo "  或手动下载: https://github.com/anthropics/claude-code/releases"
    fi
  elif [ "$OS" = "Debian/Ubuntu" ]; then
    curl -fsSL https://downloads.anthropic.com/claude-code/linux/install.sh | sh
  fi
  if command -v claude &> /dev/null; then
    ok "Claude Code 已安装: $(claude --version | head -1)"
  else
    warn "Claude Code 安装失败，请手动安装"
  fi
fi

# --- Codex ---
if [ "${status[codex]}" = "未安装" ]; then
  install_needed=true
  hr
  step "安装 Codex..."
  if command -v npm &> /dev/null; then
    npm install -g @anthropic-ai/codex 2>/dev/null || true
  fi
  if command -v codex &> /dev/null; then
    ok "Codex 已安装: $(codex --version)"
  else
    info "Codex 可通过 npm install -g @anthropic-ai/codex 安装，或配置 MCP 模式"
  fi
fi

# --- Gemini ---
if [ "${status[gemini]}" = "未安装" ]; then
  hr
  info "Gemini CLI 未安装（可选）"
  info "  npm install -g @google/gemini-cli"
  info "  或访问 https://ai.google.dev 获取 API key 后配置环境变量"
fi

#===============================================================================
# 第三阶段：克隆 CCG-Paper
#===============================================================================
hr
step "克隆 CCG-Paper..."

SKILL_DIR="$HOME/.claude/skills/ccg-paper"
SKILL_DIR_ESC=$(echo "$SKILL_DIR" | sed 's/ /\\ /g')

if [ -d "$SKILL_DIR/.git" ]; then
  info "CCG-Paper 已存在，拉取最新..."
  cd "$SKILL_DIR" && git pull origin main
  ok "已更新到最新版本"
elif [ -d "$SKILL_DIR" ]; then
  warn "目录已存在但不是 git 仓库，备份后重新克隆..."
  mv "$SKILL_DIR" "$SKILL_DIR.bak.$(date +%s)"
fi

if [ ! -d "$SKILL_DIR/.git" ]; then
  mkdir -p "$(dirname "$SKILL_DIR")"
  git clone git@github.com:xuanNULL/ccg-paper.git "$SKILL_DIR"
  ok "克隆完成"
fi

FILE_COUNT=$(find "$SKILL_DIR" -name "*.md" -o -name "*.js" | grep -v ".git" | wc -l | tr -d ' ')
ok "已安装 $FILE_COUNT 个文件"

#===============================================================================
# 第四阶段：复制路由规则（可选）
#===============================================================================
hr
step "配置自动路由规则（可选）..."

RULES_DIR="$HOME/.claude/rules"
RULES_FILE="$RULES_DIR/ccg-paper-routing.md"

mkdir -p "$RULES_DIR"

if [ -f "$SKILL_DIR/rules/ccg-paper-routing.md" ]; then
  cp "$SKILL_DIR/rules/ccg-paper-routing.md" "$RULES_FILE"
  ok "路由规则已配置: $RULES_FILE"
else
  warn "未找到路由规则文件，跳过"
fi

#===============================================================================
# 第五阶段：验证安装
#===============================================================================
hr
echo "  安装验证"
hr

all_ok=true

echo ""
step "运行测试..."

# 测试 Node.js
if node --version &>/dev/null; then
  ok "Node.js: $(node --version)"
else
  fail "Node.js 未正常工作"
  all_ok=false
fi

# 测试质量关卡
TEST_TEX="/tmp/ccg_paper_test.tex"
cat > "$TEST_TEX" << 'EOF'
\documentclass{article}
\begin{document}
Our previous work~\cite{author2023} demonstrates this.
\section{Introduction}
This paper is by authors at MIT.
\section{Results}
\begin{equation}
  E = mc^2 \label{eq}
\end{equation}
See~\ref{eq} for details.
\section{References}
\bibliographystyle{plain}
\bibliography{refs}
\end{document}
EOF

cd "$SKILL_DIR"
node tools/run_skill.js verify-anonymization "$TEST_TEX" 2>/dev/null && ok "verify-anonymization 通过" || {
  warn "verify-anonymization 运行有问题"
}
node tools/run_skill.js verify-format "$TEST_TEX" 2>/dev/null && ok "verify-format 通过" || {
  warn "verify-format 运行有问题"
}

# 检查文件完整性
EXPECTED_DIRS="tools writing domains orchestration prompts"
MISSING=""
for d in $EXPECTED_DIRS; do
  [ -d "$SKILL_DIR/$d" ] || MISSING="$MISSING $d"
done

if [ -z "$MISSING" ]; then
  ok "所有目录完整: tools writing domains orchestration prompts"
else
  fail "缺失目录:$MISSING"
  all_ok=false
fi

# 统计文件数
WRITING_COUNT=$(find "$SKILL_DIR/writing" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
TOOLS_COUNT=$(find "$SKILL_DIR/tools" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
DOMAINS_COUNT=$(find "$SKILL_DIR/domains" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

ok "Writing subskills: $WRITING_COUNT 个"
ok "Quality gates:   $TOOLS_COUNT 个"
ok "Domain packs:    $DOMAINS_COUNT 个"

#===============================================================================
# 完成
#===============================================================================
hr
echo -e "${GREEN}"
echo "  ██╗   ██╗ ██████╗ ██████╗ ████████╗███████╗██████╗  ██████╗ ███████╗"
echo "  ██║   ██║██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██╔═══██╗██╔════╝"
echo "  ██║   ██║██║   ██║██████╔╝   ██║   █████╗  ██████╔╝██║   ██║███████╗"
echo "  ╚██╗ ██╔╝██║   ██║██╔══██╗   ██║   ██╔══╝  ██╔══██╗██║   ██║╚════██║"
echo "   ╚████╔╝ ╚██████╔╝██║  ██║   ██║   ███████╗██████╔╝╚██████╔╝███████║"
echo "    ╚═══╝   ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝  ╚═════╝ ╚══════╝"
echo -e "${NC}"
hr

if [ "$all_ok" = true ]; then
  ok "安装完成！"
else
  warn "部分组件未完全配置，但 CCG-Paper 核心功能可用"
fi

echo ""
echo "  接下来："
echo ""
echo "  1. 首次使用需要登录 Claude Code："
echo "     claude auth login"
echo ""
echo "  2. 在 Claude Code 中初始化论文上下文："
echo "     /ccg-paper:teach"
echo ""
echo "  3. 查看详细配置指南："
echo "     cat ~/.claude/skills/ccg-paper/SETUP.md"
echo ""
echo "  4. 完整文档："
echo "     cat ~/.claude/skills/ccg-paper/README.md"
echo ""
echo "  常见问题见 SETUP.md 最后一节「常见问题排查」"
echo ""

# 保存安装信息到日志
LOG="$HOME/.claude/ccg-paper-install.log"
{
  echo "安装完成: $(date)"
  echo "OS: $OS"
  echo "Node: $(node --version 2>/dev/null)"
  echo "Skill: $SKILL_DIR"
  echo "File count: $FILE_COUNT"
} >> "$LOG"
info "安装日志: $LOG"
