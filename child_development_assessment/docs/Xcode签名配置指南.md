# Xcode签名配置指南

## 当前问题
构建时出现代码签名错误：
```
Failed to codesign ... with identity D85E6199E1225F6E33409F7ED13480EBEDCBACF1
```

代码签名身份显示为0个有效身份，说明Xcode自动签名配置有问题。

## 详细解决步骤

### 步骤1: 在Xcode中检查签名配置

1. **打开项目**
   - 确保已打开 `ios/Runner.xcworkspace`

2. **选择正确的target**
   - 在左侧项目导航器中选择 **Runner** 项目
   - 选择 **Runner** target（不是RunnerTests）

3. **检查签名设置**
   - 点击 **"Signing & Capabilities"** 标签页
   - 查看当前配置状态

### 步骤2: 重新配置自动签名

1. **启用自动管理**
   - ✅ 勾选 **"Automatically manage signing"**
   - 选择 **Team**: `xueqin feng`
   - 确保 **Bundle Identifier** 正确: `com.vonxq.childDevelopmentAssessment`

2. **如果显示错误**
   - 点击 **"Try Automatic Fix"** 按钮
   - 如果失败，点击 **"Download Manual Profiles"**

### 步骤3: 手动重置签名配置

如果自动修复失败，请：

1. **取消自动管理**
   - 取消勾选 "Automatically manage signing"
   - 等待几秒钟

2. **重新启用自动管理**
   - 重新勾选 "Automatically manage signing"
   - 选择正确的Team
   - 让Xcode重新生成所有配置

### 步骤4: 清理和重新构建

1. **清理项目**
   - 在Xcode中选择 **Product** → **Clean Build Folder**
   - 或者按 `Cmd + Shift + K`

2. **重新构建**
   - 选择 **Product** → **Build**
   - 或者按 `Cmd + B`

### 步骤5: 验证配置

在终端中运行：
```bash
security find-identity -v -p codesigning
```

应该显示类似：
```
1) 1234567890ABCDEF1234567890ABCDEF12345678 "Apple Development: xueqin feng (X3CFM9KDVF)"
    1 valid identity found
```

## 常见问题和解决方案

### 问题1: "No signing certificate found"
**解决**: 
- 确保选择了正确的Team
- 检查Apple Developer账户状态
- 重新启用自动管理

### 问题2: "Provisioning profile not found"
**解决**:
- 点击 "Download Manual Profiles"
- 或者让Xcode自动创建配置文件

### 问题3: "Bundle identifier conflicts"
**解决**:
- 确保Bundle Identifier唯一
- 检查是否与其他项目冲突

### 问题4: "Team not found"
**解决**:
- 确保Apple ID已登录
- 检查开发者账户状态
- 重新登录Apple ID

## 命令行验证步骤

完成Xcode配置后，运行以下命令验证：

```bash
# 检查代码签名身份
security find-identity -v -p codesigning

# 清理项目
flutter clean

# 获取依赖
flutter pub get

# 测试构建
flutter build ios --debug
```

## 如果问题仍然存在

1. **检查Apple Developer账户**
   - 访问 https://developer.apple.com/account/
   - 确认账户状态和权限

2. **重置Xcode设置**
   - 删除 `~/Library/Developer/Xcode/DerivedData`
   - 重启Xcode

3. **重新安装证书**
   - 在钥匙串访问中删除所有iOS证书
   - 让Xcode重新生成

## 重要提醒

- 确保使用正确的Apple ID登录Xcode
- 确保开发者账户有效且未过期
- 确保Bundle Identifier与Apple Developer Console中的App ID匹配
- 如果只是测试，使用Development证书即可 