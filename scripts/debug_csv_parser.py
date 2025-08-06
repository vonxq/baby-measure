#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
调试CSV解析脚本
查看CSV文件的具体内容和结构
"""

import pandas as pd
import re

def debug_csv_structure():
    """调试CSV文件结构"""
    csv_file = "docs/表A.1  0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).csv"
    
    print("=== 调试CSV文件结构 ===")
    
    # 读取CSV文件
    df = pd.read_csv(csv_file, encoding='utf-8')
    print(f"CSV文件形状: {df.shape}")
    print(f"列名: {df.columns.tolist()}")
    
    print("\n=== 前10行数据 ===")
    for i in range(min(10, len(df))):
        row = df.iloc[i]
        print(f"行 {i+1}: {row.tolist()}")
    
    print("\n=== 查找包含测试项目的行 ===")
    for i in range(len(df)):
        row = df.iloc[i]
        first_col = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
        
        # 检查是否包含测试项目编号
        if re.search(r'□\d+', first_col):
            print(f"行 {i+1}: {first_col}")
            
            # 显示该行的所有列
            for j, col in enumerate(row):
                if pd.notna(col) and str(col).strip():
                    print(f"  列 {j}: {col}")
            print()
    
    print("\n=== 查找区域标题行 ===")
    area_titles = ['大 运 动', '精细动作', '适应能力', '语    言', '社会行为']
    for i in range(len(df)):
        row = df.iloc[i]
        first_col = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
        
        if first_col.strip() in area_titles:
            print(f"行 {i+1}: {first_col}")
            
            # 显示该行的所有列
            for j, col in enumerate(row):
                if pd.notna(col) and str(col).strip():
                    print(f"  列 {j}: {col}")
            print()

if __name__ == "__main__":
    debug_csv_structure() 