#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
查找缺失的项目
"""

from docx import Document
import re

def find_missing_items():
    """查找缺失的项目"""
    docx_path = "docs/儿童生长发育量表.docx"
    doc = Document(docx_path)
    
    missing_ids = ['55', '74', '83']
    
    for i, table in enumerate(doc.tables):
        print(f"\n检查表格 {i+1}:")
        
        for row in table.rows:
            for cell in row.cells:
                cell_text = cell.text.strip()
                for missing_id in missing_ids:
                    if f'□{missing_id}' in cell_text:
                        print(f"找到项目 {missing_id}: {cell_text}")

if __name__ == "__main__":
    find_missing_items() 