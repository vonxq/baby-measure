# 儿童生长发育评估小程序

一个专为0-6岁儿童设计的生长发育评估微信小程序，帮助家长科学地跟踪和评估宝宝的发育情况。

## 项目结构

```
growAssess/
├── backend/          # 后端服务 (Node.js + Express + SQLite)
│   ├── app.js       # 主服务器文件
│   ├── database.js  # 数据库配置
│   ├── package.json # 后端依赖
│   └── routes/      # API路由
├── frontend/        # 微信小程序前端
│   ├── app.js       # 小程序入口
│   ├── pages/       # 页面文件
│   ├── utils/       # 工具函数
│   └── data/        # 评估数据
└── README.md        # 项目文档
```

## 功能特性

- 📊 **发育评估**: 基于科学标准的0-6岁儿童发育评估量表
- 👶 **宝宝管理**: 支持添加和管理多个宝宝信息
- 📈 **数据统计**: 可视化展示宝宝的发育趋势
- 📝 **评估记录**: 详细记录每次评估结果
- 🔐 **用户系统**: 安全的用户登录和身份验证

## 环境要求

### 后端环境
- Node.js >= 14.0.0
- npm >= 6.0.0

### 前端环境
- 微信开发者工具 >= 1.06.0
- 微信小程序基础库 >= 3.9.0

## 安装和配置

### 1. 克隆项目

```bash
git clone <repository-url>
cd growAssess
```

### 2. 后端配置

```bash
# 进入后端目录
cd backend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 或者启动生产服务器
npm start
```

后端服务将在 `http://localhost:3000` 启动

### 3. 前端配置

1. 打开微信开发者工具
2. 导入项目，选择 `frontend` 目录
3. 在项目设置中配置你的小程序 AppID
4. 确保后端服务正在运行

### 4. 数据库配置

项目使用 SQLite 数据库，数据库文件会在首次运行时自动创建在 `backend/` 目录下。

## API 接口

### 用户相关
- `POST /api/user/login` - 用户登录
- `GET /api/user/profile` - 获取用户信息

### 宝宝管理
- `POST /api/baby` - 创建宝宝信息
- `GET /api/baby/:id` - 获取宝宝信息
- `PUT /api/baby/:id` - 更新宝宝信息
- `DELETE /api/baby/:id` - 删除宝宝信息

### 评估相关
- `POST /api/assessment` - 提交评估结果
- `GET /api/assessment/:babyId` - 获取评估记录

### 统计相关
- `GET /api/stats/:babyId` - 获取统计数据
- `GET /api/records/:babyId` - 获取评估记录

## 开发指南

### 后端开发

1. **添加新的API路由**:
   - 在 `routes/` 目录下创建新的路由文件
   - 在 `app.js` 中注册新路由

2. **数据库操作**:
   - 修改 `database.js` 中的表结构
   - 使用 SQLite 进行数据操作

3. **环境变量**:
   - 创建 `.env` 文件配置环境变量
   - 支持 `NODE_ENV`、`PORT` 等配置

### 前端开发

1. **添加新页面**:
   - 在 `pages/` 目录下创建新页面
   - 在 `app.json` 中注册页面路由

2. **API调用**:
   - 使用 `utils/api.js` 中的方法调用后端接口
   - 确保 `baseUrl` 配置正确

3. **样式开发**:
   - 使用 WXSS 编写样式
   - 遵循微信小程序设计规范

## 部署说明

### 后端部署

1. **生产环境**:
   ```bash
   cd backend
   npm install --production
   npm start
   ```

2. **使用 PM2**:
   ```bash
   npm install -g pm2
   pm2 start app.js --name "baby-growth-api"
   ```

### 前端部署

1. 在微信开发者工具中点击"上传"
2. 在微信公众平台提交审核
3. 审核通过后发布

## 常见问题

### Q: 后端服务无法启动
A: 检查端口是否被占用，确保 Node.js 版本符合要求

### Q: 小程序无法连接后端
A: 检查 `app.js` 中的 `baseUrl` 配置，确保后端服务正在运行

### Q: 数据库连接失败
A: 检查 SQLite 数据库文件权限，确保有读写权限

## 技术栈

### 后端
- **Node.js** - 运行环境
- **Express** - Web框架
- **SQLite** - 数据库
- **CORS** - 跨域支持
- **UUID** - 唯一标识生成

### 前端
- **微信小程序** - 前端框架
- **WXML** - 模板语言
- **WXSS** - 样式语言
- **JavaScript** - 编程语言

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue
- 发送邮件至 [your-email@example.com]

---

**注意**: 本项目仅供学习和研究使用，请勿用于商业用途。 