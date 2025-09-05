#!/usr/bin/env python3
"""
GitHub项目自动创建和部署脚本
一键创建GitHub仓库并上传本地项目

作者: AI Assistant
版本: 1.0
"""

import os
import sys
import json
import subprocess
import requests
import getpass
from typing import Dict, Optional, Tuple
import time

class GitHubDeployer:
    def __init__(self):
        # 硬编码的GitHub账号信息
        self.github_username = "suwenge-game"
        self.github_password = "zhangzhilove0314"
        self.github_token = ""  # 优先使用token
        self.repo_name = ""
        self.repo_description = ""
        self.is_private = False
        self.github_api_url = "https://api.github.com"
        
    def print_banner(self):
        """打印脚本横幅"""
        print("=" * 60)
        print("🚀 GitHub项目自动创建和部署脚本")
        print("=" * 60)
        print()
        
    def check_dependencies(self) -> bool:
        """检查必要的依赖"""
        print("🔍 检查系统依赖...")
        
        # 检查git
        try:
            subprocess.run(["git", "--version"], capture_output=True, check=True)
            print("✅ Git 已安装")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("❌ Git 未安装，请先安装Git")
            return False
            
        # 检查requests库
        try:
            import requests
            print("✅ requests 库已安装")
        except ImportError:
            print("❌ requests 库未安装，正在安装...")
            try:
                subprocess.run([sys.executable, "-m", "pip", "install", "requests"], check=True)
                print("✅ requests 库安装成功")
            except subprocess.CalledProcessError:
                print("❌ requests 库安装失败")
                return False
                
        print()
        return True
        
    def get_user_input(self):
        """获取用户输入"""
        print("📝 请输入项目信息:")
        print(f"🔑 GitHub账号: {self.github_username}")
        print()
        
        # 检查是否需要Token
        print("⚠️  重要提示:")
        print("   GitHub已不再支持用户名密码认证")
        print("   请使用Personal Access Token进行认证")
        print()
        
        token_input = input("🔑 请输入GitHub Personal Access Token (可选，留空将尝试使用密码): ").strip()
        if token_input:
            self.github_token = token_input
            print("✅ 将使用Token进行认证")
        else:
            print("⚠️  将尝试使用用户名密码认证（可能失败）")
        
        print()
        
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
        
    def test_github_connection(self) -> bool:
        """测试GitHub连接"""
        print("🔗 测试GitHub连接...")
        
        # 优先使用token，如果没有则使用用户名密码
        if self.github_token:
            headers = {
                "Authorization": f"token {self.github_token}",
                "Accept": "application/vnd.github.v3+json"
            }
        else:
            # 使用基本认证（用户名密码）
            import base64
            credentials = f"{self.github_username}:{self.github_password}"
            encoded_credentials = base64.b64encode(credentials.encode()).decode()
            headers = {
                "Authorization": f"Basic {encoded_credentials}",
                "Accept": "application/vnd.github.v3+json"
            }
        
        try:
            response = requests.get(f"{self.github_api_url}/user", headers=headers)
            if response.status_code == 200:
                user_data = response.json()
                print(f"✅ 连接成功! 欢迎, {user_data.get('login', 'Unknown')}")
                return True
            else:
                print(f"❌ 连接失败: {response.status_code} - {response.text}")
                return False
        except requests.RequestException as e:
            print(f"❌ 网络错误: {e}")
            return False
            
    def check_repository_exists(self) -> bool:
        """检查仓库是否已存在"""
        print(f"🔍 检查仓库是否存在: {self.repo_name}")
        
        # 优先使用token，如果没有则使用用户名密码
        if self.github_token:
            headers = {
                "Authorization": f"token {self.github_token}",
                "Accept": "application/vnd.github.v3+json"
            }
        else:
            # 使用基本认证（用户名密码）
            import base64
            credentials = f"{self.github_username}:{self.github_password}"
            encoded_credentials = base64.b64encode(credentials.encode()).decode()
            headers = {
                "Authorization": f"Basic {encoded_credentials}",
                "Accept": "application/vnd.github.v3+json"
            }
        
        try:
            response = requests.get(
                f"{self.github_api_url}/repos/{self.github_username}/{self.repo_name}",
                headers=headers
            )
            
            if response.status_code == 200:
                print(f"ℹ️  仓库已存在: {self.repo_name}")
                return True
            elif response.status_code == 404:
                print(f"ℹ️  仓库不存在，将创建新仓库: {self.repo_name}")
                return False
            else:
                print(f"⚠️  检查仓库状态失败: {response.status_code}")
                return False
                
        except requests.RequestException as e:
            print(f"⚠️  检查仓库时网络错误: {e}")
            return False

    def create_github_repository(self) -> bool:
        """创建GitHub仓库"""
        # 先检查仓库是否已存在
        if self.check_repository_exists():
            print(f"✅ 仓库已存在，跳过创建: {self.repo_name}")
            return True
            
        print(f"🏗️  创建GitHub仓库: {self.repo_name}")
        
        # 优先使用token，如果没有则使用用户名密码
        if self.github_token:
            headers = {
                "Authorization": f"token {self.github_token}",
                "Accept": "application/vnd.github.v3+json"
            }
        else:
            # 使用基本认证（用户名密码）
            import base64
            credentials = f"{self.github_username}:{self.github_password}"
            encoded_credentials = base64.b64encode(credentials.encode()).decode()
            headers = {
                "Authorization": f"Basic {encoded_credentials}",
                "Accept": "application/vnd.github.v3+json"
            }
        
        data = {
            "name": self.repo_name,
            "description": self.repo_description,
            "private": self.is_private,
            "auto_init": False
        }
        
        try:
            response = requests.post(
                f"{self.github_api_url}/user/repos",
                headers=headers,
                json=data
            )
            
            if response.status_code == 201:
                repo_data = response.json()
                print(f"✅ 仓库创建成功!")
                print(f"   URL: {repo_data['html_url']}")
                return True
            elif response.status_code == 422:
                print("❌ 仓库名称已存在或无效")
                return False
            else:
                print(f"❌ 创建失败: {response.status_code} - {response.text}")
                return False
                
        except requests.RequestException as e:
            print(f"❌ 网络错误: {e}")
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
            
    def push_to_github(self) -> bool:
        """推送到GitHub"""
        print("⬆️  推送到GitHub...")
        
        try:
            # 添加远程仓库
            if self.github_token:
                remote_url = f"https://{self.github_username}:{self.github_token}@github.com/{self.github_username}/{self.repo_name}.git"
            else:
                remote_url = f"https://{self.github_username}:{self.github_password}@github.com/{self.github_username}/{self.repo_name}.git"
                
            subprocess.run(
                ["git", "remote", "add", "origin", remote_url],
                check=True,
                capture_output=True
            )
            print("✅ 远程仓库已添加")
            
            # 推送到main分支
            subprocess.run(
                ["git", "push", "-u", "origin", "main"],
                check=True,
                capture_output=True
            )
            print("✅ 代码推送成功")
            
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 推送失败: {e}")
            return False
            
    def enable_github_pages(self) -> bool:
        """启用GitHub Pages"""
        print("🌐 启用GitHub Pages...")
        
        # 优先使用token，如果没有则使用用户名密码
        if self.github_token:
            headers = {
                "Authorization": f"token {self.github_token}",
                "Accept": "application/vnd.github.v3+json"
            }
        else:
            # 使用基本认证（用户名密码）
            import base64
            credentials = f"{self.github_username}:{self.github_password}"
            encoded_credentials = base64.b64encode(credentials.encode()).decode()
            headers = {
                "Authorization": f"Basic {encoded_credentials}",
                "Accept": "application/vnd.github.v3+json"
            }
        
        # 启用Pages
        pages_data = {
            "source": {
                "branch": "main",
                "path": "/"
            }
        }
        
        try:
            response = requests.post(
                f"{self.github_api_url}/repos/{self.github_username}/{self.repo_name}/pages",
                headers=headers,
                json=pages_data
            )
            
            if response.status_code in [201, 204]:
                print("✅ GitHub Pages已启用")
                pages_url = f"https://{self.github_username}.github.io/{self.repo_name}"
                print(f"🌍 网站地址: {pages_url}")
                return True
            else:
                print(f"⚠️  Pages启用失败: {response.status_code} - {response.text}")
                return False
                
        except requests.RequestException as e:
            print(f"⚠️  Pages启用失败: {e}")
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
- 部署脚本: deploy_to_github.py
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
            
    def run(self):
        """运行主流程"""
        self.print_banner()
        
        # 检查依赖
        if not self.check_dependencies():
            sys.exit(1)
            
        # 获取用户输入
        self.get_user_input()
        
        # 测试GitHub连接
        if not self.test_github_connection():
            sys.exit(1)
            
        # 创建README文件（如果需要）
        self.create_readme_if_not_exists()
        
        # 初始化Git仓库
        if not self.initialize_git_repository():
            sys.exit(1)
            
        # 创建GitHub仓库
        if not self.create_github_repository():
            sys.exit(1)
            
        # 推送到GitHub
        if not self.push_to_github():
            sys.exit(1)
            
        # 启用GitHub Pages
        self.enable_github_pages()
        
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
        deployer = GitHubDeployer()
        deployer.run()
    except KeyboardInterrupt:
        print("\n\n❌ 用户取消操作")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
