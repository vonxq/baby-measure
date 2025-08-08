#!/usr/bin/env bash
set -euo pipefail

# iOS图标生成脚本：从原始图标生成所有需要的尺寸
# 使用：bash scripts/generate_icons.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ICON="/Users/vonxq/code/cursor/growAssess/图片/萌芽温馨.JPG"
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

echo "[信息] 处理图标，去除边框并优化尺寸..."

# 首先转换为PNG格式，去除可能的边框
sips -s format png "${SOURCE_ICON}" --out "${TEMP_DIR}/converted.png"

# 获取图片尺寸
IMAGE_INFO=$(sips -g pixelWidth -g pixelHeight "${TEMP_DIR}/converted.png")
WIDTH=$(echo "$IMAGE_INFO" | grep pixelWidth | awk '{print $2}')
HEIGHT=$(echo "$IMAGE_INFO" | grep pixelHeight | awk '{print $2}')

echo "[信息] 原始图片尺寸: ${WIDTH}x${HEIGHT}"

# 计算合适的裁剪尺寸，使用90%的区域而不是82%
CROP_SIZE=$(echo "scale=0; $WIDTH * 0.9 / 1" | bc)
OFFSET=$(echo "scale=0; ($WIDTH - $CROP_SIZE) / 2" | bc)

echo "[信息] 裁剪尺寸: ${CROP_SIZE}x${CROP_SIZE}, 偏移: ${OFFSET}"

# 裁剪中心区域，使用更大的比例
sips -c "${CROP_SIZE}" "${CROP_SIZE}" "${TEMP_DIR}/converted.png" --out "${TEMP_DIR}/cropped_icon.png"

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