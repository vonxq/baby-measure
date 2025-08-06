# 数据文件夹说明

## 用途
此文件夹用于存放真实的评估量表数据，替代mock数据。

## 文件结构
```
data/
├── assessment_items.json    # 真实评估项目数据（替换mock/assessment_items.json）
├── assessment_methods.json # 真实操作方法和测查通过要求（替换mock/assessment_methods.json）
├── assessment_records.json # 真实基本信息和结果记录（替换mock/assessment_records.json）
└── README.md              # 本说明文件
```

## 数据格式
数据格式与mock文件夹中的格式保持一致，确保代码可以直接替换使用。

## 替换说明
当准备好真实数据后，将相应的JSON文件放入此文件夹，并修改代码中的数据加载路径从`mock/`改为`data/`即可。

## 数据来源
- 表A.1：0岁～6岁儿童发育行为评估量表（儿心量表-Ⅱ）
- 表B.1：操作方法和测查通过要求
- 表A.2：基本信息和结果记录 