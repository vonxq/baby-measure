#!/usr/bin/env bash
set -euo pipefail

# 修复xcconfig错误脚本
# 用于解决Generated.xcconfig找不到的问题
# 使用：bash scripts/fix_xcconfig_error.sh

echo "🔧 修复xcconfig错误工具"
echo "======================"

echo "📋 检查当前状态..."
echo ""

# 检查Flutter配置
echo "🔍 检查Flutter配置..."
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "   ✅ Generated.xcconfig 文件存在"
else
    echo "   ❌ Generated.xcconfig 文件不存在"
fi

if [ -f "ios/Flutter/Release.xcconfig" ]; then
    echo "   ✅ Release.xcconfig 文件存在"
else
    echo "   ❌ Release.xcconfig 文件不存在"
fi

echo ""
echo "🧹 清理项目..."
flutter clean

echo ""
echo "📦 重新获取依赖..."
flutter pub get

echo ""
echo "🔧 重新生成iOS配置..."
cd ios
pod install
cd ..

echo ""
echo "📋 检查生成的文件..."
echo ""

if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "✅ Generated.xcconfig 已重新生成"
    echo "📁 文件内容预览："
    head -5 ios/Flutter/Generated.xcconfig
else
    echo "❌ Generated.xcconfig 仍然不存在"
fi

echo ""
echo "📋 如果问题仍然存在，请尝试："
echo ""
echo "1. 删除Xcode缓存："
echo "   rm -rf ~/Library/Developer/Xcode/DerivedData"
echo ""
echo "2. 重新打开Xcode项目："
echo "   open ios/Runner.xcworkspace"
echo ""
echo "3. 在Xcode中清理构建："
echo "   Product → Clean Build Folder"
echo ""
echo "4. 重新构建："
echo "   flutter build ios --debug"
echo ""
echo "📋 验证步骤："
echo "flutter build ios --debug --no-codesign" 