# 部署指南 - 如何提交代码到game1仓库

## 📋 快速部署命令

### 方法一：标准Git推送（推荐）
```bash
# 1. 进入项目目录
cd /Users/Shared/game2025/index1

# 2. 添加所有更改
git add .

# 3. 提交更改
git commit -m "描述你的更改内容"

# 4. 推送到远程仓库
git push origin main
```

### 方法二：使用GitHub CLI（备选）
```bash
# 1. 检查GitHub CLI状态
gh auth status

# 2. 查看仓库信息
gh repo view suwenge-game/game1

# 3. 推送代码（如果GitHub CLI已配置）
git push origin main
```

## 🔧 网络问题解决方案

如果遇到网络连接问题，可以尝试以下配置：

```bash
# 增加Git缓冲区大小
git config --global http.postBuffer 524288000

# 设置低速限制
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

# 重新尝试推送
git push origin main
```

## 📁 仓库信息

- **仓库地址**: https://github.com/suwenge-game/game1.git
- **本地路径**: /Users/Shared/game2025/index1
- **主分支**: main
- **远程名称**: origin

## 🚀 自动部署脚本

项目包含自动部署脚本 `auto_deploy_to_github.sh`，但需要GitHub CLI配置：

```bash
# 运行自动部署脚本
./auto_deploy_to_github.sh
```

## 📝 提交信息模板

建议使用以下格式的提交信息：

```
修复Google Search Console索引问题

- 修复sitemap.xml中的URL路径问题
- 为所有页面添加正确的robots meta标签
- 添加canonical标签解决重复内容问题
- 增强结构化数据提升页面质量
- 更新robots.txt排除管理页面
- 优化SEO配置和元数据
```

## 🔍 验证部署

部署完成后，可以通过以下方式验证：

```bash
# 检查本地状态
git status

# 查看提交历史
git log --oneline -5

# 检查远程连接
git remote -v

# 查看分支状态
git branch -vv
```

## ⚠️ 常见问题

### 1. 网络连接超时
```bash
# 解决方案：增加超时时间和缓冲区
git config --global http.postBuffer 524288000
git config --global http.lowSpeedTime 999999
```

### 2. 权限问题
```bash
# 检查远程URL
git remote get-url origin

# 如果需要，重新设置远程URL
git remote set-url origin https://github.com/suwenge-game/game1.git
```

### 3. SSH密钥问题
```bash
# 如果SSH有问题，改回HTTPS
git remote set-url origin https://github.com/suwenge-game/game1.git
```

## 📊 成功部署记录

### 最近一次成功部署
- **时间**: 2025-01-17
- **提交ID**: 3dacfaf
- **提交信息**: "修复Google Search Console索引问题"
- **修改文件**: 8个文件，458行新增，30行删除
- **状态**: ✅ 成功推送到远程仓库

### 部署文件列表
- `index.html` - 主页SEO优化
- `news.html` - 新闻页面优化
- `admin.html` - 管理页面配置
- `sitemap.xml` - 站点地图更新
- `robots.txt` - 爬虫规则更新
- 新增文档文件

## 🎯 下次部署步骤

1. **修改代码**
2. **运行**: `git add .`
3. **提交**: `git commit -m "你的提交信息"`
4. **推送**: `git push origin main`
5. **验证**: `git status`

---

*最后更新: 2025-01-17*
*仓库: suwenge-game/game1*
