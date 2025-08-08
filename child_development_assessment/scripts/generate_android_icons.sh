#!/usr/bin/env bash
set -euo pipefail

# Android图标生成脚本：从原始图标生成所有需要的尺寸
# 使用：bash scripts/generate_android_icons.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ICON="/Users/vonxq/code/cursor/growAssess/图片/萌芽图标.JPG"

echo "[信息] 开始处理Android应用图标..."

# 检查源文件是否存在
if [ ! -f "${SOURCE_ICON}" ]; then
  echo "[错误] 源图标文件不存在: ${SOURCE_ICON}" >&2
  exit 1
fi

# 创建临时工作目录
TEMP_DIR="/tmp/android_icon_processing_$$"
mkdir -p "${TEMP_DIR}"

echo "[信息] 处理图标，去除边框并优化尺寸..."

# 首先转换为PNG格式，去除可能的边框
sips -s format png "${SOURCE_ICON}" --out "${TEMP_DIR}/converted.png"

# 获取图片尺寸
IMAGE_INFO=$(sips -g pixelWidth -g pixelHeight "${TEMP_DIR}/converted.png")
WIDTH=$(echo "$IMAGE_INFO" | grep pixelWidth | awk '{print $2}')
HEIGHT=$(echo "$IMAGE_INFO" | grep pixelHeight | awk '{print $2}')

echo "[信息] 原始图片尺寸: ${WIDTH}x${HEIGHT}"

# 计算合适的裁剪尺寸，使用90%的区域
CROP_SIZE=$(echo "scale=0; $WIDTH * 0.9 / 1" | bc)
OFFSET=$(echo "scale=0; ($WIDTH - $CROP_SIZE) / 2" | bc)

echo "[信息] 裁剪尺寸: ${CROP_SIZE}x${CROP_SIZE}, 偏移: ${OFFSET}"

# 裁剪中心区域，使用更大的比例
sips -c "${CROP_SIZE}" "${CROP_SIZE}" "${TEMP_DIR}/converted.png" --out "${TEMP_DIR}/cropped_icon.png"

echo "[信息] 生成各种尺寸的Android图标..."

# Android mipmap-hdpi (72x72)
echo "  生成 mipmap-hdpi/ic_launcher.png (72x72)"
sips -z 72 72 "${TEMP_DIR}/cropped_icon.png" --out "${PROJECT_DIR}/android/app/src/main/res/mipmap-hdpi/ic_launcher.png"

# Android mipmap-mdpi (48x48)
echo "  生成 mipmap-mdpi/ic_launcher.png (48x48)"
sips -z 48 48 "${TEMP_DIR}/cropped_icon.png" --out "${PROJECT_DIR}/android/app/src/main/res/mipmap-mdpi/ic_launcher.png"

# Android mipmap-xhdpi (96x96)
echo "  生成 mipmap-xhdpi/ic_launcher.png (96x96)"
sips -z 96 96 "${TEMP_DIR}/cropped_icon.png" --out "${PROJECT_DIR}/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"

# Android mipmap-xxhdpi (144x144)
echo "  生成 mipmap-xxhdpi/ic_launcher.png (144x144)"
sips -z 144 144 "${TEMP_DIR}/cropped_icon.png" --out "${PROJECT_DIR}/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"

# Android mipmap-xxxhdpi (192x192)
echo "  生成 mipmap-xxxhdpi/ic_launcher.png (192x192)"
sips -z 192 192 "${TEMP_DIR}/cropped_icon.png" --out "${PROJECT_DIR}/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"

# 清理临时文件
rm -rf "${TEMP_DIR}"

echo "[完成] Android图标生成完成！"
echo "[说明] 所有Android应用图标已替换到: ${PROJECT_DIR}/android/app/src/main/res/mipmap-*/"
echo "[提示] 请在Android Studio中检查图标是否正确显示"
