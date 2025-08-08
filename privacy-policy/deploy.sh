#!/bin/bash

# 儿童发育评估应用隐私政策部署脚本

echo "🚀 开始部署隐私政策页面..."

# 检查是否在正确的目录
if [ ! -f "index.html" ]; then
    echo "❌ 错误：请在包含 index.html 的目录中运行此脚本"
    exit 1
fi

# 检查git是否已初始化
if [ ! -d ".git" ]; then
    echo "📁 初始化git仓库..."
    git init
fi

# 添加所有文件
echo "📝 添加文件到git..."
git add .

# 提交更改
echo "💾 提交更改..."
git commit -m "Update privacy policy - $(date)"

# 检查是否有远程仓库
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "⚠️  警告：未设置远程仓库"
    echo "请先运行以下命令设置远程仓库："
    echo "git remote add origin https://github.com/[您的用户名]/privacy-policy.git"
    exit 1
fi

# 推送到远程仓库
echo "📤 推送到GitHub..."
git push origin main

echo "✅ 部署完成！"
echo ""
echo "📋 下一步："
echo "1. 访问您的GitHub仓库页面"
echo "2. 进入 Settings > Pages"
echo "3. 在 Source 下选择 'Deploy from a branch'"
echo "4. 选择 'main' 分支并保存"
echo "5. 等待几分钟后访问：https://[您的用户名].github.io/privacy-policy"
echo ""
echo "🔗 在App Store Connect中使用此URL："
echo "https://[您的用户名].github.io/privacy-policy"
