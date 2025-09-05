#!/usr/bin/env python3
"""
Git自动部署脚本 - 使用Git命令创建仓库
通过Git命令行工具实现完整的自动化部署

作者: AI Assistant
版本: 1.0
"""

import os
import sys
import subprocess
import time

class GitAutoDeployer:
    def __init__(self):
        # 硬编码的GitHub账号信息
        self.github_username = "suwenge-game"
        self.github_password = "zhangzhilove0314"
        self.repo_name = ""
        self.repo_description = ""
        self.is_private = False
        
    def print_banner(self):
        """打印脚本横幅"""
        print("=" * 60)
        print("🚀 Git自动部署脚本")
        print("=" * 60)
        print(f"🔑 GitHub账号: {self.github_username}")
        print("🔐 使用Git命令自动创建仓库")
        print()
        
    def get_user_input(self):
        """获取用户输入"""
        print("📝 请输入项目信息:")
        
        # 仓库名称
        self.repo_name = input("📦 仓库名称: ").strip()
        if not self.repo_name:
            print("❌ 仓库名称不能为空")
            sys.exit(1)
            
        # 仓库描述
        self.repo_description = input("📄 仓库描述 (可选): ").strip()
        
        # 是否私有
        private_input = input("\n🔒 是否创建私有仓库? (y/N): ").strip().lower()
        self.is_private = private_input in ['y', 'yes', '是']
        
        print()
        
    def check_git_installed(self) -> bool:
        """检查Git是否已安装"""
        try:
            subprocess.run(["git", "--version"], capture_output=True, check=True)
            print("✅ Git 已安装")
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("❌ Git 未安装，请先安装Git")
            return False
            
    def initialize_git_repository(self) -> bool:
        """初始化本地Git仓库"""
        print("📁 初始化本地Git仓库...")
        
        try:
            # 检查是否已经是git仓库
            if os.path.exists(".git"):
                print("ℹ️  已经是Git仓库，跳过初始化")
                return True
                
            # 初始化git仓库
            subprocess.run(["git", "init"], check=True, capture_output=True)
            print("✅ Git仓库初始化成功")
            
            # 添加所有文件
            subprocess.run(["git", "add", "."], check=True, capture_output=True)
            print("✅ 文件已添加到暂存区")
            
            # 创建初始提交
            subprocess.run(
                ["git", "commit", "-m", "Initial commit: Auto-deployed project"],
                check=True,
                capture_output=True
            )
            print("✅ 初始提交创建成功")
            
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Git操作失败: {e}")
            return False
            
    def create_readme_if_not_exists(self):
        """如果不存在README.md，创建一个"""
        if not os.path.exists("README.md"):
            print("📝 创建README.md文件...")
            readme_content = f"""# {self.repo_name}

{self.repo_description or "自动部署的项目"}

## 项目描述

这是一个通过自动化脚本部署到GitHub的项目。

## 部署信息

- 部署时间: {time.strftime('%Y-%m-%d %H:%M:%S')}
- 部署脚本: git_auto_deploy.py
- GitHub仓库: https://github.com/{self.github_username}/{self.repo_name}

## 使用方法

1. 克隆仓库
2. 打开项目文件
3. 开始使用

## 许可证

请根据项目需要添加适当的许可证信息。
"""
            with open("README.md", "w", encoding="utf-8") as f:
                f.write(readme_content)
            print("✅ README.md创建成功")
            
    def create_github_repository_with_git(self) -> bool:
        """使用Git命令创建GitHub仓库"""
        print("🏗️  使用Git命令创建GitHub仓库...")
        
        try:
            # 设置Git凭据
            print("🔧 配置Git凭据...")
            subprocess.run(
                ["git", "config", "--global", "credential.helper", "store"],
                check=True,
                capture_output=True
            )
            
            # 创建凭据文件
            credentials_file = os.path.expanduser("~/.git-credentials")
            with open(credentials_file, "w") as f:
                f.write(f"https://{self.github_username}:{self.github_password}@github.com\n")
            print("✅ Git凭据已配置")
            
            # 添加远程仓库
            remote_url = f"https://github.com/{self.github_username}/{self.repo_name}.git"
            print(f"🔗 添加远程仓库: {remote_url}")
            
            # 检查是否已经有远程仓库
            try:
                result = subprocess.run(
                    ["git", "remote", "get-url", "origin"],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    print("ℹ️  远程仓库已存在，更新URL")
                    subprocess.run(
                        ["git", "remote", "set-url", "origin", remote_url],
                        check=True,
                        capture_output=True
                    )
                else:
                    subprocess.run(
                        ["git", "remote", "add", "origin", remote_url],
                        check=True,
                        capture_output=True
                    )
            except subprocess.CalledProcessError:
                subprocess.run(
                    ["git", "remote", "add", "origin", remote_url],
                    check=True,
                    capture_output=True
                )
            
            print("✅ 远程仓库已设置")
            
            # 推送代码（这会自动创建仓库）
            print("⬆️  推送代码到GitHub...")
            print("💡 如果仓库不存在，GitHub会自动创建")
            
            # 使用环境变量设置Git凭据
            env = os.environ.copy()
            env['GIT_TERMINAL_PROMPT'] = '0'
            
            # 推送代码
            result = subprocess.run(
                ["git", "push", "-u", "origin", "main"],
                capture_output=True,
                text=True,
                env=env
            )
            
            if result.returncode == 0:
                print("✅ 代码推送成功，仓库已创建!")
                return True
            else:
                print(f"❌ 推送失败: {result.stderr}")
                
                # 如果推送失败，尝试创建仓库的替代方法
                print("🔄 尝试替代方法...")
                return self.create_repository_alternative()
                
        except subprocess.CalledProcessError as e:
            print(f"❌ Git操作失败: {e}")
            return False
            
    def create_repository_alternative(self) -> bool:
        """创建仓库的替代方法"""
        print("🔄 使用替代方法创建仓库...")
        
        try:
            # 使用GitHub CLI（如果可用）
            try:
                subprocess.run(["gh", "--version"], capture_output=True, check=True)
                print("✅ 发现GitHub CLI，使用gh命令创建仓库")
                
                cmd = ["gh", "repo", "create", self.repo_name]
                if self.repo_description:
                    cmd.extend(["--description", self.repo_description])
                if self.is_private:
                    cmd.append("--private")
                else:
                    cmd.append("--public")
                cmd.extend(["--source=.", "--push"])
                
                result = subprocess.run(cmd, capture_output=True, text=True)
                if result.returncode == 0:
                    print("✅ 使用GitHub CLI创建仓库成功!")
                    return True
                else:
                    print(f"❌ GitHub CLI创建失败: {result.stderr}")
                    
            except (subprocess.CalledProcessError, FileNotFoundError):
                print("ℹ️  GitHub CLI不可用")
            
            # 如果所有方法都失败，提供手动指导
            print("⚠️  自动创建失败，需要手动创建仓库")
            self.show_manual_creation_guide()
            return False
            
        except Exception as e:
            print(f"❌ 替代方法失败: {e}")
            return False
            
    def show_manual_creation_guide(self):
        """显示手动创建仓库的指导"""
        print("🏗️  手动创建GitHub仓库:")
        print("=" * 50)
        print("1. 访问: https://github.com/new")
        print("2. 填写仓库信息:")
        print(f"   - Repository name: {self.repo_name}")
        print(f"   - Description: {self.repo_description}")
        print(f"   - Visibility: {'Private' if self.is_private else 'Public'}")
        print("3. 不要勾选任何选项")
        print("4. 点击 'Create repository'")
        print("5. 然后运行以下命令推送代码:")
        print(f"   git push -u origin main")
        print("=" * 50)
        
    def enable_github_pages_manual(self):
        """手动启用GitHub Pages的指导"""
        print("🌐 手动启用GitHub Pages:")
        print("=" * 50)
        print("1. 访问: https://github.com/suwenge-game/" + self.repo_name + "/settings/pages")
        print("2. 在 'Source' 下选择 'Deploy from a branch'")
        print("3. 选择分支: main")
        print("4. 选择文件夹: / (root)")
        print("5. 点击 'Save'")
        print("=" * 50)
        print()
        
    def run(self):
        """运行主流程"""
        self.print_banner()
        
        # 检查Git
        if not self.check_git_installed():
            sys.exit(1)
            
        # 获取用户输入
        self.get_user_input()
        
        # 创建README文件（如果需要）
        self.create_readme_if_not_exists()
        
        # 初始化Git仓库
        if not self.initialize_git_repository():
            sys.exit(1)
            
        # 使用Git命令创建GitHub仓库
        if not self.create_github_repository_with_git():
            print("⚠️  自动创建失败，请按照上述指导手动创建仓库")
            sys.exit(1)
            
        # 手动启用GitHub Pages指导
        self.enable_github_pages_manual()
        
        # 完成
        print("\n" + "=" * 60)
        print("🎉 部署完成!")
        print("=" * 60)
        print(f"📦 仓库地址: https://github.com/{self.github_username}/{self.repo_name}")
        print(f"🌍 网站地址: https://{self.github_username}.github.io/{self.repo_name}")
        print("=" * 60)

def main():
    """主函数"""
    try:
        deployer = GitAutoDeployer()
        deployer.run()
    except KeyboardInterrupt:
        print("\n\n❌ 用户取消操作")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
