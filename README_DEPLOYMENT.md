# 自动化GitHub部署脚本使用说明

## 脚本功能

`auto_deploy_to_github.sh` 是一个自动化脚本，可以一键创建GitHub远程仓库并上传本地项目代码。

## 主要特性

- ✅ 自动检测GitHub CLI是否已安装
- ✅ 检查Git仓库状态
- ✅ 自动登录GitHub（首次使用需要手动授权）
- ✅ 创建GitHub远程仓库（如果不存在）
- ✅ 推送本地代码到GitHub
- ✅ 可选择启用GitHub Pages
- ✅ 彩色输出和详细的状态信息

## 使用方法

### 1. 运行脚本

```bash
./auto_deploy_to_github.sh
```

### 2. 首次使用

首次运行时，脚本会要求你登录GitHub：

1. 选择协议：选择 `HTTPS`
2. 认证Git：选择 `Yes`
3. 复制一次性代码（如：`B2D5-931F`）
4. 按回车键打开浏览器
5. 在浏览器中输入代码完成认证

### 3. 仓库信息

- **仓库名称**：自动使用当前文件夹名称（如：`index1`）
- **仓库类型**：公共仓库
- **描述**：`Auto-deployed project: [项目名]`
- **GitHub地址**：`https://github.com/suwenge-game/[项目名]`

## 脚本配置

脚本中的配置项：

```bash
GITHUB_USERNAME="suwenge-gama"  # GitHub用户名
REPO_NAME=$(basename "$(pwd)")  # 自动获取当前目录名作为仓库名
```

## 输出示例

```
[INFO] 项目名称: index1
[STEP] 1. 检查GitHub CLI是否已安装...
[INFO] GitHub CLI 已安装
[STEP] 2. 检查Git仓库状态...
[INFO] Git仓库已存在，检查状态...
[STEP] 3. 登录GitHub...
[INFO] GitHub已登录
[STEP] 4. 创建GitHub远程仓库...
[INFO] 远程源已存在，跳过创建步骤
[INFO] 当前远程源: https://github.com/suwenge-game/index1.git
[STEP] 5. 推送代码到GitHub...
[INFO] 部署完成！
[INFO] 仓库地址: https://github.com/suwenge-gama/index1
[INFO] GitHub Pages (如果启用): https://suwenge-gama.github.io/index1
```

## GitHub Pages

脚本会询问是否启用GitHub Pages：

- 选择 `y`：自动配置GitHub Pages
- 选择 `n`：跳过GitHub Pages配置

如果自动配置失败，可以手动访问仓库设置页面启用：
`https://github.com/suwenge-game/[项目名]/settings/pages`

## 注意事项

1. **首次使用**：需要手动完成GitHub登录认证
2. **仓库已存在**：如果远程仓库已存在，脚本会跳过创建步骤
3. **GitHub Pages**：启用后需要几分钟才能访问网站
4. **权限要求**：需要GitHub账户有创建仓库的权限

## 故障排除

### GitHub CLI未安装
```bash
brew install gh
```

### 认证失败
```bash
gh auth login
```

### 推送失败
检查网络连接和GitHub权限设置。

## 项目信息

- **项目名称**：index1
- **GitHub仓库**：https://github.com/suwenge-game/index1
- **部署时间**：2025-09-06 23:12:42
- **脚本版本**：v1.0
