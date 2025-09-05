#!/bin/bash

# 完全自动化GitHub部署脚本 - 使用GitHub CLI
# 作者: AI Assistant

# 硬编码的GitHub账号信息
GITHUB_USERNAME="suwenge-game"
GITHUB_PASSWORD="zhangzhilove0314"

# 自动设置
REPO_NAME=$(basename "$PWD")
REPO_DESCRIPTION="Auto-deployed project from $(date '+%Y-%m-%d %H:%M:%S')"

echo "============================================================"
echo "🚀 完全自动化GitHub部署脚本"
echo "============================================================"
echo "🔑 GitHub账号: $GITHUB_USERNAME"
echo "📦 仓库名称: $REPO_NAME"
echo "📄 仓库描述: $REPO_DESCRIPTION"
echo "🔒 仓库类型: Public"
echo "📅 执行时间: $(date)"
echo "💻 系统信息: $(uname -a)"
echo "📁 当前目录: $PWD"
echo "🔧 Git版本: $(git --version)"
echo "============================================================"
echo ""

# 检查网络连接
echo "🔍 检查网络连接..."
if ping -c 1 github.com >/dev/null 2>&1; then
    echo "✅ 网络连接正常"
else
    echo "❌ 无法连接到GitHub，请检查网络连接"
    exit 1
fi

# 检查GitHub CLI
echo "🔍 检查GitHub CLI..."
if command -v gh >/dev/null 2>&1; then
    echo "✅ GitHub CLI 已安装"
    GH_VERSION=$(gh --version | head -n1)
    echo "版本: $GH_VERSION"
else
    echo "❌ GitHub CLI 未安装"
    echo "💡 正在安装GitHub CLI..."
    
    # 检测操作系统并安装
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew >/dev/null 2>&1; then
            echo "使用Homebrew安装..."
            brew install gh
        else
            echo "❌ 请先安装Homebrew或手动安装GitHub CLI"
            echo "访问: https://cli.github.com/"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "使用包管理器安装..."
        if command -v apt >/dev/null 2>&1; then
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install gh
        else
            echo "❌ 不支持的Linux发行版，请手动安装GitHub CLI"
            echo "访问: https://cli.github.com/"
            exit 1
        fi
    else
        echo "❌ 不支持的操作系统，请手动安装GitHub CLI"
        echo "访问: https://cli.github.com/"
        exit 1
    fi
fi

# 检查GitHub CLI认证
echo "🔍 检查GitHub CLI认证..."
if gh auth status >/dev/null 2>&1; then
    echo "✅ GitHub CLI 已认证"
else
    echo "🔐 需要GitHub CLI认证..."
    echo "💡 请按照提示进行认证"
    gh auth login --web
fi

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
- 部署脚本: full_auto_deploy.sh
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
git commit -m "Initial commit: Auto-deployed project $(date '+%Y-%m-%d %H:%M:%S')"
echo "✅ 初始提交创建成功"

# 使用GitHub CLI创建仓库并推送
echo "🏗️  使用GitHub CLI创建仓库..."
echo "执行命令: gh repo create $REPO_NAME --public --description \"$REPO_DESCRIPTION\" --source=. --push"

if gh repo create "$REPO_NAME" --public --description "$REPO_DESCRIPTION" --source=. --push; then
    echo "✅ 仓库创建并推送成功!"
    
    # 启用GitHub Pages
    echo "🌐 启用GitHub Pages..."
    if gh api repos/$GITHUB_USERNAME/$REPO_NAME/pages -X POST -f source='{"branch":"main","path":"/"}' >/dev/null 2>&1; then
        echo "✅ GitHub Pages已启用"
    else
        echo "⚠️  GitHub Pages启用失败，请手动启用"
    fi

    # 完成
    echo ""
    echo "============================================================"
    echo "🎉 部署完成!"
    echo "============================================================"
    echo "📦 仓库地址: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
    echo "🌍 网站地址: https://$GITHUB_USERNAME.github.io/$REPO_NAME"
    echo "============================================================"
else
    echo "❌ 仓库创建失败"
    echo ""
    echo "🔧 常见问题排查:"
    echo "   1. 检查GitHub CLI认证状态: gh auth status"
    echo "   2. 检查仓库名称是否已存在"
    echo "   3. 检查网络连接"
    echo "   4. 尝试手动创建: gh repo create $REPO_NAME --public"
    echo ""
    echo "💡 如果问题持续，请尝试:"
    echo "   1. 重新认证: gh auth login"
    echo "   2. 检查GitHub账户权限"
    echo "   3. 使用手动方式创建仓库"
    exit 1
fi
