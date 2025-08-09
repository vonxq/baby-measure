#!/usr/bin/env bash
set -euo pipefail

# 快速调整 Flutter 项目的 build 号（仅修改 pubspec.yaml 的 +buildNumber 部分）
# 使用：
#   bash scripts/bump_build.sh <build_number> [--no-commit] [--verify-ios]
# 示例：
#   bash scripts/bump_build.sh 3 --verify-ios

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBSPEC_FILE="${PROJ_DIR}/pubspec.yaml"

if [[ $# -lt 1 ]]; then
  echo "用法：bash scripts/bump_build.sh <build_number> [--no-commit] [--verify-ios]" >&2
  exit 1
fi

NEW_BUILD="$1"; shift || true
DO_COMMIT=1
VERIFY_IOS=0

while (("$#")); do
  case "$1" in
    --no-commit)
      DO_COMMIT=0
      ;;
    --verify-ios)
      VERIFY_IOS=1
      ;;
    *)
      echo "未知参数：$1" >&2; exit 1;
      ;;
  esac
  shift || true
done

if ! [[ "$NEW_BUILD" =~ ^[0-9]+$ ]]; then
  echo "错误：build 号必须为正整数" >&2
  exit 1
fi

if [[ ! -f "$PUBSPEC_FILE" ]]; then
  echo "未找到 pubspec.yaml：$PUBSPEC_FILE" >&2
  exit 1
fi

# 读取当前 version 行
CURRENT_LINE=$(sed -n 's/^version:[[:space:]]*//p' "$PUBSPEC_FILE" | head -n 1)
if [[ -z "$CURRENT_LINE" ]]; then
  echo "未在 pubspec.yaml 中找到 version 字段" >&2
  exit 1
fi

# 拆分版本名与 build 号
if [[ "$CURRENT_LINE" == *+* ]]; then
  VERSION_NAME="${CURRENT_LINE%%+*}"
else
  VERSION_NAME="$CURRENT_LINE"
fi

NEW_VERSION_LINE="version: ${VERSION_NAME}+${NEW_BUILD}"

echo "当前 version: $CURRENT_LINE"
echo "更新为      : ${VERSION_NAME}+${NEW_BUILD}"

# 替换 pubspec.yaml 中的版本行（兼容 macOS BSD sed）
sed -i '' -E "s/^version:[[:space:]]*.*/${NEW_VERSION_LINE//\//\\\/}/" "$PUBSPEC_FILE"

pushd "$PROJ_DIR" >/dev/null

echo "执行 flutter pub get..."
flutter pub get >/dev/null

if [[ $VERIFY_IOS -eq 1 ]]; then
  echo "验证 iOS debug 构建...（如不需要可移除 --verify-ios）"
  flutter build ios --debug >/dev/null
fi

if [[ $DO_COMMIT -eq 1 ]]; then
  git add pubspec.yaml
  git commit -m "版本号更新：${VERSION_NAME}+${NEW_BUILD}（build=${NEW_BUILD}）" || true
  echo "已提交版本修改。"
else
  echo "已更新 pubspec.yaml，但未提交（--no-commit）。"
fi

echo "完成。当前版本：${VERSION_NAME}+${NEW_BUILD}"

popd >/dev/null

