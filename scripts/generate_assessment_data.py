#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成儿童发育评估量表数据
从Excel表格中解析数据并生成符合assessment_data.json结构的数据
"""

import pandas as pd
import json
import re
from typing import List, Dict, Any

def parse_excel_data():
    """解析Excel表格数据"""
    # 读取量表数据
    scale_df = pd.read_excel('docs/v-表A.1  0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).xlsx')
    
    # 读取操作方法数据
    operation_df = pd.read_excel('docs/v-表 B.1  0 岁～6 岁儿童发育行为评估量表（儿心量表-Ⅱ)操作方法和测查通过要求.xlsx')
    
    return scale_df, operation_df

def extract_item_info(item_text: str) -> Dict[str, Any]:
    """从项目文本中提取信息"""
    if pd.isna(item_text) or item_text == '':
        return None
    
    # 匹配项目编号和名称
    pattern = r'□(\d+)\s*(.+)'
    match = re.search(pattern, str(item_text))
    
    if match:
        item_id = int(match.group(1))
        item_name = match.group(2).strip()
        return {
            'id': item_id,
            'name': item_name
        }
    return None

def get_area_name(row_index: int, scale_df: pd.DataFrame) -> str:
    """根据行索引获取能区名称"""
    # 根据Excel表格的实际结构，每行代表一个测试项目
    # 需要从项目名称或编号推断能区
    area_mapping = {
        0: 'motor',      # 大运动
        1: 'motor',      # 大运动  
        2: 'fineMotor',  # 精细动作
        3: 'fineMotor',  # 精细动作
        4: 'adaptive',   # 适应能力
        5: 'adaptive',   # 适应能力
        6: 'language',   # 语言
        7: 'language',   # 语言
        8: 'social',     # 社会行为
        9: 'social',     # 社会行为
    }
    return area_mapping.get(row_index, 'unknown')

def get_score(age_month: int) -> float:
    """根据月龄获取分数"""
    if 1 <= age_month <= 12:
        return 1.0
    elif 15 <= age_month <= 36:
        return 3.0
    elif 42 <= age_month <= 84:
        return 6.0
    else:
        return 0.0

def find_operation_info(item_id: int, operation_df: pd.DataFrame) -> Dict[str, str]:
    """在操作方法表中查找对应的操作方法和通过要求"""
    for _, row in operation_df.iterrows():
        project_name = str(row['测查项目'])
        if project_name.startswith(str(item_id)):
            return {
                'operation': str(row['操作方法']),
                'passCondition': str(row['测查通过要求'])
            }
    return {
        'operation': '请参考标准操作方法',
        'passCondition': '请参考标准通过要求'
    }

def generate_assessment_data():
    """生成评估数据"""
    scale_df, operation_df = parse_excel_data()
    
    # 月龄列表
    age_months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84]
    
    assessment_data = []
    
    # 遍历每一行（每个测试项目）
    for row_idx in range(len(scale_df)):
        area = get_area_name(row_idx, scale_df)
        
        # 遍历每个月龄（列）
        for col_idx, age_month in enumerate(age_months):
            if col_idx + 1 >= len(scale_df.columns):
                continue
                
            col_name = f'{age_month} 月龄'
            if col_name not in scale_df.columns:
                continue
                
            item_text = scale_df.iloc[row_idx][col_name]
            item_info = extract_item_info(item_text)
            
            if item_info:
                # 查找操作方法信息
                operation_info = find_operation_info(item_info['id'], operation_df)
                
                test_item = {
                    'id': item_info['id'],
                    'name': item_info['name'],
                    'desc': item_info['name'],  # 描述暂时使用名称
                    'operation': operation_info['operation'],
                    'passCondition': operation_info['passCondition']
                }
                
                # 检查是否已存在该月龄和能区的数据
                existing_item = None
                for item in assessment_data:
                    if item['ageMonth'] == age_month and item['area'] == area:
                        existing_item = item
                        break
                
                if existing_item:
                    # 添加到现有项目
                    existing_item['testItems'].append(test_item)
                else:
                    # 创建新项目
                    assessment_data.append({
                        'ageMonth': age_month,
                        'area': area,
                        'score': get_score(age_month),
                        'testItems': [test_item]
                    })
    
    return assessment_data

def main():
    """主函数"""
    print("开始生成评估数据...")
    
    try:
        assessment_data = generate_assessment_data()
        
        # 保存到data文件夹
        output_file = 'child_development_assessment/assets/data/assessment_data.json'
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(assessment_data, f, ensure_ascii=False, indent=2)
        
        print(f"数据生成完成，已保存到: {output_file}")
        print(f"共生成 {len(assessment_data)} 个评估项目")
        
        # 统计信息
        area_stats = {}
        age_stats = {}
        total_items = 0
        
        for item in assessment_data:
            area = item['area']
            age = item['ageMonth']
            test_items = item['testItems']
            
            area_stats[area] = area_stats.get(area, 0) + len(test_items)
            age_stats[age] = age_stats.get(age, 0) + len(test_items)
            total_items += len(test_items)
        
        print(f"\n统计信息:")
        print(f"总测试项目数: {total_items}")
        print("各能区项目数量:")
        for area, count in area_stats.items():
            print(f"  {area}: {count} 项")
        
        print("\n各月龄项目数量:")
        for age in sorted(age_stats.keys()):
            print(f"  {age}月龄: {age_stats[age]} 项")
            
    except Exception as e:
        print(f"生成数据时出错: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main() 