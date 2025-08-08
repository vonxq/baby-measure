#!/usr/bin/env bash
set -euo pipefail

# Bundle ID修复脚本
# 用于统一和修复Bundle ID配置
# 使用：bash scripts/fix_bundle_id.sh

echo "🔧 Bundle ID修复工具"
echo "==================="

# 检查是否在正确的目录
if [ ! -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    echo "❌ 错误：请在Flutter项目根目录运行此脚本"
    exit 1
fi

# 定义Bundle ID
BUNDLE_ID="com.vonxq.childDevelopmentAssessment"

echo "📝 当前Bundle ID配置："
echo "   主应用: $BUNDLE_ID"
echo "   测试应用: $BUNDLE_ID.RunnerTests"
echo ""

echo "🔧 修复Bundle ID配置..."

# 备份原文件
cp ios/Runner.xcodeproj/project.pbxproj ios/Runner.xcodeproj/project.pbxproj.backup

# 使用sed修复Bundle ID
sed -i '' "s/com\.vonxq\.babyMeasure/$BUNDLE_ID/g" ios/Runner.xcodeproj/project.pbxproj

echo "✅ Bundle ID修复完成！"
echo ""
echo "📋 修复内容："
echo "   - 统一所有配置中的Bundle ID"
echo "   - 主应用: $BUNDLE_ID"
echo "   - 测试应用: $BUNDLE_ID.RunnerTests"
echo ""
echo "📋 下一步操作："
echo "1. 在Apple Developer Console中创建App ID: $BUNDLE_ID"
echo "2. 创建对应的证书和配置文件"
echo "3. 在Xcode中验证Bundle ID设置"
echo ""
echo "🔗 相关链接："
echo "   - App ID管理: https://developer.apple.com/account/resources/identifiers/list"
echo "   - 证书管理: https://developer.apple.com/account/resources/certificates/list"
echo "   - 配置文件: https://developer.apple.com/account/resources/profiles/list" 