# 儿童发育评估助手

基于《0岁～6岁儿童发育行为评估量表》（WS/T 580—2017）开发的Flutter移动应用，用于协助专业人员进行儿童发育行为评估。

## 项目结构

```
growAssess/
├── docs/                          # 文档文件夹
│   └── 儿童生长发育量表.md        # 量表原始文档
├── data/                          # 数据文件夹
│   ├── assessment_items.json      # 手动创建的示例数据
│   └── assessment_items_improved.json  # 脚本提取的数据
├── ui/                            # 页面原型文件夹
│   ├── 01-启动页面.html          # 启动页面原型
│   ├── 02-儿童列表页面.html      # 儿童列表页面原型
│   ├── 03-测查项目页面.html      # 测查项目页面原型
│   └── 04-结果展示页面.html      # 结果展示页面原型
├── 需求文档.md                    # 项目需求文档
├── extract_data.py               # 数据提取脚本
├── extract_data_improved.py      # 改进的数据提取脚本
└── package.json                  # Node.js项目配置
```

## 功能模块

### 1. 儿童档案管理模块
- 儿童基本信息录入（姓名、性别、出生日期、民族）
- 自动计算实际月龄（精确到月龄，保留一位小数）
- 儿童档案的增删改查
- 历史评估记录查看

### 2. 智能测查系统模块
- 主测月龄自动确定
- 测查项目智能推荐
- 测查流程引导
- 测查记录实时保存

### 3. 结果计算与分析模块
- 各能区计分计算
- 智龄计算
- 发育商计算
- 发育水平评估

### 4. 数据可视化模块
- 发育曲线图
- 发育商雷达图
- 历史对比分析
- 评估报告生成

## 页面设计

### 主要页面
1. **启动页面** - 应用欢迎页面，快速开始评估
2. **儿童列表页面** - 显示所有儿童档案
3. **测查项目页面** - 显示需要测查的项目列表
4. **结果展示页面** - 显示评估的总体结果

### 页面原型
所有页面原型都在 `ui/` 文件夹中，使用HTML和CSS创建，展示基本的页面布局和交互元素。

## 数据文件

### assessment_items.json
手动创建的示例数据，包含20个测查项目的基本信息。

### assessment_items_improved.json
通过Python脚本从markdown文档中自动提取的数据，包含261个测查项目的完整信息。

## 开发工具

### 数据提取脚本
- `extract_data.py` - 基础数据提取脚本
- `extract_data_improved.py` - 改进的数据提取脚本，不硬编码数据

### 使用方法
```bash
# 运行数据提取脚本
python3 extract_data_improved.py
```

## 技术栈

- **前端框架**: Flutter
- **数据存储**: SQLite本地数据库
- **图表库**: fl_chart或syncfusion_flutter_charts
- **状态管理**: Provider或Riverpod

## 开发环境要求

- Flutter SDK
- Dart语言
- Android Studio / VS Code
- Python 3.6+ (用于数据提取)

## 数据格式

### 量表信息 (scaleInfo)
```json
{
  "name": "量表名称",
  "standard": "标准编号",
  "description": "描述信息",
  "categories": ["能区列表"],
  "ageRanges": [{"min": 1, "max": 12, "score": 1.0}],
  "developmentLevels": [{"min": 130, "level": "优秀"}]
}
```

### 测查项目 (items)
```json
{
  "id": 1,
  "age": 24,
  "category": "大运动",
  "description": "项目描述",
  "operation": "操作方法",
  "requirement": "通过要求",
  "isParentReport": false,
  "isAttention": false,
  "score": 6.0
}
```

## 评估标准

### 发育商参考范围
- DQ > 130：优秀
- DQ 110-129：良好
- DQ 80-109：中等
- DQ 70-79：临界偏低
- DQ < 70：智力发育障碍

### 计分规则
- 1-12月龄：每个能区1.0分
- 15-36月龄：每个能区3.0分
- 42-84月龄：每个能区6.0分

## 开发进度

- [x] 需求分析
- [x] 页面原型设计
- [x] 数据提取脚本
- [x] JSON数据文件生成
- [ ] Flutter应用开发
- [ ] 数据库设计
- [ ] 功能实现
- [ ] 测试验证

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

本项目基于MIT许可证开源。 