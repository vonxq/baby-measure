#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
儿童发育评估量表数据提取脚本
从markdown文档中解析测查项目数据并生成JSON文件
"""

import json
import re
import os
from typing import List, Dict, Any

def parse_markdown_table(content: str) -> List[Dict[str, Any]]:
    """
    解析markdown文档中的表格数据
    """
    items = []
    
    # 查找表格数据
    # 匹配格式：□项目编号 月龄 能区 项目描述
    pattern = r'□(\d+)\s+([^□]+)'
    matches = re.findall(pattern, content)
    
    current_age = None
    current_category = None
    
    for match in matches:
        item_id = int(match[0])
        description = match[1].strip()
        
        # 从描述中提取月龄和能区信息
        # 这里需要根据实际文档格式调整
        if '月龄' in description:
            # 提取月龄信息
            age_match = re.search(r'(\d+)月龄', description)
            if age_match:
                current_age = int(age_match.group(1))
        
        # 根据项目描述判断能区
        category = determine_category(description)
        if category:
            current_category = category
        
        # 从附录B中查找操作方法和通过要求
        operation, requirement = find_operation_requirement(content, item_id)
        
        item = {
            "id": item_id,
            "age": current_age,
            "category": current_category,
            "description": description,
            "operation": operation,
            "requirement": requirement,
            "isParentReport": "R" in description,
            "isAttention": "*" in description,
            "score": calculate_score(current_age) if current_age else 0
        }
        
        items.append(item)
    
    return items

def determine_category(description: str) -> str:
    """
    根据项目描述判断能区
    """
    categories = {
        "大运动": ["坐", "爬", "立", "走", "跑", "跳", "翻身", "扶", "站", "上楼", "下楼"],
        "精细动作": ["握", "抓", "捏", "画", "穿", "搭", "拼", "剪", "写"],
        "语言": ["说", "叫", "发音", "理解", "表达", "模仿"],
        "适应能力": ["注意", "观察", "理解", "认识", "知道", "懂得"],
        "社会行为": ["微笑", "反应", "交往", "自理", "配合", "游戏"]
    }
    
    for category, keywords in categories.items():
        for keyword in keywords:
            if keyword in description:
                return category
    
    return "未知"

def find_operation_requirement(content: str, item_id: int) -> tuple:
    """
    从附录B中查找操作方法和通过要求
    """
    # 查找项目编号对应的操作方法和通过要求
    pattern = rf'{item_id}\.\s*([^□]+)'
    matches = re.findall(pattern, content)
    
    if matches:
        text = matches[0]
        # 分离操作方法和通过要求
        parts = text.split('测查通过要求')
        if len(parts) >= 2:
            operation = parts[0].strip()
            requirement = parts[1].strip()
            return operation, requirement
    
    return "", ""

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

def generate_scale_info() -> Dict[str, Any]:
    """
    生成量表基本信息
    """
    return {
        "name": "0岁～6岁儿童发育行为评估量表（儿心量表-Ⅱ）",
        "standard": "WS/T 580—2017",
        "description": "本标准规定了0岁～6岁（未满7周岁）儿童发育行为评估量表的评估内容、测查方法、发育商参考范围以及量表的使用。",
        "categories": [
            "大运动",
            "精细动作", 
            "语言",
            "适应能力",
            "社会行为"
        ],
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
    
    # 解析数据
    print("正在解析markdown文档...")
    items = parse_markdown_table(content)
    
    if not items:
        print("警告：未找到任何测查项目数据")
        return
    
    # 生成完整的JSON数据
    scale_info = generate_scale_info()
    
    data = {
        "scaleInfo": scale_info,
        "items": items
    }
    
    # 确保data文件夹存在
    os.makedirs("data", exist_ok=True)
    
    # 保存到JSON文件
    output_file = "data/assessment_items_extracted.json"
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
    for category, count in categories.items():
        print(f"  {category}: {count} 项")
    
    print("\n月龄分布：")
    for age in sorted(ages.keys()):
        print(f"  {age}月龄: {ages[age]} 项")

if __name__ == "__main__":
    main() 