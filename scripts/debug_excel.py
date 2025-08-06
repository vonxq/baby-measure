#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
调试Excel文件内容
"""

import pandas as pd
import os

def debug_excel_file(file_path: str):
    """调试Excel文件内容"""
    print(f"=== 调试文件: {file_path} ===")
    
    try:
        df = pd.read_excel(file_path)
        
        print(f"文件形状: {df.shape}")
        print(f"列名: {list(df.columns)}")
        print()
        
        # 显示前10行数据
        print("前10行数据:")
        for i in range(min(10, len(df))):
            row = df.iloc[i]
            print(f"行 {i}:")
            for j, col in enumerate(df.columns):
                value = row.iloc[j]
                if pd.notna(value):
                    print(f"  {col}: {value}")
            print()
        
        # 查找包含"□"的行
        print("包含'□'的行:")
        for i in range(len(df)):
            row = df.iloc[i]
            for j, col in enumerate(df.columns):
                value = str(row.iloc[j]) if pd.notna(row.iloc[j]) else ""
                if "□" in value:
                    print(f"行 {i}, 列 {col}: {value}")
        
    except Exception as e:
        print(f"调试文件时出错: {e}")
        import traceback
        traceback.print_exc()

def main():
    """主函数"""
    docs_path = "docs"
    
    # 调试量表文件
    scale_file = os.path.join(docs_path, "0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).xlsx")
    if os.path.exists(scale_file):
        debug_excel_file(scale_file)
    
    print("\n" + "="*50 + "\n")
    
    # 调试操作方法文件
    method_file = os.path.join(docs_path, "0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ ) 操作方法和测查通过要求.xlsx")
    if os.path.exists(method_file):
        debug_excel_file(method_file)

if __name__ == "__main__":
    main() 