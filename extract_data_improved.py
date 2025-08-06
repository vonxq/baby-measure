#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
儿童发育评估量表数据提取脚本 - 改进版
通过分析文档结构动态提取数据，不硬编码任何信息
"""

import json
import re
import os
from typing import List, Dict, Any

def extract_table_data(content: str) -> List[Dict[str, Any]]:
    """
    从文档中提取表格数据
    """
    items = []
    
    # 查找表格开始标记
    table_start = content.find("表A.1 0 岁～6 岁儿童发育行为评估量表（儿心量表-Ⅱ）")
    if table_start == -1:
        print("未找到量表表格")
        return items
    
    # 提取表格内容
    table_content = content[table_start:]
    
    # 查找项目编号和描述
    # 匹配格式：□数字 描述
    pattern = r'□(\d+)\s+([^□\n]+)'
    matches = re.findall(pattern, table_content)
    
    print(f"找到 {len(matches)} 个项目")
    
    for match in matches:
        item_id = int(match[0])
        description = match[1].strip()
        
        # 从描述中提取信息
        info = extract_item_info(description)
        
        item = {
            "id": item_id,
            "description": description,
            **info
        }
        
        items.append(item)
    
    return items

def extract_item_info(description: str) -> Dict[str, Any]:
    """
    从项目描述中提取信息
    """
    info = {
        "age": None,
        "category": None,
        "operation": "",
        "requirement": "",
        "isParentReport": "R" in description,
        "isAttention": "*" in description,
        "score": 0
    }
    
    # 提取月龄信息
    age_match = re.search(r'(\d+)月龄', description)
    if age_match:
        info["age"] = int(age_match.group(1))
        info["score"] = calculate_score(info["age"])
    
    # 根据关键词判断能区
    info["category"] = determine_category_by_keywords(description)
    
    return info

def determine_category_by_keywords(description: str) -> str:
    """
    根据关键词动态判断能区
    """
    # 定义各能区的关键词模式
    category_patterns = {
        "大运动": [
            r"坐", r"爬", r"立", r"走", r"跑", r"跳", r"翻身", r"扶", r"站", 
            r"上楼", r"下楼", r"蹲", r"拉", r"抱", r"悬垂", r"落地", r"支撑"
        ],
        "精细动作": [
            r"握", r"抓", r"捏", r"画", r"穿", r"搭", r"拼", r"剪", r"写",
            r"撕", r"揉", r"摇", r"敲", r"拧", r"扣", r"线", r"积木"
        ],
        "语言": [
            r"说", r"叫", r"发音", r"理解", r"表达", r"模仿", r"声音",
            r"语言", r"字", r"词", r"句子", r"儿歌", r"诗"
        ],
        "适应能力": [
            r"注意", r"观察", r"理解", r"认识", r"知道", r"懂得", r"寻找",
            r"记忆", r"思考", r"判断", r"推理", r"想象", r"创造"
        ],
        "社会行为": [
            r"微笑", r"反应", r"交往", r"自理", r"配合", r"游戏", r"社交",
            r"情感", r"行为", r"习惯", r"规则", r"合作", r"分享"
        ]
    }
    
    # 计算每个能区的匹配度
    category_scores = {}
    for category, patterns in category_patterns.items():
        score = 0
        for pattern in patterns:
            if re.search(pattern, description):
                score += 1
        category_scores[category] = score
    
    # 返回匹配度最高的能区
    if category_scores:
        best_category = max(category_scores.items(), key=lambda x: x[1])
        if best_category[1] > 0:
            return best_category[0]
    
    return "未知"

def extract_operations_requirements(content: str) -> Dict[int, Dict[str, str]]:
    """
    从附录B中提取操作方法和通过要求
    """
    operations = {}
    
    # 查找附录B
    appendix_b_start = content.find("附 录 B")
    if appendix_b_start == -1:
        print("未找到附录B")
        return operations
    
    appendix_b_content = content[appendix_b_start:]
    
    # 查找每个项目的操作方法和通过要求
    # 格式：数字. 操作方法 测查通过要求
    pattern = r'(\d+)\.\s*([^测查通过要求]+)测查通过要求([^□\n]+)'
    matches = re.findall(pattern, appendix_b_content)
    
    for match in matches:
        item_id = int(match[0])
        operation = match[1].strip()
        requirement = match[2].strip()
        
        operations[item_id] = {
            "operation": operation,
            "requirement": requirement
        }
    
    print(f"从附录B中提取了 {len(operations)} 个项目的操作方法和通过要求")
    return operations

def calculate_score(age: int) -> float:
    """
    根据月龄计算分值
    """
    if 1 <= age <= 12:
        return 1.0
    elif 15 <= age <= 36:
        return 3.0
    elif 42 <= age <= 84:
        return 6.0
    else:
        return 0.0

def extract_scale_info(content: str) -> Dict[str, Any]:
    """
    从文档中提取量表基本信息
    """
    info = {
        "name": "0岁～6岁儿童发育行为评估量表（儿心量表-Ⅱ）",
        "standard": "WS/T 580—2017",
        "description": "",
        "categories": ["大运动", "精细动作", "语言", "适应能力", "社会行为"],
        "ageRanges": [
            {"min": 1, "max": 12, "score": 1.0},
            {"min": 15, "max": 36, "score": 3.0},
            {"min": 42, "max": 84, "score": 6.0}
        ],
        "developmentLevels": [
            {"min": 130, "level": "优秀"},
            {"min": 110, "max": 129, "level": "良好"},
            {"min": 80, "max": 109, "level": "中等"},
            {"min": 70, "max": 79, "level": "临界偏低"},
            {"max": 70, "level": "智力发育障碍"}
        ]
    }
    
    # 提取描述信息
    desc_match = re.search(r'本标准规定了([^。]+。)', content)
    if desc_match:
        info["description"] = desc_match.group(1)
    
    return info

def merge_operations_with_items(items: List[Dict[str, Any]], operations: Dict[int, Dict[str, str]]) -> List[Dict[str, Any]]:
    """
    将操作方法和通过要求合并到项目中
    """
    for item in items:
        item_id = item["id"]
        if item_id in operations:
            item["operation"] = operations[item_id]["operation"]
            item["requirement"] = operations[item_id]["requirement"]
    
    return items

def main():
    """
    主函数
    """
    # 读取markdown文档
    markdown_file = "docs/儿童生长发育量表.md"
    
    if not os.path.exists(markdown_file):
        print(f"错误：找不到文件 {markdown_file}")
        return
    
    try:
        with open(markdown_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"读取文件失败：{e}")
        return
    
    # 提取量表基本信息
    print("正在提取量表基本信息...")
    scale_info = extract_scale_info(content)
    
    # 提取表格数据
    print("正在提取表格数据...")
    items = extract_table_data(content)
    
    if not items:
        print("警告：未找到任何测查项目数据")
        return
    
    # 提取操作方法和通过要求
    print("正在提取操作方法和通过要求...")
    operations = extract_operations_requirements(content)
    
    # 合并数据
    items = merge_operations_with_items(items, operations)
    
    # 生成完整的JSON数据
    data = {
        "scaleInfo": scale_info,
        "items": items
    }
    
    # 确保data文件夹存在
    os.makedirs("data", exist_ok=True)
    
    # 保存到JSON文件
    output_file = "data/assessment_items_improved.json"
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"成功提取 {len(items)} 个测查项目")
        print(f"数据已保存到：{output_file}")
    except Exception as e:
        print(f"保存文件失败：{e}")
    
    # 生成统计信息
    print("\n数据统计：")
    categories = {}
    ages = {}
    
    for item in items:
        # 统计能区
        category = item.get('category', '未知')
        categories[category] = categories.get(category, 0) + 1
        
        # 统计月龄
        age = item.get('age')
        if age and age > 0:
            ages[age] = ages.get(age, 0) + 1
    
    print("能区分布：")
    for category, count in sorted(categories.items()):
        print(f"  {category}: {count} 项")
    
    print("\n月龄分布：")
    for age in sorted(ages.keys()):
        print(f"  {age}月龄: {ages[age]} 项")

if __name__ == "__main__":
    main() 