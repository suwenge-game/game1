#!/bin/bash

# 快速部署脚本 - 提交代码到game1仓库
# 使用方法: ./quick_deploy.sh "提交信息"

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印消息函数
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查是否在正确的目录
if [ ! -f "index.html" ]; then
    print_warning "请在项目根目录运行此脚本"
    exit 1
fi

# 获取提交信息
if [ -z "$1" ]; then
    print_warning "请提供提交信息"
    echo "使用方法: ./quick_deploy.sh \"你的提交信息\""
    exit 1
fi

COMMIT_MSG="$1"

print_step "1. 添加所有更改..."
git add .

print_step "2. 检查更改状态..."
git status

print_step "3. 提交更改..."
git commit -m "$COMMIT_MSG"

print_step "4. 推送到远程仓库..."
# 如果推送失败，尝试网络优化配置
if ! git push origin main; then
    print_warning "推送失败，尝试网络优化..."
    git config --global http.postBuffer 524288000
    git config --global http.lowSpeedLimit 0
    git config --global http.lowSpeedTime 999999
    
    print_step "重新尝试推送..."
    git push origin main
fi

print_message "✅ 部署完成！"
print_message "仓库地址: https://github.com/suwenge-game/game1"
print_message "提交ID: $(git rev-parse --short HEAD)"

# 显示最新提交信息
print_step "最新提交信息:"
git log --oneline -1
