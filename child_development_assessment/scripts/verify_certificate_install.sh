#!/usr/bin/env bash
set -euo pipefail

# 证书安装验证脚本
# 用于验证证书是否正确安装
# 使用：bash scripts/verify_certificate_install.sh

echo "🔍 证书安装验证工具"
echo "=================="

echo "📋 检查证书安装状态..."
echo ""

# 检查代码签名证书
echo "🔐 代码签名证书："
security find-identity -v -p codesigning

echo ""
echo "📋 检查所有证书..."
echo ""

# 检查所有证书
echo "🔍 所有证书列表："
security find-certificate -a

echo ""
echo "📋 检查钥匙串中的证书..."
echo ""

# 检查钥匙串中的证书
echo "🔍 钥匙串中的证书："
security list-keychains
security default-keychain -d user -s login.keychain

echo ""
echo "📋 检查证书文件..."
echo ""

# 检查桌面上的证书文件
CERT_DIR="$HOME/Desktop/iOS_Certificates"
if [ -d "$CERT_DIR" ]; then
    echo "📁 桌面证书目录内容："
    ls -la "$CERT_DIR"
else
    echo "❌ 桌面证书目录不存在"
fi

echo ""
echo "📋 常见安装问题检查..."
echo ""

# 检查常见问题
echo "1. 检查证书文件是否存在..."
if [ -f "$CERT_DIR/CertificateSigningRequest.certSigningRequest" ]; then
    echo "   ✅ CSR文件存在"
else
    echo "   ❌ CSR文件不存在"
fi

echo ""
echo "2. 检查私钥文件..."
if [ -f "$CERT_DIR/private_key.pem" ]; then
    echo "   ✅ 私钥文件存在"
else
    echo "   ❌ 私钥文件不存在"
fi

echo ""
echo "📋 证书安装指南..."
echo ""

echo "🔧 如果证书未正确安装，请按以下步骤操作："
echo ""
echo "1. 确保已下载证书文件(.cer)"
echo "2. 双击.cer文件安装到钥匙串"
echo "3. 在钥匙串访问中确认证书已安装"
echo "4. 重新运行此脚本验证"
echo ""
echo "📋 手动安装步骤："
echo ""
echo "1. 打开 '钥匙串访问' 应用"
echo "2. 选择 '登录' 钥匙串"
echo "3. 选择 '证书' 类别"
echo "4. 检查是否有iOS相关证书"
echo "5. 如果没有，双击.cer文件安装"
echo ""
echo "📋 验证命令："
echo "security find-identity -v -p codesigning" 