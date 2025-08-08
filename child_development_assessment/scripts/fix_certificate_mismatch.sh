#!/usr/bin/env bash
set -euo pipefail

# 证书私钥不匹配修复脚本
# 用于解决证书与私钥不匹配的问题
# 使用：bash scripts/fix_certificate_mismatch.sh

echo "🔧 证书私钥不匹配修复工具"
echo "========================"

echo "📋 当前问题分析："
echo "证书已安装但代码签名身份显示为0个有效身份"
echo "这通常是因为私钥与证书不匹配"
echo ""

echo "📋 解决方案选项："
echo ""
echo "选项1: 使用现有私钥重新生成证书"
echo "选项2: 使用Xcode自动管理证书"
echo "选项3: 删除现有证书，重新创建"
echo ""

read -p "请选择解决方案 (1/2/3): " CHOICE

case $CHOICE in
    1)
        echo ""
        echo "🔍 选项1: 使用现有私钥重新生成证书"
        echo "=================================="
        echo ""
        echo "1. 删除现有的证书"
        echo "2. 使用现有私钥重新生成CSR"
        echo "3. 在Apple Developer Console中重新创建证书"
        echo ""
        
        read -p "是否继续？(y/n): " CONTINUE
        if [[ $CONTINUE =~ ^[Yy]$ ]]; then
            echo "🗑️  删除现有证书..."
            security delete-certificate -Z "Apple Development"
            security delete-certificate -Z "iPhone Distribution"
            
            echo "📝 使用现有私钥重新生成CSR..."
            CERT_DIR="$HOME/Desktop/iOS_Certificates"
            PRIVATE_KEY="$CERT_DIR/private_key.pem"
            CSR_FILE="$CERT_DIR/CertificateSigningRequest_new.certSigningRequest"
            
            read -p "请输入您的Apple ID邮箱地址: " EMAIL
            read -p "请输入您的姓名或公司名: " COMMON_NAME
            
            openssl req -new -key "$PRIVATE_KEY" -out "$CSR_FILE" -subj "/emailAddress=$EMAIL/CN=$COMMON_NAME/C=CN"
            
            echo "✅ 新的CSR文件已生成: $CSR_FILE"
            echo ""
            echo "📋 下一步："
            echo "1. 访问 Apple Developer Console"
            echo "2. 删除旧的证书"
            echo "3. 使用新的CSR文件创建证书"
            echo "4. 下载并安装新证书"
        fi
        ;;
    2)
        echo ""
        echo "🔍 选项2: 使用Xcode自动管理证书"
        echo "=================================="
        echo ""
        echo "这是最简单的解决方案："
        echo ""
        echo "1. 打开 Xcode"
        echo "2. 打开项目: ios/Runner.xcworkspace"
        echo "3. 选择 Runner target"
        echo "4. 在 'Signing & Capabilities' 中："
        echo "   - 勾选 'Automatically manage signing'"
        echo "   - 选择您的Team"
        echo "5. Xcode会自动处理证书和私钥"
        echo ""
        echo "✅ 推荐使用此选项"
        ;;
    3)
        echo ""
        echo "🔍 选项3: 删除现有证书，重新创建"
        echo "=================================="
        echo ""
        echo "1. 删除所有现有证书"
        echo "2. 重新生成私钥和CSR"
        echo "3. 重新创建证书"
        echo ""
        
        read -p "是否继续？(y/n): " CONTINUE
        if [[ $CONTINUE =~ ^[Yy]$ ]]; then
            echo "🗑️  删除现有证书..."
            security delete-certificate -Z "Apple Development"
            security delete-certificate -Z "iPhone Distribution"
            security delete-certificate -Z "iPhone Developer"
            security delete-certificate -Z "iOS Distribution"
            
            echo "🗑️  删除现有私钥..."
            rm -f "$HOME/Desktop/iOS_Certificates/private_key.pem"
            rm -f "$HOME/Desktop/iOS_Certificates/CertificateSigningRequest.certSigningRequest"
            
            echo "📝 重新生成私钥和CSR..."
            bash scripts/create_certificates.sh
        fi
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "📋 验证步骤："
echo "1. 运行: security find-identity -v -p codesigning"
echo "2. 应该显示有效的代码签名身份"
echo "3. 运行: flutter build ios --debug"
echo ""
echo "📋 如果问题仍然存在："
echo "1. 检查Apple Developer Console中的证书状态"
echo "2. 确保私钥文件安全且未损坏"
echo "3. 考虑使用Xcode自动管理功能" 