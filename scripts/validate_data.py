#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
验证生成的评估数据质量
"""

import json
import os

def validate_assessment_data():
    """验证评估数据"""
    data_file = 'child_development_assessment/assets/data/assessment_data.json'
    
    if not os.path.exists(data_file):
        print(f"错误：数据文件不存在: {data_file}")
        return False
    
    try:
        with open(data_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        print("数据验证开始...")
        print(f"总项目数: {len(data)}")
        
        # 统计信息
        area_stats = {}
        age_stats = {}
        total_items = 0
        
        for item in data:
            age_month = item['ageMonth']
            area = item['area']
            score = item['score']
            test_items = item['testItems']
            
            # 统计
            area_stats[area] = area_stats.get(area, 0) + len(test_items)
            age_stats[age_month] = age_stats.get(age_month, 0) + len(test_items)
            total_items += len(test_items)
            
            # 验证必要字段
            if not all(key in item for key in ['ageMonth', 'area', 'score', 'testItems']):
                print(f"错误：缺少必要字段 - {item}")
                return False
            
            # 验证测试项目
            for test_item in test_items:
                if not all(key in test_item for key in ['id', 'name', 'desc', 'operation', 'passCondition']):
                    print(f"错误：测试项目缺少必要字段 - {test_item}")
                    return False
                
                # 验证操作方法和通过要求不为空
                if not test_item['operation'] or test_item['operation'] == '请参考标准操作方法':
                    print(f"警告：项目 {test_item['id']} 缺少详细操作方法")
                
                if not test_item['passCondition'] or test_item['passCondition'] == '请参考标准通过要求':
                    print(f"警告：项目 {test_item['id']} 缺少详细通过要求")
        
        print(f"\n验证结果:")
        print(f"总测试项目数: {total_items}")
        
        print("\n各能区项目数量:")
        for area, count in sorted(area_stats.items()):
            print(f"  {area}: {count} 项")
        
        print("\n各月龄项目数量:")
        for age in sorted(age_stats.keys()):
            print(f"  {age}月龄: {age_stats[age]} 项")
        
        # 检查数据完整性
        expected_ages = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84]
        expected_areas = ['motor', 'fineMotor', 'adaptive', 'language', 'social']
        
        missing_ages = set(expected_ages) - set(age_stats.keys())
        if missing_ages:
            print(f"\n警告：缺少以下月龄的数据: {missing_ages}")
        
        missing_areas = set(expected_areas) - set(area_stats.keys())
        if missing_areas:
            print(f"\n警告：缺少以下能区的数据: {missing_areas}")
        
        print("\n数据验证完成！")
        return True
        
    except Exception as e:
        print(f"验证过程中出错: {e}")
        return False

if __name__ == "__main__":
    validate_assessment_data() 