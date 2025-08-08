#!/usr/bin/env bash
set -euo pipefail

# 证书检查和分析脚本
# 用于辨别错误的证书
# 使用：bash scripts/check_certificates.sh

echo "🔍 iOS证书检查和分析工具"
echo "========================"

echo "📋 检查钥匙串中的证书..."
echo ""

# 检查所有代码签名证书
echo "🔐 当前安装的代码签名证书："
security find-identity -v -p codesigning

echo ""
echo "📋 检查证书详细信息..."

# 获取证书列表并检查详细信息
CERTIFICATES=$(security find-identity -v -p codesigning | grep -E "iPhone|Apple|iOS" | awk '{print $2}' | sed 's/"//g')

if [ -z "$CERTIFICATES" ]; then
    echo "❌ 未找到任何iOS证书"
    echo ""
    echo "📋 建议："
    echo "1. 在Apple Developer Console中创建新证书"
    echo "2. 下载并安装证书到钥匙串"
    echo "3. 重新运行此脚本检查"
    exit 1
fi

echo "🔍 分析证书状态..."
echo ""

for cert in $CERTIFICATES; do
    echo "📄 证书: $cert"
    
    # 检查证书是否有效
    if security find-certificate -c "$cert" -p codesigning >/dev/null 2>&1; then
        echo "   ✅ 状态: 有效"
        
        # 获取证书详细信息
        CERT_INFO=$(security find-certificate -c "$cert" -p codesigning | openssl x509 -text -noout 2>/dev/null)
        
        # 提取证书类型
        if echo "$CERT_INFO" | grep -q "iPhone Developer"; then
            echo "   📱 类型: iPhone Developer (开发证书)"
        elif echo "$CERT_INFO" | grep -q "iPhone Distribution"; then
            echo "   📦 类型: iPhone Distribution (发布证书)"
        elif echo "$CERT_INFO" | grep -q "Apple Development"; then
            echo "   🍎 类型: Apple Development (开发证书)"
        elif echo "$CERT_INFO" | grep -q "iOS Distribution"; then
            echo "   📱 类型: iOS Distribution (发布证书)"
        else
            echo "   ❓ 类型: 未知"
        fi
        
        # 提取过期时间
        EXPIRY=$(echo "$CERT_INFO" | grep "Not After" | head -1 | sed 's/.*Not After : //')
        if [ -n "$EXPIRY" ]; then
            echo "   ⏰ 过期时间: $EXPIRY"
        fi
        
        # 提取主题信息
        SUBJECT=$(echo "$CERT_INFO" | grep "Subject:" | head -1 | sed 's/.*Subject: //')
        if [ -n "$SUBJECT" ]; then
            echo "   👤 主题: $SUBJECT"
        fi
        
    else
        echo "   ❌ 状态: 无效或已损坏"
    fi
    
    echo ""
done

echo "🔍 检查证书问题..."

# 检查常见问题
echo "📋 常见证书问题检查："
echo ""

# 检查是否有过期的证书
echo "1. 检查过期证书..."
EXPIRED_CERTS=$(security find-identity -v -p codesigning 2>&1 | grep "expired" || true)
if [ -n "$EXPIRED_CERTS" ]; then
    echo "   ❌ 发现过期证书："
    echo "$EXPIRED_CERTS"
else
    echo "   ✅ 未发现过期证书"
fi

# 检查是否有撤销的证书
echo ""
echo "2. 检查撤销证书..."
REVOKED_CERTS=$(security find-identity -v -p codesigning 2>&1 | grep "revoked" || true)
if [ -n "$REVOKED_CERTS" ]; then
    echo "   ❌ 发现撤销证书："
    echo "$REVOKED_CERTS"
else
    echo "   ✅ 未发现撤销证书"
fi

# 检查私钥问题
echo ""
echo "3. 检查私钥问题..."
NO_PRIVATE_KEY=$(security find-identity -v -p codesigning 2>&1 | grep "private key" || true)
if [ -n "$NO_PRIVATE_KEY" ]; then
    echo "   ❌ 发现私钥问题："
    echo "$NO_PRIVATE_KEY"
else
    echo "   ✅ 未发现私钥问题"
fi

echo ""
echo "📋 证书清理建议："
echo ""

# 提供清理建议
echo "🔧 如果发现错误证书，可以运行以下命令清理："
echo ""
echo "1. 删除特定证书："
echo "   security delete-certificate -Z '证书名称'"
echo ""
echo "2. 删除所有iOS证书："
echo "   security delete-certificate -Z 'iPhone Developer'"
echo "   security delete-certificate -Z 'Apple Development'"
echo "   security delete-certificate -Z 'iPhone Distribution'"
echo "   security delete-certificate -Z 'iOS Distribution'"
echo ""
echo "3. 运行完整清理脚本："
echo "   bash scripts/fix_ios_certificates.sh"
echo ""
echo "📋 重新创建证书步骤："
echo "1. 访问 Apple Developer Console"
echo "2. 删除旧的证书"
echo "3. 创建新的证书"
echo "4. 下载并安装到钥匙串"
echo "5. 重新运行此脚本验证" 