#!/bin/bash

# iOS运行脚本
# 用于在本地运行iOS应用

echo "🚀 开始运行iOS应用..."

# 检查是否在正确的目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在Flutter项目根目录下运行此脚本"
    exit 1
fi

# 检查Flutter环境
echo "📱 检查Flutter环境..."
flutter doctor

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 检查iOS设备
echo "📱 检查iOS设备..."
flutter devices

# 清理构建缓存
echo "🧹 清理构建缓存..."
flutter clean
flutter pub get

# 检查iOS模拟器
echo "📱 检查iOS模拟器..."
xcrun simctl list devices | grep "iPhone"

# 启动iOS模拟器（如果可用）
echo "📱 启动iOS模拟器..."
open -a Simulator

# 等待模拟器启动
echo "⏳ 等待模拟器启动..."
sleep 5

# 运行iOS应用
echo "🚀 运行iOS应用..."
flutter run -d ios

echo "✅ iOS应用运行完成！" 