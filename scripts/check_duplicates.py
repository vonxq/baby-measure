#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
检查重复项目ID的脚本
"""

import json

def check_duplicates():
    """检查重复的项目ID"""
    with open('data/assessment_items.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    items = data['items']
    ids = [item['id'] for item in items]
    
    print(f"项目总数: {len(ids)}")
    print(f"唯一ID数: {len(set(ids))}")
    
    # 找出重复的ID
    duplicates = [id for id in set(ids) if ids.count(id) > 1]
    print(f"重复ID: {duplicates}")
    
    # 显示重复项目的详细信息
    for dup_id in duplicates:
        print(f"\n重复项目ID {dup_id}:")
        dup_items = [item for item in items if item['id'] == dup_id]
        for i, item in enumerate(dup_items):
            print(f"  {i+1}. {item['item_name']} - {item['category']} - {item['age_group']}")

if __name__ == "__main__":
    check_duplicates() 