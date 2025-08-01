#!/bin/bash

# 儿童生长发育评估小程序后端启动脚本

echo "🚀 启动儿童生长发育评估后端服务..."

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到Node.js，请先安装Node.js"
    exit 1
fi

# 检查npm是否安装
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未找到npm，请先安装npm"
    exit 1
fi

# 显示Node.js和npm版本
echo "📋 环境信息:"
echo "   Node.js版本: $(node --version)"
echo "   npm版本: $(npm --version)"

# 检查是否在正确的目录
if [ ! -f "package.json" ]; then
    echo "❌ 错误: 请在backend目录下运行此脚本"
    exit 1
fi

# 检查依赖是否安装
if [ ! -d "node_modules" ]; then
    echo "📦 安装依赖包..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ 依赖安装失败"
        exit 1
    fi
fi

# 检查端口是否被占用
PORT=3000
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  警告: 端口 $PORT 已被占用"
    echo "   正在尝试终止占用进程..."
    lsof -ti:$PORT | xargs kill -9 2>/dev/null
    sleep 2
fi

# 启动服务器
echo "🌐 启动服务器..."
echo "   服务地址: http://localhost:$PORT"
echo "   健康检查: http://localhost:$PORT/health"
echo "   按 Ctrl+C 停止服务"
echo ""

# 根据环境变量选择启动模式
if [ "$NODE_ENV" = "production" ]; then
    echo "🏭 生产模式启动"
    npm start
else
    echo "🔧 开发模式启动 (支持热重载)"
    npm run dev
fi 