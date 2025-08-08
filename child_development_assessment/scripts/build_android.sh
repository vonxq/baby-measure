#!/usr/bin/env bash
set -euo pipefail

# 安卓打包脚本：生成可分发的 release APK
# 使用：
#   bash scripts/build_android.sh
# 产物：dist/android/child_development_assessment-<version>+<build>-<timestamp>.apk

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_DIR}"

APP_NAME="child_development_assessment"
VERSION_LINE=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
BUILD_NAME="${VERSION_LINE%%+*}"
BUILD_NUMBER="${VERSION_LINE##*+}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

DIST_DIR="${PROJECT_DIR}/dist/android"
mkdir -p "${DIST_DIR}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[错误] 未检测到 flutter 命令，请先安装 Flutter SDK 并将其加入 PATH。" >&2
  exit 1
fi

if [ -z "${ANDROID_HOME:-}" ] && ! command -v sdkmanager >/dev/null 2>&1; then
  echo "[警告] 未检测到 ANDROID_HOME 或 sdkmanager，安卓 SDK 可能未正确配置，构建可能失败。" >&2
fi

echo "[信息] 清理与获取依赖..."
flutter clean
flutter pub get

echo "[信息] 构建 release APK..."
flutter build apk --release

APK_PATH="${PROJECT_DIR}/build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "${APK_PATH}" ]; then
  echo "[错误] 未找到 APK 产物: ${APK_PATH}" >&2
  exit 1
fi

OUT_PATH="${DIST_DIR}/${APP_NAME}-${BUILD_NAME}+${BUILD_NUMBER}-${TIMESTAMP}.apk"
cp "${APK_PATH}" "${OUT_PATH}"

echo "[完成] 已生成 APK: ${OUT_PATH}"
