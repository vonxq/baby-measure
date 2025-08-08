#!/usr/bin/env bash
set -euo pipefail

# Xcode构建问题修复脚本
# 使用：bash scripts/fix_xcode_build.sh

echo "[信息] 开始修复Xcode构建问题..."

# 1. 清理Flutter缓存
echo "[步骤1] 清理Flutter缓存..."
flutter clean

# 2. 清理iOS相关缓存
echo "[步骤2] 清理iOS缓存..."
rm -rf ios/Pods ios/Podfile.lock
rm -rf ios/Runner.xcworkspace/xcshareddata
rm -rf ios/Runner.xcworkspace/xcuserdata

# 3. 清理Xcode缓存
echo "[步骤3] 清理Xcode缓存..."
sudo rm -rf ~/Library/Developer/Xcode/DerivedData
sudo rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 4. 重新获取Flutter依赖
echo "[步骤4] 重新获取Flutter依赖..."
flutter pub get

# 5. 重新安装CocoaPods依赖
echo "[步骤5] 重新安装CocoaPods依赖..."
cd ios
pod deintegrate 2>/dev/null || true
pod cache clean --all
pod install
cd ..

# 6. 重新构建项目
echo "[步骤6] 重新构建项目..."
flutter build ios --debug --no-codesign

echo "[完成] Xcode构建问题修复完成！"
echo "[提示] 现在可以尝试运行应用："
echo "  flutter run -d ios"
