# 儿童发育评估应用 - iOS发布流程文档

## 📱 应用概述
- **应用名称**: 萌芽评测
- **版本**: 1.0.0
- **描述**: 基于0-6岁儿童发育行为评估量表（儿心量表-Ⅱ）的专业评估工具
- **平台**: iOS (Flutter开发)

---

## 🚀 发布前准备工作

### 1. 开发环境检查
```bash
# 检查Flutter版本
flutter --version

# 检查iOS依赖
flutter doctor

# 清理项目
cd child_development_assessment
flutter clean
flutter pub get
```

### 2. 代码质量检查
```bash
# 代码分析
flutter analyze

# 运行测试
flutter test

# iOS设备测试
flutter run --release
```

### 3. 应用配置更新

#### 修改应用信息 (`ios/Runner/Info.plist`)
```xml
<key>CFBundleDisplayName</key>
<string>儿童发育评估</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.child_development_assessment</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

#### 更新应用图标
- 准备1024x1024的应用图标
- 替换 `ios/Runner/Assets.xcassets/AppIcon.appiconset/` 中的图标文件

---

## 🍎 Apple Developer账户准备

### 1. 注册Apple Developer账户
- 访问 [Apple Developer](https://developer.apple.com/)
- 注册个人或企业开发者账户 (年费 $99)
- 等待账户审核通过

### 2. 创建App ID
1. 登录 [Apple Developer Console](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → **+** 按钮
4. 选择 **App IDs** → **Continue**
5. 填写应用信息：
   - **Description**: 儿童发育评估
   - **Bundle ID**: `com.yourcompany.child_development_assessment`
6. 选择需要的 **Capabilities** (如果应用需要特殊权限)
7. 点击 **Continue** → **Register**

### 3. 创建发布证书
1. 在 **Certificates** 部分点击 **+**
2. 选择 **iOS Distribution (App Store and Ad Hoc)**
3. 按照指引上传 CSR 文件
4. 下载并安装证书到 Keychain

### 4. 创建Provisioning Profile
1. 在 **Profiles** 部分点击 **+**
2. 选择 **App Store**
3. 选择之前创建的 App ID
4. 选择发布证书
5. 命名并下载 Provisioning Profile

---

## 📦 App Store Connect配置

### 1. 创建新应用
1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 点击 **我的App** → **+** → **新App**
3. 填写应用信息：
   - **平台**: iOS
   - **名称**: 萌芽评测
   - **主要语言**: 简体中文
   - **套装ID**: 选择之前创建的Bundle ID
   - **SKU**: `child_development_assessment_001`

### 2. 应用信息配置

#### 应用信息页面
- **名称**: 萌芽评测
- **字幕**: 专业的0-6岁儿童发育评估工具
- **描述**:
```
基于儿心量表-Ⅱ的专业儿童发育评估应用，为0-6岁儿童提供科学、准确的发育行为评估。

主要功能：
• 基于权威儿心量表-Ⅱ标准
• 覆盖五大发育能区：大运动、精细动作、语言、适应能力、社会行为
• 智能月龄计算和推荐
• 详细的发育商分析和建议
• 测评历史记录和对比
• 专业的评估报告导出

适用对象：
• 0-6岁儿童家长
• 儿童保健医生
• 早教机构工作者
• 儿童发育研究人员

评估科学：基于标准化量表，结果可信
操作简便：用户友好界面，操作直观
数据安全：本地存储，保护隐私
```

#### 关键词
```
儿童发育,发育评估,儿心量表,早期教育,儿童健康,发育商,智龄,儿童测评,发育筛查,儿保
```

#### 支持URL
- **应用支持**: `https://github.com/vonxq/baby-measure`
- **隐私政策**: 需要创建隐私政策页面

### 3. 定价与销售范围
- **价格**: 免费
- **销售范围**: 选择需要发布的国家/地区

### 4. App Review信息
- **联系信息**: 填写真实联系方式
- **演示账户**: 如需要，提供测试账号
- **备注**: 说明应用用途和特殊功能

---

## 🔨 构建和上传

### 1. 在Xcode中配置
```bash
# 打开iOS项目
cd child_development_assessment
open ios/Runner.xcworkspace
```

在Xcode中：
1. 选择 **Runner** 项目
2. 在 **Signing & Capabilities** 中：
   - 选择开发团队
   - 确认Bundle Identifier正确
   - 选择正确的Provisioning Profile
3. 设置部署目标为iOS 12.0或更高

### 2. 构建Release版本
```bash
# 构建iOS release版本
flutter build ios --release --no-codesign

# 或者使用Xcode Archive
# 在Xcode中: Product > Archive
```

### 3. 上传到App Store Connect

