#!/usr/bin/env bash
set -euo pipefail

# 快速调整 Flutter 项目的 build 号（仅修改 pubspec.yaml 的 +buildNumber 部分）
# 使用：
#   bash scripts/bump_build.sh [inc] [--no-commit]
#  - 不传 inc 时，默认自增 +1
#  - 传入 inc（正整数）时，按增量自增（如传 5 表示 +5）
# 每次更新后会自动执行 `flutter build ios`，如需跳过构建，可手动修改脚本或临时注释。

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBSPEC_FILE="${PROJ_DIR}/pubspec.yaml"

INC=1
DO_COMMIT=1

while (("$#")); do
  case "$1" in
    --no-commit)
      DO_COMMIT=0
      ;;
    [0-9]*)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        INC="$1"
      else
        echo "错误：增量 inc 必须为正整数" >&2
        exit 1
      fi
      ;;
    *)
      echo "未知参数：$1" >&2; exit 1;
      ;;
  esac
  shift || true
done

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
CURRENT_BUILD=0
if [[ "$CURRENT_LINE" == *+* ]]; then
  VERSION_NAME="${CURRENT_LINE%%+*}"
  CURRENT_BUILD="${CURRENT_LINE##*+}"
else
  VERSION_NAME="$CURRENT_LINE"
fi

if ! [[ "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
  echo "警告：当前 build 号无法识别（$CURRENT_BUILD），按 0 处理" >&2
  CURRENT_BUILD=0
fi

NEW_BUILD=$((CURRENT_BUILD + INC))
NEW_VERSION_LINE="version: ${VERSION_NAME}+${NEW_BUILD}"

echo "当前 version: $CURRENT_LINE (build=$CURRENT_BUILD)"
echo "增量 inc    : +$INC"
echo "更新为      : ${VERSION_NAME}+${NEW_BUILD}"

# 替换 pubspec.yaml 中的版本行（兼容 macOS BSD sed）
sed -i '' -E "s/^version:[[:space:]]*.*/${NEW_VERSION_LINE//\//\\\/}/" "$PUBSPEC_FILE"

pushd "$PROJ_DIR" >/dev/null

echo "执行 flutter pub get..."
flutter pub get >/dev/null

echo "开始 iOS 构建（flutter build ios）..."
flutter build ios >/dev/null

if [[ $DO_COMMIT -eq 1 ]]; then
  git add pubspec.yaml
  git commit -m "版本号更新：${VERSION_NAME}+${NEW_BUILD}（build+=${INC}→${NEW_BUILD}）" || true
  echo "已提交版本修改。"
else
  echo "已更新 pubspec.yaml，但未提交（--no-commit）。"
fi

echo "完成。当前版本：${VERSION_NAME}+${NEW_BUILD}"

popd >/dev/null

