#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
调试正确的CSV解析过程
"""

import pandas as pd
import re

def debug_correct_parsing():
    """调试正确的解析过程"""
    csv_file = "docs/表A.1  0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).csv"
    
    print("=== 调试正确的CSV解析过程 ===")
    
    # 读取CSV文件
    df = pd.read_csv(csv_file, encoding='utf-8')
    print(f"CSV文件形状: {df.shape}")
    
    current_months = []
    current_area = None
    
    for index, row in df.iterrows():
        project_col = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
        
        print(f"\n行 {index+1}: {project_col}")
        
        # 检查是否是新的年龄组标题行
        if project_col.strip() == "项目":
            months = []
            for col_idx in range(1, len(row)):
                cell_value = str(row.iloc[col_idx]) if pd.notna(row.iloc[col_idx]) else ""
                if cell_value.strip():
                    month_match = re.search(r'(\d+)\s*月龄', cell_value)
                    if month_match:
                        months.append(int(month_match.group(1)))
            
            current_months = months
            print(f"  发现新年龄组: {current_months}")
            continue
        
        # 检查是否是区域标题
        area_titles = ['大 运 动', '精细动作', '适应能力', '语    言', '社会行为']
        if project_col.strip() in area_titles:
            current_area = project_col.strip()
            print(f"  发现区域: {current_area}")
            continue
        
        # 检查是否是项目行
        if current_area and current_months and re.search(r'□\d+', project_col):
            print(f"  项目行 - 区域: {current_area}, 月份: {current_months}")
            
            # 显示该行的所有列
            for col_idx in range(1, len(row)):
                cell_value = str(row.iloc[col_idx]) if pd.notna(row.iloc[col_idx]) else ""
                if cell_value.strip():
                    print(f"    列 {col_idx}: {cell_value}")
                    
                    # 查找测试项目
                    item_matches = re.findall(r'□(\d+)\s*([^□]*)', cell_value)
                    for match in item_matches:
                        item_number = int(match[0])
                        item_description = match[1].strip()
                        month_idx = col_idx - 1
                        if month_idx < len(current_months):
                            month = current_months[month_idx]
                            print(f"      项目: {item_number} - {item_description} (月龄: {month})")

if __name__ == "__main__":
    debug_correct_parsing() 