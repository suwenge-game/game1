#!/bin/bash

# 自动Ping搜索引擎脚本
# 通知Google、Bing等搜索引擎网站已更新

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 网站URL
SITE_URL="https://deskgame.xyz"
SITEMAP_URL="https://deskgame.xyz/sitemap.xml"

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_message "开始Ping搜索引擎..."

# 检查网络连接
print_step "检查网络连接..."
if ! curl -s --max-time 5 "https://www.google.com" > /dev/null 2>&1; then
    print_warning "网络连接可能有问题，但继续尝试ping..."
else
    print_message "网络连接正常"
fi

# Ping Google
print_step "Pinging Google..."
if curl -s --max-time 10 "http://www.google.com/ping?sitemap=$SITEMAP_URL" > /dev/null; then
    print_message "✅ Google pinged successfully"
else
    print_warning "⚠️ Google ping failed"
fi

# Ping Bing
print_step "Pinging Bing..."
if curl -s --max-time 10 "http://www.bing.com/ping?sitemap=$SITEMAP_URL" > /dev/null; then
    print_message "✅ Bing pinged successfully"
else
    print_warning "⚠️ Bing ping failed"
fi

# Ping Yandex (可选)
print_step "Pinging Yandex..."
if curl -s --max-time 10 "http://webmaster.yandex.com/ping?sitemap=$SITEMAP_URL" > /dev/null; then
    print_message "✅ Yandex pinged successfully"
else
    print_warning "⚠️ Yandex ping failed"
fi

print_message "🎉 搜索引擎Ping完成！"
print_message "建议接下来："
print_message "1. 登录Google Search Console"
print_message "2. 提交sitemap: $SITEMAP_URL"
print_message "3. 请求主要页面重新索引"
print_message "4. 检查索引状态"

# 显示有用的链接
echo ""
print_step "有用的链接："
echo "Google Search Console: https://search.google.com/search-console/"
echo "Bing Webmaster Tools: https://www.bing.com/webmasters/"
echo "网站Sitemap: $SITEMAP_URL"
echo "网站首页: $SITE_URL"

