#!/usr/bin/env bash
set -euo pipefail

# iOS CSR文件生成脚本
# 使用：bash scripts/generate_csr.sh

echo "🔐 iOS证书签名请求(CSR)生成工具"
echo "=================================="

# 获取用户信息
read -p "请输入你的邮箱地址 (Apple ID): " EMAIL
read -p "请输入你的姓名或公司名: " COMMON_NAME

# 设置文件路径
CERT_DIR="$HOME/Desktop/iOS_Certificates"
PRIVATE_KEY="$CERT_DIR/private_key.pem"
CSR_FILE="$CERT_DIR/CertificateSigningRequest.certSigningRequest"

mkdir -p "$CERT_DIR"

echo ""
echo "📝 生成私钥..."
# 生成2048位RSA私钥
openssl genrsa -out "$PRIVATE_KEY" 2048

echo "📝 生成CSR文件..."
# 生成CSR文件
openssl req -new -key "$PRIVATE_KEY" -out "$CSR_FILE" -subj "/emailAddress=$EMAIL/CN=$COMMON_NAME/C=CN"

echo ""
echo "✅ CSR文件生成完成！"
echo ""
echo "📁 文件位置："
echo "   私钥文件: $PRIVATE_KEY"
echo "   CSR文件:  $CSR_FILE"
echo ""
echo "📋 下一步操作："
echo "   1. 在Apple Developer Console中上传CSR文件"
echo "   2. 下载生成的证书文件(.cer)"
echo "   3. 双击.cer文件安装到钥匙串"
echo ""
echo "⚠️  重要提醒："
echo "   - 请妥善保管私钥文件"
echo "   - 不要删除私钥，否则证书无法使用"
