# GitHub项目自动部署脚本

这是一个Python脚本，可以一键创建GitHub仓库并上传本地项目。

## 功能特性

- 🚀 **一键部署**: 自动创建GitHub仓库并上传代码
- 🔐 **安全认证**: 使用GitHub Personal Access Token
- 🌐 **自动启用Pages**: 自动配置GitHub Pages
- 📝 **智能README**: 自动创建项目说明文档
- ⚡ **错误处理**: 完善的错误处理和用户提示
- 🔍 **依赖检查**: 自动检查并安装必要依赖

## 安装依赖

```bash
pip install -r requirements.txt
```

或者手动安装：

```bash
pip install requests
```

## 使用方法

### 1. 准备GitHub Token

1. 访问 [GitHub Settings > Personal Access Tokens](https://github.com/settings/tokens)
2. 点击 "Generate new token"
3. 选择以下权限：
   - `repo` (完整仓库访问权限)
   - `admin:org` (如果是组织仓库)
4. 复制生成的token

### 2. 运行脚本

```bash
python deploy_to_github.py
```

### 3. 按提示输入信息

- GitHub用户名
- GitHub Personal Access Token
- 仓库名称
- 仓库描述（可选）
- 是否创建私有仓库

## 脚本功能详解

### 自动执行的操作

1. **依赖检查**: 检查Git和requests库
2. **连接测试**: 验证GitHub Token有效性
3. **仓库创建**: 在GitHub上创建新仓库
4. **Git初始化**: 初始化本地Git仓库（如果需要）
5. **文件提交**: 添加并提交所有文件
6. **代码推送**: 推送到GitHub远程仓库
7. **Pages启用**: 自动启用GitHub Pages
8. **README创建**: 自动创建项目说明文档

### 输出信息

脚本执行完成后会显示：
- 仓库地址: `https://github.com/用户名/仓库名`
- 网站地址: `https://用户名.github.io/仓库名`

## 使用示例

```bash
$ python deploy_to_github.py

============================================================
🚀 GitHub项目自动创建和部署脚本
============================================================

🔍 检查系统依赖...
✅ Git 已安装
✅ requests 库已安装

📝 请输入项目信息:

GitHub用户名: suwenge-game
🔑 GitHub Personal Access Token:
Token: ****************
📦 仓库名称: my-awesome-project
📄 仓库描述 (可选): 我的超棒项目
🔒 是否创建私有仓库? (y/N): n

🔗 测试GitHub连接...
✅ 连接成功! 欢迎, suwenge-game

📝 创建README.md文件...
✅ README.md创建成功

📁 初始化本地Git仓库...
✅ Git仓库初始化成功
✅ 文件已添加到暂存区
✅ 初始提交创建成功

🏗️  创建GitHub仓库: my-awesome-project
✅ 仓库创建成功!
   URL: https://github.com/suwenge-game/my-awesome-project

⬆️  推送到GitHub...
✅ 远程仓库已添加
✅ 代码推送成功

🌐 启用GitHub Pages...
✅ GitHub Pages已启用
🌍 网站地址: https://suwenge-game.github.io/my-awesome-project

============================================================
🎉 部署完成!
============================================================
📦 仓库地址: https://github.com/suwenge-game/my-awesome-project
🌍 网站地址: https://suwenge-game.github.io/my-awesome-project
============================================================
```

## 注意事项

### 安全提醒

- ⚠️ **不要分享您的GitHub Token**
- ⚠️ **Token具有完整的仓库访问权限，请妥善保管**
- ⚠️ **建议定期更换Token**

### 系统要求

- Python 3.6+
- Git
- 网络连接

### 常见问题

**Q: 提示"Git未安装"怎么办？**
A: 请先安装Git: https://git-scm.com/downloads

**Q: 提示"requests库未安装"怎么办？**
A: 脚本会自动尝试安装，如果失败请手动运行: `pip install requests`

**Q: 提示"GitHub连接失败"怎么办？**
A: 检查Token是否正确，是否有足够的权限

**Q: 提示"仓库名称已存在"怎么办？**
A: 更换一个不存在的仓库名称

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request来改进这个脚本！
