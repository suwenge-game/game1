#!/bin/bash

# 验证Sitemap和网站可访问性脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

SITE_URL="https://deskgame.xyz"
SITEMAP_URL="https://deskgame.xyz/sitemap.xml"

print_message "验证网站和Sitemap状态..."

print_step "1. 检查网站首页..."
if curl -s --max-time 10 "$SITE_URL" > /dev/null; then
    print_message "✅ 网站首页可访问: $SITE_URL"
else
    print_error "❌ 网站首页无法访问: $SITE_URL"
fi

print_step "2. 检查Sitemap..."
if curl -s --max-time 10 "$SITEMAP_URL" > /dev/null; then
    print_message "✅ Sitemap可访问: $SITEMAP_URL"
    
    # 检查sitemap内容
    print_step "3. 验证Sitemap内容..."
    SITEMAP_CONTENT=$(curl -s --max-time 10 "$SITEMAP_URL")
    
    if echo "$SITEMAP_CONTENT" | grep -q "deskgame.xyz"; then
        print_message "✅ Sitemap包含正确的域名"
    else
        print_warning "⚠️ Sitemap可能不包含正确域名"
    fi
    
    if echo "$SITEMAP_CONTENT" | grep -q "lastmod"; then
        print_message "✅ Sitemap包含最后修改时间"
    else
        print_warning "⚠️ Sitemap缺少最后修改时间"
    fi
    
    # 显示sitemap中的URL数量
    URL_COUNT=$(echo "$SITEMAP_CONTENT" | grep -c "<loc>" || echo "0")
    print_message "📊 Sitemap包含 $URL_COUNT 个URL"
    
else
    print_error "❌ Sitemap无法访问: $SITEMAP_URL"
fi

print_step "4. 检查robots.txt..."
if curl -s --max-time 10 "$SITE_URL/robots.txt" > /dev/null; then
    print_message "✅ Robots.txt可访问"
    
    # 检查robots.txt是否包含sitemap
    ROBOTS_CONTENT=$(curl -s --max-time 10 "$SITE_URL/robots.txt")
    if echo "$ROBOTS_CONTENT" | grep -qi "sitemap"; then
        print_message "✅ Robots.txt包含sitemap引用"
    else
        print_warning "⚠️ Robots.txt缺少sitemap引用"
    fi
else
    print_warning "⚠️ Robots.txt无法访问"
fi

print_step "5. 检查主要页面..."
PAGES=("$SITE_URL/" "$SITE_URL/news.html")
for page in "${PAGES[@]}"; do
    if curl -s --max-time 10 "$page" > /dev/null; then
        print_message "✅ 页面可访问: $page"
    else
        print_error "❌ 页面无法访问: $page"
    fi
done

print_message ""
print_message "🎯 Google Search Console 操作建议："
print_message "1. 登录: https://search.google.com/search-console/"
print_message "2. 选择网站: deskgame.xyz"
print_message "3. 查找路径: 索引 → Sitemaps"
print_message "4. 提交sitemap: sitemap.xml"
print_message "5. 使用URL检查工具请求索引"

print_message ""
print_message "🔗 直接链接："
echo "Google Search Console: https://search.google.com/search-console/"
echo "网站首页: $SITE_URL"
echo "Sitemap: $SITEMAP_URL"
echo "Robots.txt: $SITE_URL/robots.txt"

print_message ""
print_message "📱 如果找不到Sitemaps选项："
print_message "1. 尝试搜索 'sitemap'"
print_message "2. 查看 '索引' 子菜单"
print_message "3. 使用URL检查工具直接检查sitemap"
print_message "4. 尝试不同浏览器或清除缓存"
