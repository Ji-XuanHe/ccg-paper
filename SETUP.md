# CCG-Paper 新手完全配置指南

> ⏱️ **预计完成时间**：15–30 分钟（取决于网络速度）
> 🎯 **目标**：从零配置好 Claude Code + Codex + Gemini 三模型协作系统

---

## 目录

- [第一步：安装 Claude Code](#第一步安装-claude-code)
- [第二步：安装 Codex MCP](#第二步安装-codex-mcp)
- [第三步：安装 Gemini CLI](#第三步安装-gemini-cli)
- [第四步：安装 Node.js（质量关卡需要）](#第四步安装-nodejs质量关卡需要)
- [第五步：安装 LaTeX 工具链](#第五步安装-latex-工具链)
- [第六步：克隆 CCG-Paper 到本地](#第六步克隆-ccg-paper-到本地)
- [第七步：配置自动路由规则（可选但推荐）](#第七步配置自动路由规则可选但推荐)
- [第八步：一键验证安装](#第八步一键验证安装)
- [常见问题排查](#常见问题排查)
- [快速检查清单](#快速检查清单)

---

## 第一步：安装 Claude Code

Claude Code 是整个系统的编排核心，必须首先安装。

### macOS

```bash
# 方法一：Homebrew（推荐）
brew install anthropic/claude-code/claude-code

# 方法二：npm 全局安装
npm install -g @anthropic-ai/claude-code

# 方法三：直接下载
# 访问 https://github.com/anthropics/claude-code/releases/latest
# 下载对应平台的二进制文件
```

### Linux (Ubuntu/Debian)

```bash
# Snap
sudo snap install claude-code --classic

# 或下载 .deb 包
curl -fsSL https://downloads.anthropic.com/claude-code/linux/install.sh | sh
```

### 验证安装

```bash
claude --version
# 应该看到类似：Claude Code v2.x.x
```

### 首次登录

```bash
claude auth login
# 浏览器会自动打开，按提示完成登录授权
```

---

## 第二步：安装 Codex MCP

Codex 负责 Reviewer × 3（创新性 / 技术 / 写作）角色，是修改执行的主力。

### 方式一：Codex CLI（推荐）

```bash
# 安装 codex CLI
npm install -g @anthropic-ai/codex

# 验证
codex --version
```

### 方式二：MCP 服务器模式

如果你已经有 Codex API key，可以配置为 MCP 服务器：

1. 在 Claude Code 中启用 MCP：
```bash
# 编辑 ~/.claude/settings.json 添加：
{
  "mcpServers": {
    "codex": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/codex-mcp", "serve"],
      "env": {
        "ANTHROPIC_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

2. 或者使用环境变量：
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

### 验证

```bash
# 如果用 CLI 方式
codex --version

# 如果用 MCP 方式，在 Claude Code 里运行
/mcp
# 应该能看到 codex 在列表中
```

### 获取 API Key

1. 访问 [console.anthropic.com](https://console.anthropic.com)
2. API Keys → Create Key
3. 复制并妥善保存（不要泄露！）

---

## 第三步：安装 Gemini CLI

Gemini 负责 Deep Research（文献调研、SOTA 核查、事实核验）。

### 安装

```bash
# npm
npm install -g @google/gemini-cli

# 或使用 pip
pip install google-gemini

# 验证
gemini --version
```

### 配置 API Key

```bash
gemini auth
# 或设置环境变量
export GEMINI_API_KEY="your-gemini-api-key-here"
```

获取 Key：[ai.google.dev](https://ai.google.dev) → API Keys

### 备选：如果不用 Gemini

**完全可用**。`/ccg-paper:research` 会降级为 Claude 自己查文献，其他流程不受影响。

---

## 第四步：安装 Node.js（质量关卡需要）

`tools/run_skill.js` 需要 Node.js ≥ 18。

### macOS

```bash
# Homebrew（推荐）
brew install node

# 或使用 nvm（管理多版本）
brew install nvm
nvm install 20
nvm use 20
```

### Linux

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 或用 nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
```

### 验证

```bash
node --version
# v20.x.x 或更高
npm --version
# 9.x.x 或更高
```

---

## 第五步：安装 LaTeX 工具链

`verify-format` 需要 LaTeX 来编译检查。

### macOS

```bash
# MacTeX（完整版，约 5GB）
brew install --cask mactex

# 或 BasicTeX（精简版，约 100MB，够用）
brew install --cask basictex
```

### Linux

```bash
# Ubuntu/Debian
sudo apt install texlive-full

# 或精简版
sudo apt install texlive-latex-base texlive-latex-extra texlive-bibtex-extra biber
```

### 验证

```bash
pdflatex --version
biber --version
```

> ⚠️ 如果不装 LaTeX，`verify-format` 只能做有限的静态检查，不影响其他功能。

---

## 第六步：克隆 CCG-Paper 到本地

### 方式一：直接克隆（推荐）

```bash
# 克隆到 Claude Code Skills 目录
git clone git@github.com:xuanNULL/ccg-paper.git ~/.claude/skills/ccg-paper
```

### 方式二：如果你只想用，不想 git 管理

```bash
# 下载 ZIP
curl -L https://github.com/xuanNULL/ccg-paper/archive/refs/heads/main.zip -o ccg-paper.zip
unzip ccg-paper.zip
mv ccg-paper-main ~/.claude/skills/ccg-paper
rm ccg-paper.zip
```

### 方式三：一键脚本（见仓库根目录 `setup.sh`）

```bash
# 在任意目录运行：
curl -fsSL https://raw.githubusercontent.com/xuanNULL/ccg-paper/main/setup.sh | bash
```

### 验证克隆成功

```bash
ls ~/.claude/skills/ccg-paper/
# 应该看到：SKILL.md README.md SETUP.md tools/ writing/ domains/ ...
```

---

## 第七步：配置自动路由规则（可选但推荐）

自动路由让 Claude 在你提到特定关键词时**自动加载对应知识包**，无需手动指定。

### 复制路由规则文件

```bash
# 如果仓库里有 rules/ 目录
cp ~/.claude/skills/ccg-paper/rules/ccg-paper-routing.md ~/.claude/rules/ccg-paper-routing.md

# 或手动创建
mkdir -p ~/.claude/rules
# 然后复制下面「路由规则内容」到该文件
```

### 路由规则内容（ccg-paper-routing.md）

```markdown
# CCG-Paper Domain Knowledge — Auto-routing Rules

When the user's paper-related request matches trigger keywords below,
automatically READ the corresponding knowledge file BEFORE responding.
Knowledge lives at `/Users/ji-xuanhe/.claude/skills/ccg-paper/domains/`.

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

## Statistics (`domains/statistics/`)
| Trigger | File |
|---------|------|
| 显著性 / p-value / t-test | `significance.md` |
| 置信区间 / CI / bootstrap | `confidence-intervals.md` |
| p-hacking / pre-register | `p-hacking.md` |
| 消融 / ablation | `ablation.md` |

## Routing Rules
1. 触发词 fuzzy 匹配 — 匹配意图而非字符串
2. 多重匹配 — 跨领域请求读多个
3. 会话内不重复读同一文件
4. 知识文件为准，冲突时文件胜过训练数据
```

---

## 第八步：一键验证安装

运行仓库根的 `setup.sh` 脚本，或手动执行以下命令：

```bash
cd ~/.claude/skills/ccg-paper

# 1. 验证文件完整
echo "=== 文件结构检查 ==="
ls -la
echo ""

# 2. 验证所有子目录
echo "=== 子目录检查 ==="
for dir in tools writing domains orchestration prompts; do
  count=$(find $dir -name "*.md" | wc -l)
  echo "$dir: $count 个文件"
done
echo ""

# 3. 验证 Node.js
echo "=== Node.js 检查 ==="
node --version && echo "✓ Node.js OK"
echo ""

# 4. 验证 LaTeX
echo "=== LaTeX 检查 ==="
if command -v pdflatex &> /dev/null; then
  pdflatex --version | head -1
  echo "✓ LaTeX OK"
else
  echo "⚠ LaTeX 未安装（可选，verify-format 功能受限）"
fi
echo ""

# 5. 运行质量关卡测试
echo "=== 质量关卡测试 ==="
echo "This is a test for anonymization." > /tmp/test_paper.tex
node tools/run_skill.js verify-anonymization /tmp/test_paper.tex
node tools/run_skill.js verify-format /tmp/test_paper.tex
echo ""

echo "=== 验证完成 ==="
echo "现在可以在 Claude Code 中运行 /ccg-paper:teach 开始使用"
```

---

## 常见问题排查

### Q1: `claude: command not found`

```bash
# 检查安装位置
which claude

# 如果没在 PATH，添加到 shell 配置
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Q2: Codex 连接失败

```bash
# 检查 API key 是否设置
echo $ANTHROPIC_API_KEY  # 应该显示 key

# 如果为空，重新设置
export ANTHROPIC_API_KEY="sk-ant-xxxx"
```

### Q3: Node.js 版本太旧

```bash
# 检查版本
node --version

# 使用 nvm 切换到新版
nvm install 20
nvm use 20
nvm alias default 20
```

### Q4: LaTeX 编译失败（verify-format 报错）

```bash
# macOS 用 BasicTex 需要手动加 PATH
echo 'export PATH="/usr/local/texlive/basictex/bin/universal-darwin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 更新包索引
sudo tlmgr update --self
```

### Q5: 克隆仓库失败（SSH key 问题）

```bash
# 检查是否有 SSH key
ls ~/.ssh/id_rsa.pub

# 如果没有，生成一个
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 复制公钥到 GitHub
cat ~/.ssh/id_rsa.pub | pbcopy
# 然后访问 https://github.com/settings/keys 添加

# 再试
git clone git@github.com:xuanNULL/ccg-paper.git ~/.claude/skills/ccg-paper
```

### Q6: Gemini API 认证失败

```bash
# 设置 key
export GEMINI_API_KEY="your-key"

# 或用 gemini auth 交互式登录
gemini auth
```

### Q7: Claude Code 找不到 skill

```bash
# 确认 skill 文件存在
ls ~/.claude/skills/ccg-paper/SKILL.md

# 检查 Claude Code 配置
claude config list
```

---

## 快速检查清单

完成所有步骤后，运行以下检查：

```bash
# 一键检查所有依赖
bash ~/.claude/skills/ccg-paper/check_deps.sh

# 预期输出（全部 ✓）：
# ✓ Claude Code: v2.x.x
# ✓ Codex: available
# ✓ Gemini: available（或 "not configured"）
# ✓ Node.js: v20.x.x
# ✓ LaTeX: pdflatex 可用
# ✓ CCG-Paper: 74 个文件已安装
# ✓ 路由规则: 已配置
```

### 手动检查项

| 组件 | 检查命令 | 预期结果 |
|------|---------|---------|
| Claude Code | `claude --version` | v2.x.x |
| Codex | `codex --version` 或 MCP 列表中有 codex | 版本号 |
| Gemini | `gemini --version` | 版本号 |
| Node.js | `node --version` | ≥ v18 |
| LaTeX | `pdflatex --version` | TeX Live xxx |
| CCG-Paper | `ls ~/.claude/skills/ccg-paper/SKILL.md` | 文件存在 |
| 路由规则 | `ls ~/.claude/rules/ccg-paper-routing.md` | 文件存在 |

---

## 下一步

配置完成后，查看 [README.md](./README.md) 的「快速上手」部分，开始你的第一篇论文！

推荐顺序：
1. `/ccg-paper:teach` — 初始化论文上下文
2. `/ccg-paper:outline` — 生成论文骨架
3. `/ccg-paper:research <topic>` — 文献调研
4. `/ccg-paper:review` — 三模型审稿

有问题？[提 Issue](https://github.com/xuanNULL/ccg-paper/issues)
