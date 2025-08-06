# 儿童生长发育量表数据提取项目

## 项目简介
本项目实现了从Word文档中提取儿童生长发育量表261个评估项目的功能，建立了标准化的数据结构。

## 快速开始

### 环境要求
- Python 3.6+
- 依赖库：python-docx, pandas

### 安装依赖
```bash
pip install python-docx pandas
```

### 运行数据提取
```bash
python3 scripts/extract_word_data.py
```

### 检查数据完整性
```bash
python3 scripts/check_duplicates.py
```

## 数据文件

- `data/assessment_items.json`: 包含261个评估项目的完整数据
- `data/assessment_methods.json`: 包含项目的操作方法数据

## 项目结构

```
growAssess/
├── data/                    # 数据文件
├── scripts/                 # 脚本文件
├── docs/                    # 原始文档
├── README.md               # 项目说明
└── 开发进度报告.md         # 详细开发报告
```

## 主要功能

1. **数据提取**: 从Word文档中提取量表项目
2. **数据清洗**: 去重、分值平分、格式标准化
3. **数据验证**: 完整性检查和重复检测
4. **数据输出**: 生成标准化的JSON格式数据

## 数据格式

每个评估项目包含以下字段：
- `id`: 项目编号
- `item_name`: 项目名称
- `category`: 发育领域（大运动、精细动作、适应能力、语言、社会行为）
- `age_group`: 月龄组
- `score`: 分值
- `is_important`: 是否为重要项目
- `can_ask_parent`: 是否可询问家长

## 开发状态

✅ 核心功能完成
- 成功提取261个项目
- 数据完整性验证通过
- 分值平分功能实现

📋 下一步计划
- 完善月龄组信息
- 优化分类准确性
- 开发可视化功能

## 联系方式

如有问题或建议，请查看 `开发进度报告.md` 获取详细信息。 