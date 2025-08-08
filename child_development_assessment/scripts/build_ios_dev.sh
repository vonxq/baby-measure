#!/usr/bin/env bash
set -euo pipefail

# iOS 开发版本打包脚本：适用于免费Apple ID账户
# 使用：
#   bash scripts/build_ios_dev.sh
# 产物：通过Xcode Archive手动分发

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_DIR}"

APP_NAME="Runner"
VERSION_LINE=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
BUILD_NAME="${VERSION_LINE%%+*}"
BUILD_NUMBER="${VERSION_LINE##*+}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if ! command -v flutter >/dev/null 2>&1; then
  echo "[错误] 未检测到 flutter 命令，请先安装 Flutter SDK 并将其加入 PATH。" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "[错误] 未检测到 xcodebuild，请先安装 Xcode。" >&2
  exit 1
fi

echo "[信息] 清理与获取依赖..."
flutter clean
flutter pub get

echo "[信息] 构建iOS Release版本（免费账户）..."
# 使用 --no-codesign 避免发布证书问题
flutter build ios --release --no-codesign

echo "[信息] 开始Archive过程..."
# 在Xcode中创建Archive
cd ios
xcodebuild archive \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath "${PROJECT_DIR}/build/ios/archive/${APP_NAME}-${TIMESTAMP}.xcarchive" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

ARCHIVE_PATH="${PROJECT_DIR}/build/ios/archive/${APP_NAME}-${TIMESTAMP}.xcarchive"

if [ -d "${ARCHIVE_PATH}" ]; then
  echo "[完成] Archive已生成: ${ARCHIVE_PATH}"
  echo "[说明] 请在Xcode Organizer中打开此Archive："
  echo "       open '${ARCHIVE_PATH}'"
  echo "[分发] 在Organizer中选择 'Distribute App' -> 'Development' 来创建IPA"
  
  # 自动打开Archive
  open "${ARCHIVE_PATH}"
else
  echo "[错误] Archive生成失败" >&2
  exit 1
fi
