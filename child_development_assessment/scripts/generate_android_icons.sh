#!/usr/bin/env bash
set -euo pipefail

# Android图标生成脚本：从原始图标生成所有需要的尺寸
# 使用：bash scripts/generate_android_icons.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ICON="/Users/vonxq/code/cursor/baby-measure/图片/应用图标.JPG"

echo "[信息] 开始处理Android应用图标..."

# 检查源文件是否存在
if [ ! -f "${SOURCE_ICON}" ]; then
  echo "[错误] 源图标文件不存在: ${SOURCE_ICON}" >&2
  exit 1
fi

# 创建临时工作目录
TEMP_DIR="/tmp/android_icon_processing_$$"
mkdir -p "${TEMP_DIR}"

echo "[信息] 裁剪图标，去除边框..."
# 裁剪中心区域，去除边框（假设有效内容在中心82%区域）
CROP_SIZE=1680  # 82% of 2048
OFFSET=184      # (2048 - 1680) / 2

sips -c "${CROP_SIZE}" "${CROP_SIZE}" "${SOURCE_ICON}" --out "${TEMP_DIR}/cropped_icon.png"

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
