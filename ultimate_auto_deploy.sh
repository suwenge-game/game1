#!/bin/bash

# 终极自动化GitHub部署脚本 - 不依赖GitHub CLI
# 作者: AI Assistant

# 硬编码的GitHub账号信息
GITHUB_USERNAME="suwenge-game"
GITHUB_PASSWORD="zhangzhilove0314"

# 自动设置
REPO_NAME=$(basename "$PWD")
REPO_DESCRIPTION="Auto-deployed project from $(date '+%Y-%m-%d %H:%M:%S')"

echo "============================================================"
echo "🚀 终极自动化GitHub部署脚本"
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
- 部署脚本: ultimate_auto_deploy.sh
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

# 配置Git凭据
echo "🔧 配置Git凭据..."
git config --global credential.helper store
echo "https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com" > ~/.git-credentials
echo "✅ Git凭据已配置"

# 添加远程仓库
echo "🔗 添加远程仓库..."
REMOTE_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# 检查是否已经有远程仓库
if git remote get-url origin >/dev/null 2>&1; then
    echo "ℹ️  远程仓库已存在，更新URL"
    git remote set-url origin "$REMOTE_URL"
else
    git remote add origin "$REMOTE_URL"
fi

echo "✅ 远程仓库已设置"

# 使用curl自动创建GitHub仓库
echo "🏗️  使用API自动创建GitHub仓库..."

# 创建仓库的JSON数据
REPO_JSON=$(cat << EOF
{
  "name": "$REPO_NAME",
  "description": "$REPO_DESCRIPTION",
  "private": false,
  "auto_init": false
}
EOF
)

echo "📤 发送创建仓库请求..."
echo "仓库信息: $REPO_JSON"

# 使用curl创建仓库
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -u "$GITHUB_USERNAME:$GITHUB_PASSWORD" \
  -d "$REPO_JSON" \
  "https://api.github.com/user/repos")

# 分离响应体和状态码
HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$CREATE_RESPONSE" | head -n -1)

echo "HTTP状态码: $HTTP_CODE"
echo "响应内容: $RESPONSE_BODY"

if [ "$HTTP_CODE" = "201" ]; then
    echo "✅ 仓库创建成功!"
elif [ "$HTTP_CODE" = "422" ]; then
    echo "⚠️  仓库可能已存在，尝试推送..."
elif [ "$HTTP_CODE" = "401" ]; then
    echo "❌ 认证失败，请检查用户名和密码"
    echo "💡 建议使用Personal Access Token替代密码"
    exit 1
else
    echo "❌ 仓库创建失败 (HTTP: $HTTP_CODE)"
    echo "响应: $RESPONSE_BODY"
    echo "💡 尝试继续推送..."
fi

# 推送代码
echo "⬆️  推送代码到GitHub..."

# 设置环境变量
export GIT_TERMINAL_PROMPT=0

# 推送代码
if git push -u origin main; then
    echo "✅ 代码推送成功!"
    
    # 尝试启用GitHub Pages
    echo "🌐 尝试启用GitHub Pages..."
    PAGES_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -u "$GITHUB_USERNAME:$GITHUB_PASSWORD" \
      -d '{"source":{"branch":"main","path":"/"}}' \
      "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/pages")
    
    PAGES_HTTP_CODE=$(echo "$PAGES_RESPONSE" | tail -n1)
    PAGES_RESPONSE_BODY=$(echo "$PAGES_RESPONSE" | head -n -1)
    
    if [ "$PAGES_HTTP_CODE" = "201" ] || [ "$PAGES_HTTP_CODE" = "204" ]; then
        echo "✅ GitHub Pages已启用"
    else
        echo "⚠️  GitHub Pages启用失败 (HTTP: $PAGES_HTTP_CODE)"
        echo "💡 请手动启用: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/pages"
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
    echo "❌ 推送失败"
    echo ""
    echo "🔧 常见问题排查:"
    echo "   1. 确认GitHub仓库已创建"
    echo "   2. 检查用户名和密码是否正确"
    echo "   3. 检查网络连接"
    echo "   4. 尝试手动推送: git push -u origin main"
    echo ""
    echo "💡 如果问题持续，请尝试:"
    echo "   1. 使用Personal Access Token替代密码"
    echo "   2. 检查GitHub账户设置"
    echo "   3. 手动创建仓库: https://github.com/new"
    echo ""
    echo "🔍 调试信息:"
    echo "当前目录: $PWD"
    echo "仓库名称: $REPO_NAME"
    echo "远程URL: $REMOTE_URL"
    echo "Git配置:"
    git config --list | grep -E "(user|credential|remote)"
    exit 1
fi
