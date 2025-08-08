#!/usr/bin/env bash
set -euo pipefail

# iOS 打包脚本：生成 ipa 安装包（需要已配置签名与证书）
# 使用：
#   bash scripts/build_ios.sh
# 产物：dist/ios/Runner-<version>+<build>-<timestamp>.ipa

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_DIR}"

APP_NAME="Runner"
VERSION_LINE=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
BUILD_NAME="${VERSION_LINE%%+*}"
BUILD_NUMBER="${VERSION_LINE##*+}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

DIST_DIR="${PROJECT_DIR}/dist/ios"
mkdir -p "${DIST_DIR}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[错误] 未检测到 flutter 命令，请先安装 Flutter SDK 并将其加入 PATH。" >&2
  exit 1
fi

# 检查是否安装了 xcodebuild
if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "[错误] 未检测到 xcodebuild，请先安装 Xcode。" >&2
  exit 1
fi

echo "[信息] 清理与获取依赖..."
flutter clean
flutter pub get

echo "[信息] 使用 Flutter 构建 ipa（需已配置签名）..."
# --export-options-plist 可以在 ios/ExportOptions.plist 中自定义
flutter build ipa --release

# Flutter 会在 build/ios/ipa 下生成 Runner.ipa
IPA_PATH="${PROJECT_DIR}/build/ios/ipa/${APP_NAME}.ipa"
if [ ! -f "${IPA_PATH}" ]; then
  echo "[错误] 未找到 IPA 产物: ${IPA_PATH}" >&2
  echo "[提示] 请确认 iOS 签名配置正确（Xcode -> Signing & Capabilities），或改用 Xcode Archive 上传。" >&2
  exit 1
fi

OUT_PATH="${DIST_DIR}/${APP_NAME}-${BUILD_NAME}+${BUILD_NUMBER}-${TIMESTAMP}.ipa"
cp "${IPA_PATH}" "${OUT_PATH}"

echo "[完成] 已生成 IPA: ${OUT_PATH}"
