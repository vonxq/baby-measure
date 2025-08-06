#!/bin/bash

# 智能iOS运行脚本
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

# 自动检测iOS设备
echo "🔍 自动检测iOS设备..."
IOS_DEVICE=$(flutter devices | grep "ios" | head -1 | awk '{print $2}' | sed 's/•//' | tr -d ' ')

if [ -z "$IOS_DEVICE" ]; then
    echo "❌ 未找到iOS设备，尝试启动模拟器..."
    open -a Simulator
    sleep 10
    IOS_DEVICE=$(flutter devices | grep "ios" | head -1 | awk '{print $2}' | sed 's/•//' | tr -d ' ')
fi

if [ -z "$IOS_DEVICE" ]; then
    echo "❌ 仍然未找到iOS设备，请手动启动模拟器"
    exit 1
fi

echo "📱 找到iOS设备: $IOS_DEVICE"

# 运行iOS应用
echo "🚀 运行iOS应用..."
flutter run -d "$IOS_DEVICE"

echo "✅ iOS应用运行完成！" 