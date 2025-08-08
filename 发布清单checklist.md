# 📋 iOS应用发布快速清单

## 🎯 发布前必做 (Pre-Release)

### ✅ 开发环境
- [ ] `flutter doctor` 检查无错误
- [ ] `flutter analyze` 代码分析通过
- [ ] `flutter test` 测试通过
- [ ] 真机测试功能完整

### ✅ 应用信息
- [ ] 修改Bundle ID: `com.yourcompany.child_development_assessment`
- [ ] 更新版本号: `1.0.0` (pubspec.yaml)
- [ ] 准备1024x1024应用图标
- [ ] 替换默认启动屏幕

### ✅ Apple Developer
- [ ] 注册Apple Developer账户 ($99/年)
- [ ] 创建App ID
- [ ] 生成发布证书
- [ ] 创建Provisioning Profile

---

## 🏪 App Store Connect设置

### ✅ 创建应用
- [ ] 应用名称: **儿童发育评估**
- [ ] Bundle ID: 选择已创建的ID
- [ ] SKU: `child_development_assessment_001`

### ✅ 应用描述
```
基于儿心量表-Ⅱ的专业儿童发育评估应用，为0-6岁儿童提供科学、准确的发育行为评估。

主要功能：
• 基于权威儿心量表-Ⅱ标准
• 覆盖五大发育能区
• 智能月龄计算和推荐  
• 详细的发育商分析和建议
• 测评历史记录和对比
```

### ✅ 关键词
```
儿童发育,发育评估,儿心量表,早期教育,儿童健康,发育商,智龄,儿童测评
```

### ✅ 截图准备
- [ ] iPhone 6.7": 1290 x 2796 pixels (至少3张)
- [ ] iPhone 6.5": 1242 x 2688 pixels (至少3张)
- [ ] iPad Pro: 2048 x 2732 pixels (至少3张)

---

## 🔨 构建上传

### ✅ Xcode配置
```bash
cd child_development_assessment
open ios/Runner.xcworkspace
```
- [ ] 选择开发团队
- [ ] 确认Bundle Identifier
- [ ] 设置Provisioning Profile
- [ ] 部署目标设为iOS 12.0+

### ✅ 构建发布版本
- [ ] Product → Archive
- [ ] 等待构建完成
- [ ] Distribute App → App Store Connect
- [ ] 上传成功

---

## 📋 审核提交

### ✅ 最终检查
- [ ] 选择构建版本
- [ ] 应用信息完整
- [ ] 截图已上传
- [ ] 分级评定完成
- [ ] 审核联系信息填写

### ✅ 隐私政策 (必需)
创建简单隐私政策页面，包含：
- 数据收集说明
- 本地存储声明
- 联系方式

### ✅ 提交审核
- [ ] 点击"提交以供审核"
- [ ] 等待审核 (通常1-7天)

---

## 🎉 发布后

### ✅ 监控
- [ ] 查看App Store Connect数据
- [ ] 关注用户评价
- [ ] 检查崩溃报告

### ✅ 推广
- [ ] 分享到社交媒体
- [ ] 联系相关专业人士
- [ ] 收集用户反馈

---

## 🚨 常见问题解决

### 构建失败
```bash
# 清理重建
flutter clean
flutter pub get
rm -rf ios/Pods
cd ios && pod install
```

### 证书问题
- 确保证书和Provisioning Profile匹配
- 检查Bundle ID一致性
- 重新下载安装证书

### 审核被拒
- 仔细阅读拒绝原因
- 修复问题后重新提交
- 常见问题：隐私政策、界面适配、功能完整性

---

## 📱 应用信息参考

**应用名称**: 儿童发育评估  
**副标题**: 基于儿心量表-Ⅱ的专业评估工具  
**分类**: 医疗/健康健美  
**年龄分级**: 4+ (适合所有年龄)  
**价格**: 免费  

---

## 💡 小贴士

1. **第一次发布**建议预留2-3周时间
2. **截图要美观**，突出核心功能
3. **描述要详细**，说明专业性和安全性
4. **关键词要精准**，便于用户搜索
5. **保持耐心**，审核需要时间

完成这个清单后，你的应用就可以成功发布到App Store了！🚀