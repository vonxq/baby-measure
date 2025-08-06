# Excel数据转换脚本

这个脚本用于从docs文件夹中的Excel文件读取数据并生成符合assessment_data.json格式的JSON文件。

## 功能

- 自动读取docs文件夹中的所有Excel文件
- 解析评估量表数据（表A.1）
- 解析操作方法和测查要求（表B.1）
- 生成符合Flutter应用格式的JSON数据
- 自动处理月龄、能区、测试项目等信息

## 安装依赖

```bash
cd scripts
pip install -r requirements.txt
```

## 使用方法

```bash
cd scripts
python excel_to_json.py
```

## 输出

脚本会在 `child_development_assessment/assets/data/assessment_data.json` 生成符合以下格式的JSON文件：

```json
[
  {
    "ageMonth": 1,
    "area": "motor",
    "score": 1.0,
    "testItems": [
      {
        "id": 101,
        "name": "俯卧抬头",
        "desc": "宝宝俯卧时能抬头",
        "operation": "让宝宝俯卧，用玩具逗引抬头",
        "passCondition": "能抬头离开床面"
      }
    ]
  }
]
```

## 数据格式说明

- `ageMonth`: 月龄（整数）
- `area`: 能区（motor/fineMotor/language/adaptive/social）
- `score`: 计分（根据月龄确定）
- `testItems`: 测试项目列表
  - `id`: 项目ID
  - `name`: 项目名称
  - `desc`: 项目描述
  - `operation`: 操作方法
  - `passCondition`: 通过要求

## 计分规则

- 1-12月龄：每个能区1.0分
- 15-36月龄：每个能区3.0分
- 42-84月龄：每个能区6.0分

## 注意事项

1. Excel文件需要包含必要的列（月龄、能区、测试项目等）
2. 脚本会自动识别列名中的关键词
3. 支持中文能区名称的自动映射
4. 生成的JSON文件会按月龄和能区排序 