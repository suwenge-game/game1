#!/bin/bash

# 简单GitHub部署脚本 - 处理网络问题
# 作者: AI Assistant

# 硬编码的GitHub账号信息
GITHUB_USERNAME="suwenge-game"
GITHUB_PASSWORD="zhangzhilove0314"

echo "============================================================"
echo "🚀 简单GitHub部署脚本"
echo "============================================================"
echo "🔑 GitHub账号: $GITHUB_USERNAME"
echo "📅 执行时间: $(date)"
echo "💻 系统信息: $(uname -a)"
echo "📁 当前目录: $PWD"
echo "🔧 Git版本: $(git --version)"
echo "============================================================"
echo ""

# 使用当前文件夹名作为仓库名
REPO_NAME=$(basename "$PWD")
echo "📦 自动使用当前文件夹名作为仓库名: $REPO_NAME"

read -p "📄 仓库描述 (可选): " REPO_DESCRIPTION
read -p "🔒 是否创建私有仓库? (y/N): " IS_PRIVATE

echo ""

# 检查网络连接
echo "🔍 检查网络连接..."
echo "执行命令: ping -c 1 github.com"
if ping -c 1 github.com; then
    echo "✅ 网络连接正常"
else
    echo "❌ 无法连接到GitHub，请检查网络连接"
    exit 1
fi

# 初始化Git仓库
echo "📁 初始化本地Git仓库..."
echo "检查当前目录: $PWD"
echo "检查.git目录是否存在..."
if [ ! -d ".git" ]; then
    echo "执行命令: git init"
    git init
    echo "✅ Git仓库初始化成功"
else
    echo "ℹ️  已经是Git仓库，跳过初始化"
fi

# 创建README.md（如果不存在）
if [ ! -f "README.md" ]; then
    echo "📝 创建README.md文件..."
    cat > README.md << EOF
# $REPO_NAME

$REPO_DESCRIPTION

## 项目描述

这是一个通过自动化脚本部署到GitHub的项目。

## 部署信息

- 部署时间: $(date '+%Y-%m-%d %H:%M:%S')
- 部署脚本: simple_git_deploy.sh
- GitHub仓库: https://github.com/$GITHUB_USERNAME/$REPO_NAME

## 使用方法

1. 克隆仓库
2. 打开项目文件
3. 开始使用

## 许可证

请根据项目需要添加适当的许可证信息。
EOF
    echo "✅ README.md创建成功"
fi

# 添加文件到Git
echo "📝 添加文件到Git..."
echo "执行命令: git add ."
git add .
echo "检查暂存区状态:"
git status --porcelain
echo "✅ 文件已添加到暂存区"

# 创建提交
echo "💾 创建提交..."
echo "执行命令: git commit -m \"Initial commit: Auto-deployed project\""
git commit -m "Initial commit: Auto-deployed project"
echo "检查提交状态:"
git log --oneline -1
echo "✅ 初始提交创建成功"

# 配置Git凭据
echo "🔧 配置Git凭据..."
echo "执行命令: git config --global credential.helper store"
git config --global credential.helper store
echo "创建凭据文件: ~/.git-credentials"
echo "https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com" > ~/.git-credentials
echo "检查凭据文件内容:"
cat ~/.git-credentials
echo "✅ Git凭据已配置"

# 添加远程仓库
echo "🔗 添加远程仓库..."
REMOTE_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "远程仓库URL: $REMOTE_URL"

# 检查是否已经有远程仓库
echo "检查现有远程仓库..."
if git remote get-url origin >/dev/null 2>&1; then
    echo "ℹ️  远程仓库已存在，更新URL"
    echo "执行命令: git remote set-url origin \"$REMOTE_URL\""
    git remote set-url origin "$REMOTE_URL"
else
    echo "执行命令: git remote add origin \"$REMOTE_URL\""
    git remote add origin "$REMOTE_URL"
fi

echo "检查远程仓库配置:"
git remote -v
echo "✅ 远程仓库已设置"

# 显示手动创建指导
echo ""
echo "🏗️  请先手动创建GitHub仓库:"
echo "=================================================="
echo "1. 访问: https://github.com/new"
echo "2. 填写仓库信息:"
echo "   - Repository name: $REPO_NAME"
echo "   - Description: $REPO_DESCRIPTION"
echo "   - Visibility: $([ "$IS_PRIVATE" = "y" ] || [ "$IS_PRIVATE" = "Y" ] && echo "Private" || echo "Public")"
echo "3. 不要勾选任何选项"
echo "4. 点击 'Create repository'"
echo "=================================================="
echo ""

read -p "按回车键继续，确认您已经创建了仓库..."

# 推送代码
echo "⬆️  推送代码到GitHub..."
echo "💡 提示: 系统会要求您输入GitHub用户名和密码"
echo "   用户名: $GITHUB_USERNAME"
echo "   密码: $GITHUB_PASSWORD"
echo ""

# 设置环境变量
export GIT_TERMINAL_PROMPT=0
echo "设置环境变量: GIT_TERMINAL_PROMPT=0"

# 检查当前分支
echo "检查当前分支:"
git branch
echo "检查远程分支:"
git branch -r

# 推送代码
echo "执行命令: git push -u origin main"
if git push -u origin main; then
    echo "✅ 代码推送成功!"
    
    # 启用GitHub Pages指导
    echo ""
    echo "🌐 手动启用GitHub Pages:"
    echo "=================================================="
    echo "1. 访问: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/pages"
    echo "2. 在 'Source' 下选择 'Deploy from a branch'"
    echo "3. 选择分支: main"
    echo "4. 选择文件夹: / (root)"
    echo "5. 点击 'Save'"
    echo "=================================================="

    # 完成
    echo ""
    echo "============================================================"
    echo "🎉 部署完成!"
    echo "============================================================"
    echo "📦 仓库地址: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
    echo "🌍 网站地址: https://$GITHUB_USERNAME.github.io/$REPO_NAME"
    echo "============================================================"
else
    echo "❌ 推送失败"
    echo ""
    echo "🔍 详细错误信息:"
    echo "退出码: $?"
    echo ""
    echo "🔧 常见问题排查:"
    echo "   1. 确认GitHub仓库已创建"
    echo "   2. 检查用户名和密码是否正确"
    echo "   3. 检查网络连接"
    echo "   4. 尝试手动推送: git push -u origin main"
    echo ""
    echo "💡 如果问题持续，请尝试:"
    echo "   1. 使用GitHub CLI: brew install gh"
    echo "   2. 使用Personal Access Token替代密码"
    echo "   3. 检查GitHub账户设置"
    echo ""
    echo "🔍 调试信息:"
    echo "当前目录: $PWD"
    echo "仓库名称: $REPO_NAME"
    echo "远程URL: $REMOTE_URL"
    echo "Git配置:"
    git config --list | grep -E "(user|credential|remote)"
    exit 1
fi
