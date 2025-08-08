#!/usr/bin/env bash
set -euo pipefail

# 完整代码签名修复脚本
# 用于解决代码签名身份问题
# 使用：bash scripts/fix_codesign_complete.sh

echo "🔧 完整代码签名修复工具"
echo "======================"

echo "📋 当前问题：代码签名身份显示为0个有效身份"
echo ""

# 检查当前状态
echo "🔍 检查当前代码签名状态..."
security find-identity -v -p codesigning

echo ""
echo "📋 解决方案：使用Xcode自动管理签名"
echo ""

echo "🔧 步骤1: 清理旧的签名配置..."
echo ""

# 清理Xcode缓存
echo "🧹 清理Xcode缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Developer/Xcode/Archives

# 清理Flutter缓存
echo "🧹 清理Flutter缓存..."
flutter clean

echo ""
echo "🔧 步骤2: 重新生成项目配置..."
echo ""

# 重新获取依赖
echo "📦 重新获取Flutter依赖..."
flutter pub get

# 重新安装CocoaPods
echo "📦 重新安装CocoaPods依赖..."
cd ios
pod install
cd ..

echo ""
echo "🔧 步骤3: 打开Xcode进行配置..."
echo ""

echo "📋 请在Xcode中执行以下步骤："
echo ""
echo "1. 打开项目: ios/Runner.xcworkspace"
echo "2. 选择 Runner target"
echo "3. 在 'Signing & Capabilities' 中："
echo "   - ✅ 勾选 'Automatically manage signing'"
echo "   - 选择 Team: xueqin feng"
echo "   - 确保 Bundle Identifier: com.vonxq.childDevelopmentAssessment"
echo "4. 如果显示错误，点击 'Try Automatic Fix'"
echo "5. 选择 Product → Clean Build Folder"
echo "6. 选择 Product → Build"
echo ""

read -p "完成Xcode配置后按回车继续..."

echo ""
echo "🔧 步骤4: 验证代码签名..."
echo ""

# 检查代码签名身份
echo "📋 检查代码签名身份..."
security find-identity -v -p codesigning

echo ""
echo "🔧 步骤5: 测试构建..."
echo ""

read -p "是否现在测试构建？(y/n): " TEST_BUILD
if [[ $TEST_BUILD =~ ^[Yy]$ ]]; then
    echo "🧪 开始测试构建..."
    
    # 测试构建
    flutter build ios --debug
    
    echo "✅ 构建测试完成"
else
    echo "📋 手动测试命令："
    echo "flutter build ios --debug"
fi

echo ""
echo "📋 如果问题仍然存在，请尝试："
echo ""
echo "1. 检查Apple Developer账户状态"
echo "2. 确保Apple ID已正确登录Xcode"
echo "3. 检查开发者账户权限"
echo "4. 考虑升级到付费开发者账户"
echo ""
echo "📋 验证命令："
echo "security find-identity -v -p codesigning"
echo "flutter build ios --debug" 