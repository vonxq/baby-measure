#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
分析Excel文件中的项目数
"""

import pandas as pd
import re

def analyze_excel():
    """分析Excel文件中的项目数"""
    try:
        df = pd.read_excel('docs/0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).xlsx')
        print(f"Excel文件形状: {df.shape}")
        
        # 统计包含□符号的单元格
        square_count = 0
        project_ids = []
        
        for i in range(len(df)):
            for j in range(len(df.columns)):
                cell_value = str(df.iloc[i, j])
                if '□' in cell_value:
                    square_count += 1
                    # 提取项目ID
                    matches = re.findall(r'□(\d+)', cell_value)
                    project_ids.extend(matches)
        
        print(f"包含□符号的单元格数: {square_count}")
        print(f"提取的项目ID数: {len(project_ids)}")
        print(f"唯一项目ID数: {len(set(project_ids))}")
        
        # 显示项目ID范围
        if project_ids:
            project_ids = [int(id) for id in project_ids if id.isdigit()]
            print(f"项目ID范围: {min(project_ids)} - {max(project_ids)}")
            print(f"缺失的项目ID: {set(range(1, max(project_ids) + 1)) - set(project_ids)}")
        
    except Exception as e:
        print(f"分析失败: {e}")

if __name__ == "__main__":
    analyze_excel() 