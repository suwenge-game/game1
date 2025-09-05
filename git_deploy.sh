#!/bin/bash

# 简单GitHub部署脚本 - 使用账号密码
# 作者: AI Assistant

# 硬编码的GitHub账号信息
GITHUB_USERNAME="suwenge-game"
GITHUB_PASSWORD="zhangzhilove0314"

echo "============================================================"
echo "🚀 简单GitHub部署脚本"
echo "============================================================"
echo "🔑 GitHub账号: $GITHUB_USERNAME"
echo "🔐 使用账号密码认证"
echo ""

# 获取用户输入
read -p "📦 仓库名称: " REPO_NAME
if [ -z "$REPO_NAME" ]; then
    echo "❌ 仓库名称不能为空"
    exit 1
fi

read -p "📄 仓库描述 (可选): " REPO_DESCRIPTION
read -p "🔒 是否创建私有仓库? (y/N): " IS_PRIVATE

echo ""
echo "🏗️  需要手动创建GitHub仓库:"
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

# 初始化Git仓库
echo "📁 初始化本地Git仓库..."
if [ ! -d ".git" ]; then
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
- 部署脚本: git_deploy.sh
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
git add .
echo "✅ 文件已添加到暂存区"

# 创建提交
echo "💾 创建提交..."
git commit -m "Initial commit: Auto-deployed project"
echo "✅ 初始提交创建成功"

# 添加远程仓库
echo "🔗 添加远程仓库..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git 2>/dev/null || git remote set-url origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
echo "✅ 远程仓库已设置"

# 推送代码
echo "⬆️  推送到GitHub..."
echo "💡 提示: 系统会要求您输入GitHub用户名和密码"
echo "   用户名: $GITHUB_USERNAME"
echo "   密码: $GITHUB_PASSWORD"
echo ""

# 使用Git凭据助手
git config --global credential.helper store

# 推送代码
if git push -u origin main; then
    echo "✅ 代码推送成功"
else
    echo "❌ 推送失败"
    echo "💡 请检查:"
    echo "   1. GitHub仓库是否已创建"
    echo "   2. 用户名和密码是否正确"
    echo "   3. 网络连接是否正常"
    exit 1
fi

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
