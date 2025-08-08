#!/usr/bin/env bash
set -euo pipefail

# iOS证书创建指南脚本
# 用于重新创建iOS开发证书
# 使用：bash scripts/create_certificates.sh

echo "🔐 iOS证书创建指南"
echo "=================="

echo "📋 检查当前证书状态..."
security find-identity -v -p codesigning

echo ""
echo "📝 证书创建步骤："
echo ""

echo "🔍 步骤1: 生成证书签名请求(CSR)"
echo "=================================="

# 获取用户信息
read -p "请输入您的Apple ID邮箱地址: " EMAIL
read -p "请输入您的姓名或公司名: " COMMON_NAME

# 设置文件路径
CERT_DIR="$HOME/Desktop/iOS_Certificates"
PRIVATE_KEY="$CERT_DIR/private_key.pem"
CSR_FILE="$CERT_DIR/CertificateSigningRequest.certSigningRequest"

mkdir -p "$CERT_DIR"

echo ""
echo "📝 生成私钥..."
openssl genrsa -out "$PRIVATE_KEY" 2048

echo "📝 生成CSR文件..."
openssl req -new -key "$PRIVATE_KEY" -out "$CSR_FILE" -subj "/emailAddress=$EMAIL/CN=$COMMON_NAME/C=CN"

echo ""
echo "✅ CSR文件生成完成！"
echo "📁 文件位置: $CSR_FILE"
echo ""

echo "🔍 步骤2: 在Apple Developer Console创建证书"
echo "=========================================="
echo ""
echo "请按照以下步骤操作："
echo ""
echo "1. 访问 Apple Developer Console:"
echo "   https://developer.apple.com/account/resources/certificates/list"
echo ""
echo "2. 点击 '+' 创建新证书"
echo ""
echo "3. 选择证书类型："
echo "   - 对于测试: 选择 'iOS App Development'"
echo "   - 对于发布: 选择 'iOS Distribution' (需要付费账户)"
echo ""
echo "4. 上传刚才生成的CSR文件:"
echo "   $CSR_FILE"
echo ""
echo "5. 下载生成的证书文件(.cer)"
echo ""
echo "6. 双击.cer文件安装到钥匙串"
echo ""

read -p "完成证书创建后按回车继续..."

echo ""
echo "🔍 步骤3: 验证证书安装"
echo "========================"

# 检查证书是否安装成功
echo "📋 检查新安装的证书..."
security find-identity -v -p codesigning

echo ""
echo "🔍 步骤4: 创建配置文件"
echo "========================"
echo ""
echo "请按照以下步骤创建配置文件："
echo ""
echo "1. 访问 Apple Developer Console:"
echo "   https://developer.apple.com/account/resources/profiles/list"
echo ""
echo "2. 点击 '+' 创建新的配置文件"
echo ""
echo "3. 选择配置文件类型："
echo "   - 对于测试: 选择 'iOS App Development'"
echo "   - 对于发布: 选择 'iOS App Store' (需要付费账户)"
echo ""
echo "4. 选择App ID: com.vonxq.childDevelopmentAssessment"
echo ""
echo "5. 选择刚安装的开发证书"
echo ""
echo "6. 选择测试设备（如果需要）"
echo ""
echo "7. 下载配置文件(.mobileprovision)"
echo ""

read -p "完成配置文件创建后，请将.mobileprovision文件拖拽到终端，然后按回车: " PROFILE_PATH

if [ -f "$PROFILE_PATH" ]; then
    # 复制配置文件到项目目录
    mkdir -p "certificates"
    mkdir -p "child_development_assessment/certificates"
    cp "$PROFILE_PATH" "certificates/mobileprovision"
    cp "$PROFILE_PATH" "child_development_assessment/certificates/mobileprovision"
    echo "✅ 配置文件已复制到项目目录"
else
    echo "❌ 未找到有效的配置文件"
    exit 1
fi

echo ""
echo "🔍 步骤5: 在Xcode中配置"
echo "========================"
echo ""
echo "请在Xcode中配置以下设置："
echo ""
echo "1. 打开项目: ios/Runner.xcworkspace"
echo ""
echo "2. 选择 Runner target"
echo ""
echo "3. 在 'Signing & Capabilities' 标签页中："
echo "   - 勾选 'Automatically manage signing'"
echo "   - 选择您的Team: xueqin feng"
echo "   - 确保Bundle Identifier正确: com.vonxq.childDevelopmentAssessment"
echo ""
echo "4. 如果自动管理失败，手动选择："
echo "   - 选择刚安装的证书"
echo "   - 选择刚创建的配置文件"
echo ""

echo ""
echo "🔍 步骤6: 测试构建"
echo "=================="

read -p "是否现在进行测试构建？(y/n): " TEST_BUILD
if [[ $TEST_BUILD =~ ^[Yy]$ ]]; then
    echo "🧪 开始测试构建..."
    
    echo "清理项目..."
    flutter clean
    
    echo "获取依赖..."
    flutter pub get
    
    echo "构建iOS项目..."
    flutter build ios --debug --no-codesign
    
    echo "✅ 构建测试完成"
else
    echo "📋 手动测试命令："
    echo "flutter clean && flutter pub get && flutter build ios"
fi

echo ""
echo "🎉 证书创建流程完成！"
echo ""
echo "📋 重要提醒："
echo "   - 请妥善保管私钥文件: $PRIVATE_KEY"
echo "   - 不要删除私钥，否则证书无法使用"
echo "   - 定期备份证书和私钥"
echo ""
echo "📋 如果遇到问题："
echo "   - 运行: bash scripts/check_certificates.sh"
echo "   - 运行: bash scripts/fix_ios_certificates.sh" 