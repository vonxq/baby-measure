# 儿童发育评估应用隐私政策

这是儿童发育评估应用的隐私政策页面，用于满足App Store的隐私政策要求。

## 部署步骤

### 1. 创建GitHub仓库
1. 在GitHub上创建一个新的公开仓库，命名为 `privacy-policy`
2. 不要初始化README文件

### 2. 克隆仓库
```bash
git clone https://github.com/[您的用户名]/privacy-policy.git
cd privacy-policy
```

### 3. 添加文件
将 `index.html` 文件复制到仓库根目录

### 4. 提交并推送
```bash
git add .
git commit -m "Initial commit: Add privacy policy"
git push origin main
```

### 5. 启用GitHub Pages
1. 在GitHub仓库页面，点击 "Settings"
2. 滚动到 "Pages" 部分
3. 在 "Source" 下选择 "Deploy from a branch"
4. 选择 "main" 分支
5. 点击 "Save"

### 6. 获取URL
几分钟后，您的隐私政策将在以下URL可用：
```
https://[您的用户名].github.io/privacy-policy
```

## 在App Store Connect中使用

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择您的应用
3. 进入 "App 信息" 页面
4. 在 "隐私政策URL" 字段中填入：
   ```
   https://[您的用户名].github.io/privacy-policy
   ```

## 自定义

在部署前，请记得：
1. 将 `[您的邮箱地址]` 替换为您的实际邮箱
2. 根据需要调整隐私政策内容
3. 更新 "最后更新" 日期

## 验证

部署后，请访问您的隐私政策URL，确保页面正常显示且内容符合要求。
