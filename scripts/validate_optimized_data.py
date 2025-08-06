#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
优化数据格式验证脚本
验证简化数组格式的数据
"""

import json
import os
from typing import Dict, List, Any

class OptimizedDataValidator:
    def __init__(self, data_file: str):
        self.data_file = data_file
        self.data = None
        
    def load_data(self):
        """加载数据"""
        print(f"加载数据文件: {self.data_file}")
        
        with open(self.data_file, 'r', encoding='utf-8') as f:
            self.data = json.load(f)
        
        print("数据加载完成")
    
    def validate_structure(self):
        """验证数据结构"""
        print("\n=== 验证数据结构 ===")
        
        # 检查是否是数组
        if not isinstance(self.data, list):
            print("❌ 数据不是数组格式")
            return False
        
        print(f"✅ 数据是数组格式，包含 {len(self.data)} 个项目")
        
        # 检查每个项目的格式
        required_fields = ['month', 'category', 'id', 'description']
        valid_categories = ['motor', 'fineMotor', 'adaptive', 'language', 'social']
        
        for i, item in enumerate(self.data):
            # 检查必需字段
            for field in required_fields:
                if field not in item:
                    print(f"❌ 项目 {i} 缺少字段: {field}")
                    return False
            
            # 检查数据类型
            if not isinstance(item['month'], int):
                print(f"❌ 项目 {i} month 字段不是整数")
                return False
            
            if not isinstance(item['id'], int):
                print(f"❌ 项目 {i} id 字段不是整数")
                return False
            
            if not isinstance(item['category'], str):
                print(f"❌ 项目 {i} category 字段不是字符串")
                return False
            
            if not isinstance(item['description'], str):
                print(f"❌ 项目 {i} description 字段不是字符串")
                return False
            
            # 检查category是否有效
            if item['category'] not in valid_categories:
                print(f"❌ 项目 {i} category 无效: {item['category']}")
                return False
        
        print("✅ 数据结构验证通过")
        return True
    
    def check_duplicates(self):
        """检查重复项"""
        print("\n=== 检查重复项 ===")
        
        # 检查ID重复
        ids = [item['id'] for item in self.data]
        duplicate_ids = [id for id in set(ids) if ids.count(id) > 1]
        
        if duplicate_ids:
            print(f"❌ 发现重复ID: {duplicate_ids}")
            return False
        else:
            print("✅ 无重复ID")
        
        # 检查相同月份和类别的组合
        combinations = [(item['month'], item['category'], item['id']) for item in self.data]
        duplicate_combinations = [combo for combo in set(combinations) if combinations.count(combo) > 1]
        
        if duplicate_combinations:
            print(f"❌ 发现重复组合: {duplicate_combinations}")
            return False
        else:
            print("✅ 无重复组合")
        
        return True
    
    def analyze_data_distribution(self):
        """分析数据分布"""
        print("\n=== 数据分布分析 ===")
        
        # 按区域统计
        category_stats = {}
        for item in self.data:
            category = item['category']
            if category not in category_stats:
                category_stats[category] = 0
            category_stats[category] += 1
        
        print("按区域分布:")
        category_names = {
            'motor': '大运动',
            'fineMotor': '精细动作',
            'adaptive': '适应能力',
            'language': '语言',
            'social': '社会行为'
        }
        for category, count in category_stats.items():
            category_name = category_names.get(category, category)
            print(f"  {category_name}: {count} 个项目")
        
        # 按月份统计
        month_stats = {}
        for item in self.data:
            month = item['month']
            if month not in month_stats:
                month_stats[month] = 0
            month_stats[month] += 1
        
        print("\n按月份分布:")
        for month, count in sorted(month_stats.items()):
            print(f"  {month}月龄: {count} 个项目")
        
        # 按月份和区域统计
        print("\n按月份和区域分布:")
        for month in sorted(month_stats.keys()):
            print(f"  {month}月龄:")
            month_items = [item for item in self.data if item['month'] == month]
            for category in ['motor', 'fineMotor', 'adaptive', 'language', 'social']:
                category_count = len([item for item in month_items if item['category'] == category])
                category_name = category_names.get(category, category)
                print(f"    {category_name}: {category_count} 个项目")
    
    def print_sample_data(self):
        """打印示例数据"""
        print("\n=== 示例数据 ===")
        
        # 显示每个区域的一个示例
        categories = ['motor', 'fineMotor', 'adaptive', 'language', 'social']
        category_names = {
            'motor': '大运动',
            'fineMotor': '精细动作',
            'adaptive': '适应能力',
            'language': '语言',
            'social': '社会行为'
        }
        
        for category in categories:
            category_items = [item for item in self.data if item['category'] == category]
            if category_items:
                sample = category_items[0]
                category_name = category_names.get(category, category)
                print(f"{category_name} 示例:")
                print(f"  {sample}")
    
    def run_validation(self):
        """运行完整验证"""
        print("=== 开始优化数据验证 ===")
        
        # 加载数据
        self.load_data()
        
        # 验证结构
        if not self.validate_structure():
            return False
        
        # 检查重复项
        if not self.check_duplicates():
            return False
        
        # 分析数据分布
        self.analyze_data_distribution()
        
        # 显示示例数据
        self.print_sample_data()
        
        print("\n✅ 所有验证通过！")
        return True

def main():
    """主函数"""
    # 验证优化后的数据
    data_file = "data/optimized_scale_data.json"
    
    if not os.path.exists(data_file):
        print(f"❌ 数据文件不存在: {data_file}")
        return
    
    validator = OptimizedDataValidator(data_file)
    validator.run_validation()

if __name__ == "__main__":
    main() 