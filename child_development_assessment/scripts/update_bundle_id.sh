#!/usr/bin/env bash
set -euo pipefail

# 更新Bundle ID脚本
# 使用：bash scripts/update_bundle_id.sh

OLD_BUNDLE_ID="com.example.childDevelopmentAssessment"
NEW_BUNDLE_ID="com.vonxq.childDevelopmentAssessment"

echo "🔄 更新Bundle ID..."
echo "   从: $OLD_BUNDLE_ID"
echo "   到: $NEW_BUNDLE_ID"

# 更新Xcode项目文件
echo "📝 更新Xcode项目配置..."
sed -i '' "s/$OLD_BUNDLE_ID/$NEW_BUNDLE_ID/g" ios/Runner.xcodeproj/project.pbxproj

# 验证更改
echo "✅ Bundle ID更新完成"
echo ""
echo "📋 请在Apple Developer Console中创建对应的App ID："
echo "   Bundle ID: $NEW_BUNDLE_ID"
echo "   Description: 儿童发育评估"
echo ""
echo "⚠️  重要：确保在Apple Developer Console中的Bundle ID与此完全一致"
