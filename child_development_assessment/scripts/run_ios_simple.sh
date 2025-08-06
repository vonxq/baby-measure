#!/bin/bash

# 简化iOS运行脚本
echo "🚀 开始运行iOS应用..."

# 检查是否在正确的目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在Flutter项目根目录下运行此脚本"
    exit 1
fi

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 检查可用设备
echo "📱 检查可用设备..."
flutter devices

# 运行iOS应用（使用具体的设备ID）
echo "🚀 运行iOS应用..."
flutter run -d 1C96C458-B3A5-490E-9963-F23BBFB2DE08

echo "✅ iOS应用运行完成！" 