#### 方法一: 使用Xcode
1. 在Xcode中点击 **Product** → **Archive**
2. 等待构建完成
3. 在Organizer中选择构建版本
4. 点击 **Distribute App**
5. 选择 **App Store Connect**
6. 按照向导完成上传

#### 方法二: 使用命令行
```bash
# 安装fastlane (如果没有)
sudo gem install fastlane

# 初始化fastlane
cd ios
fastlane init

# 配置Appfile和Fastfile
# 然后运行上传
fastlane deliver
```

---

## 📋 应用审核准备

### 1. 应用截图准备
需要为不同设备准备截图：
- **iPhone 6.7"**: 1290 x 2796 pixels
- **iPhone 6.5"**: 1242 x 2688 pixels  
- **iPhone 5.5"**: 1242 x 2208 pixels
- **iPad Pro (6th Gen)**: 2048 x 2732 pixels
- **iPad Pro (2nd Gen)**: 2048 x 2732 pixels

截图建议：
- 展示主要功能界面
- 突出应用价值
- 使用简体中文界面

### 2. 应用预览视频（可选）
- 时长: 15-30秒
- 格式: MOV或MP4
- 展示核心功能使用流程

### 3. 元数据本地化
为简体中文市场准备：
- 应用名称
- 描述
- 关键词
- 截图

---

## 🚀 提交审核

### 1. 最终检查清单
- [ ] 应用信息完整
- [ ] 截图已上传
- [ ] 构建版本已选择
- [ ] 定价信息正确
- [ ] 分级评定完成
- [ ] 审核信息填写
- [ ] 隐私政策链接有效

### 2. 提交审核
1. 在App Store Connect中选择应用
2. 进入 **1.0 准备提交** 版本
3. 选择构建版本
4. 填写完所有必需信息
5. 点击 **提交以供审核**

### 3. 审核时间
- 通常需要 1-7 天
- 首次提交可能需要更长时间
- 可在App Store Connect中跟踪状态

---

## 📱 审核状态说明

### 状态类型
1. **等待审核**: 应用在队列中等待
2. **正在审核**: 苹果团队正在审核
3. **元数据被拒绝**: 需要修改应用信息
4. **二进制文件被拒绝**: 需要修改代码重新提交
5. **准备销售**: 审核通过，可以发布
6. **可供销售**: 应用已上线

### 常见拒绝原因及解决方案
1. **界面问题**: 确保适配所有屏幕尺寸
2. **功能不完整**: 确保所有功能都能正常使用
3. **隐私政策**: 必须提供隐私政策链接
4. **内容问题**: 确保内容符合App Store审核指南
5. **技术问题**: 修复崩溃和性能问题

---

## 🎉 发布后管理

### 1. 监控应用表现
- 在App Store Connect中查看下载数据
- 监控用户评价和反馈
- 检查崩溃报告

### 2. 应用更新
```bash
# 更新版本号
# 在pubspec.yaml中修改version
version: 1.0.1+2

# 重新构建和上传
flutter build ios --release
```

### 3. 用户反馈处理
- 及时回复用户评价
- 收集功能改进建议
- 修复用户报告的问题

---

## 🛠️ 开发工具建议

### 必备工具
- **Xcode**: iOS开发必需
- **Flutter**: 应用框架
- **App Store Connect**: 应用管理
- **Transporter**: 上传工具（可选）

### 可选工具
- **Fastlane**: 自动化构建和发布
- **TestFlight**: 内测分发
- **Firebase**: 数据分析和崩溃报告

---

## 📞 支持和资源

### 官方文档
- [Flutter iOS部署指南](https://docs.flutter.dev/deployment/ios)
- [App Store审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect帮助](https://help.apple.com/app-store-connect/)

### 社区资源
- [Flutter中文社区](https://flutter.cn/)
- [Apple开发者论坛](https://developer.apple.com/forums/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### 技术支持
- Apple Developer Support
- Flutter官方技术支持
- 第三方开发者服务

---

## ⚠️ 重要提醒

1. **备份重要文件**: 包括证书、密钥、项目文件
2. **测试充分**: 在真实设备上测试所有功能
3. **遵守指南**: 严格遵守App Store审核指南
4. **保持更新**: 及时更新应用以修复问题和添加功能
5. **用户隐私**: 确保符合GDPR和其他隐私法规要求

---

## 📈 成功发布后的建议

### 推广策略
1. **ASO优化**: 持续优化应用商店页面
2. **社交媒体**: 在微信、微博等平台推广
3. **专业渠道**: 联系儿科医生、早教机构
4. **用户口碑**: 鼓励满意用户评价和分享

### 长期维护
1. **定期更新**: 每月检查并修复已知问题
2. **功能扩展**: 根据用户反馈添加新功能
3. **数据分析**: 分析用户行为优化体验
4. **技术升级**: 跟随Flutter和iOS系统更新

祝你的应用发布成功！🎉