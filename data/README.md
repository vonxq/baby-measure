# 数据文件夹说明

## 用途
此文件夹用于存放真实的评估量表数据，替代mock数据。

## 文件结构
```
data/
├── assessment_items.json    # 真实评估项目数据（替换mock/assessment_items.json）
├── children.json           # 儿童信息数据
└── README.md              # 本说明文件
```

## 数据格式
数据格式与mock文件夹中的格式保持一致，确保代码可以直接替换使用。

## 替换说明
当准备好真实数据后，将相应的JSON文件放入此文件夹，并修改代码中的数据加载路径从`mock/`改为`data/`即可。 