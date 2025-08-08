#!/usr/bin/env bash
set -euo pipefail

# iOS图标生成脚本：从原始图标生成所有需要的尺寸
# 使用：bash scripts/generate_icons.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ICON="/Users/vonxq/code/cursor/growAssess/图片/萌芽图标.JPG"
ICON_DIR="${PROJECT_DIR}/ios/Runner/Assets.xcassets/AppIcon.appiconset"

echo "[信息] 开始处理应用图标..."

# 检查源文件是否存在
if [ ! -f "${SOURCE_ICON}" ]; then
  echo "[错误] 源图标文件不存在: ${SOURCE_ICON}" >&2
  exit 1
fi

# 创建临时工作目录
TEMP_DIR="/tmp/icon_processing_$$"
mkdir -p "${TEMP_DIR}"

echo "[信息] 裁剪图标，去除边框..."
# 裁剪中心区域，去除边框（假设有效内容在中心82%区域）
CROP_SIZE=1680  # 82% of 2048
OFFSET=184      # (2048 - 1680) / 2

sips -c "${CROP_SIZE}" "${CROP_SIZE}" "${SOURCE_ICON}" --out "${TEMP_DIR}/cropped_icon.png"

echo "[信息] 生成各种尺寸的图标..."

# 生成每个尺寸的图标
echo "  生成 20x20@1x"
sips -z 20 20 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-20x20@1x.png"

echo "  生成 20x20@2x"
sips -z 40 40 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-20x20@2x.png"

echo "  生成 20x20@3x"
sips -z 60 60 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-20x20@3x.png"

echo "  生成 29x29@1x"
sips -z 29 29 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-29x29@1x.png"

echo "  生成 29x29@2x"
sips -z 58 58 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-29x29@2x.png"

echo "  生成 29x29@3x"
sips -z 87 87 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-29x29@3x.png"

echo "  生成 40x40@1x"
sips -z 40 40 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-40x40@1x.png"

echo "  生成 40x40@2x"
sips -z 80 80 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-40x40@2x.png"

echo "  生成 40x40@3x"
sips -z 120 120 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-40x40@3x.png"

echo "  生成 60x60@2x"
sips -z 120 120 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-60x60@2x.png"

echo "  生成 60x60@3x"
sips -z 180 180 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-60x60@3x.png"

echo "  生成 76x76@1x"
sips -z 76 76 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-76x76@1x.png"

echo "  生成 76x76@2x"
sips -z 152 152 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-76x76@2x.png"

echo "  生成 83.5x83.5@2x"
sips -z 167 167 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-83.5x83.5@2x.png"

echo "  生成 1024x1024@1x"
sips -z 1024 1024 "${TEMP_DIR}/cropped_icon.png" --out "${ICON_DIR}/Icon-App-1024x1024@1x.png"

# 清理临时文件
rm -rf "${TEMP_DIR}"

echo "[完成] 图标生成完成！"
echo "[说明] 所有iOS应用图标已替换到: ${ICON_DIR}"
echo "[提示] 请在Xcode中检查图标是否正确显示"