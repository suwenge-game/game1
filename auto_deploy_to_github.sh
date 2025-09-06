#!/bin/bash

# 自动部署到GitHub脚本
# 使用GitHub CLI创建远程仓库并上传代码

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 获取当前目录名作为仓库名
REPO_NAME=$(basename "$(pwd)")
print_message "项目名称: $REPO_NAME"

# 设置GitHub凭据
GITHUB_USERNAME="suwenge-gama"
# 注意：GitHub不再支持密码认证，需要使用Personal Access Token
# 请访问 https://github.com/settings/tokens 创建Personal Access Token
GITHUB_TOKEN="zhangzhilove0314"  # 这应该是Personal Access Token，不是密码

print_step "1. 检查GitHub CLI是否已安装..."
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) 未安装，请先安装: brew install gh"
    exit 1
fi
print_message "GitHub CLI 已安装"

print_step "2. 检查Git仓库状态..."
if [ ! -d ".git" ]; then
    print_message "初始化Git仓库..."
    git init
    git add .
    git commit -m "Initial commit"
else
    print_message "Git仓库已存在，检查状态..."
    git status
fi

print_step "3. 登录GitHub..."
# 检查是否已经登录
if gh auth status &> /dev/null; then
    print_message "GitHub已登录"
else
    print_warning "GitHub未登录，请手动登录..."
    print_message "请按照提示完成GitHub登录："
    gh auth login --web
    if [ $? -ne 0 ]; then
        print_error "GitHub登录失败"
        exit 1
    fi
    print_message "GitHub登录成功"
fi

print_step "4. 创建GitHub远程仓库..."
# 使用GitHub CLI创建仓库
gh repo create "$REPO_NAME" --public --description "Auto-deployed project: $REPO_NAME" --source=. --remote=origin --push

if [ $? -eq 0 ]; then
    print_message "仓库创建成功: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
else
    print_warning "仓库可能已存在，尝试添加远程源..."
    # 如果仓库已存在，添加远程源并推送
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" 2>/dev/null || true
    git branch -M main
    git push -u origin main
fi

print_step "5. 推送代码到GitHub..."
git add .
git commit -m "Auto-deploy: $(date '+%Y-%m-%d %H:%M:%S')" || print_warning "没有新的更改需要提交"
git push origin main

print_message "部署完成！"
print_message "仓库地址: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
print_message "GitHub Pages (如果启用): https://$GITHUB_USERNAME.github.io/$REPO_NAME"

# 询问是否启用GitHub Pages
echo ""
read -p "是否启用GitHub Pages? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "启用GitHub Pages..."
    gh api repos/$GITHUB_USERNAME/$REPO_NAME/pages -X POST -f source[branch]=main -f source[path]=/
    print_message "GitHub Pages已启用，网站将在几分钟内可用"
fi

print_message "脚本执行完成！"
