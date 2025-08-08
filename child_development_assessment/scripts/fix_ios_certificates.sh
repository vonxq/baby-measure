#!/usr/bin/env bash
set -euo pipefail

# iOS证书问题修复脚本
# 用于解决证书和配置文件问题
# 使用：bash scripts/fix_ios_certificates.sh

echo "🔧 iOS证书问题修复工具"
echo "======================="

# 清理旧的证书和缓存
echo "🧹 清理旧的证书和缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Developer/Xcode/Archives
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport
rm -rf ~/Library/Developer/Xcode/UserData/IDEPreferencesController.xcuserstate

# 清理钥匙串中的旧证书
echo "🔐 清理钥匙串中的旧证书..."
security delete-certificate -Z "iPhone Developer" 2>/dev/null || true
security delete-certificate -Z "Apple Development" 2>/dev/null || true
security delete-certificate -Z "iPhone Distribution" 2>/dev/null || true
security delete-certificate -Z "iOS Distribution" 2>/dev/null || true

# 清理项目中的证书文件
echo "📁 清理项目证书文件..."
rm -rf certificates/mobileprovision 2>/dev/null || true
rm -rf child_development_assessment/certificates/mobileprovision 2>/dev/null || true

echo "✅ 清理完成！"
echo ""
echo "📋 问题分析和解决方案："
echo ""
echo "🔍 问题1: 'You already have a current Distribution Managed certificate'"
echo "   解决: 在Apple Developer Console中删除旧的Distribution证书"
echo "   链接: https://developer.apple.com/account/resources/certificates/list"
echo ""
echo "🔍 问题2: 'No signing certificate iOS Distribution found'"
echo "   解决: 创建新的Distribution证书"
echo "   步骤: 在Apple Developer Console中创建新的iOS Distribution证书"
echo ""
echo "🔍 问题3: 'Team does not have permission to create iOS App Store profiles'"
echo "   解决: 检查账户权限或使用Development证书"
echo "   选项1: 联系Apple Developer Support升级账户权限"
echo "   选项2: 使用Development证书进行测试"
echo ""
echo "🔍 问题4: 'No profiles for com.vonxq.childDevelopmentAssessment'"
echo "   解决: 创建新的配置文件"
echo "   步骤: 在Apple Developer Console中创建新的Provisioning Profile"
echo ""
echo "📋 推荐操作步骤："
echo ""
echo "1. 访问 Apple Developer Console:"
echo "   https://developer.apple.com/account/"
echo ""
echo "2. 检查账户状态和权限"
echo "   - 确认账户是否有效"
echo "   - 检查是否有App Store Connect权限"
echo ""
echo "3. 管理证书："
echo "   - 删除旧的Distribution证书"
echo "   - 创建新的Development证书（用于测试）"
echo "   - 创建新的Distribution证书（用于发布）"
echo ""
echo "4. 创建配置文件："
echo "   - 为Development创建配置文件"
echo "   - 为Distribution创建配置文件"
echo ""
echo "5. 在Xcode中配置："
echo "   - 打开 ios/Runner.xcworkspace"
echo "   - 选择正确的Team"
echo "   - 选择正确的证书和配置文件"
echo ""
echo "6. 测试构建："
echo "   flutter clean && flutter pub get && flutter build ios"
echo ""
echo "⚠️  重要提醒："
echo "   - 确保Bundle ID正确: com.vonxq.childDevelopmentAssessment"
echo "   - 如果只是测试，使用Development证书即可"
echo "   - 如果需要发布到App Store，需要Distribution证书和相应权限" 