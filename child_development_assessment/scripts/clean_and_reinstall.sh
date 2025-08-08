#!/usr/bin/env bash
set -euo pipefail

# 清理并重新安装应用脚本
# 使用：bash scripts/clean_and_reinstall.sh

echo "[信息] 开始清理并重新安装应用..."

# 1. 清理Flutter缓存
echo "[步骤1] 清理Flutter缓存..."
flutter clean

# 2. 清理Xcode缓存
echo "[步骤2] 清理Xcode缓存..."
sudo rm -rf ~/Library/Developer/Xcode/DerivedData
sudo rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 3. 清理iOS模拟器缓存
echo "[步骤3] 清理iOS模拟器缓存..."
xcrun simctl shutdown all 2>/dev/null || true
xcrun simctl erase all 2>/dev/null || true

# 4. 获取依赖
echo "[步骤4] 重新获取依赖..."
flutter pub get

# 5. 重新构建iOS应用
echo "[步骤5] 重新构建iOS应用..."
flutter build ios --debug

# 6. 运行应用
echo "[步骤6] 启动应用..."
flutter run -d ios

echo "[完成] 应用已重新安装，新图标应该生效！"
echo "[提示] 如果图标仍然显示旧版本，请尝试："
echo "  1. 重启iOS模拟器"
echo "  2. 在模拟器中删除应用后重新安装"
echo "  3. 重启Xcode"
