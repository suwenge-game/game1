#!/bin/bash

# 检查Google索引状态脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

SITE_URL="https://deskgame.xyz"

print_message "检查网站索引状态..."

print_step "1. 检查网站可访问性..."
if curl -s --max-time 10 "$SITE_URL" > /dev/null; then
    print_message "✅ 网站可正常访问"
else
    print_message "❌ 网站无法访问"
fi

print_step "2. 检查sitemap可访问性..."
if curl -s --max-time 10 "$SITE_URL/sitemap.xml" > /dev/null; then
    print_message "✅ Sitemap可正常访问"
else
    print_message "❌ Sitemap无法访问"
fi

print_step "3. 检查robots.txt..."
if curl -s --max-time 10 "$SITE_URL/robots.txt" > /dev/null; then
    print_message "✅ Robots.txt可正常访问"
else
    print_message "❌ Robots.txt无法访问"
fi

print_message "📋 手动检查建议："
print_message "1. 在Google搜索中测试: site:deskgame.xyz"
print_message "2. 登录Google Search Console检查索引状态"
print_message "3. 使用URL检查工具验证页面"
print_message "4. 监控覆盖范围报告"

print_message "🔗 有用的链接："
echo "Google Search Console: https://search.google.com/search-console/"
echo "Bing Webmaster Tools: https://www.bing.com/webmasters/"
echo "网站首页: $SITE_URL"
echo "Sitemap: $SITE_URL/sitemap.xml"
