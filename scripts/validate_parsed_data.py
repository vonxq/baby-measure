#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
数据验证脚本
验证解析的儿童发育行为评估量表数据
"""

import json
import os
from typing import Dict, List, Any

class DataValidator:
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
        
        # 检查必需字段
        required_fields = ['age_groups', 'test_items', 'areas']
        for field in required_fields:
            if field not in self.data:
                print(f"❌ 缺少必需字段: {field}")
                return False
            else:
                print(f"✅ 字段存在: {field}")
        
        return True
    
    def validate_age_groups(self):
        """验证年龄组数据"""
        print("\n=== 验证年龄组数据 ===")
        
        age_groups = self.data['age_groups']
        print(f"年龄组数量: {len(age_groups)}")
        
        # 检查年龄组格式
        for i, age_group in enumerate(age_groups):
            required_keys = ['age_months', 'display_name', 'key']
            for key in required_keys:
                if key not in age_group:
                    print(f"❌ 年龄组 {i} 缺少字段: {key}")
                    return False
            
            # 检查年龄组是否按顺序排列
            if i > 0 and age_group['age_months'] <= age_groups[i-1]['age_months']:
                print(f"❌ 年龄组顺序错误: {age_group['display_name']}")
                return False
        
        print("✅ 年龄组数据验证通过")
        return True
    
    def validate_test_items(self):
        """验证测试项目数据"""
        print("\n=== 验证测试项目数据 ===")
        
        test_items = self.data['test_items']
        print(f"测试项目数量: {len(test_items)}")
        
        # 检查测试项目格式
        for i, item in enumerate(test_items):
            required_keys = ['id', 'item_number', 'area', 'description', 'age_group', 'display_name']
            for key in required_keys:
                if key not in item:
                    print(f"❌ 测试项目 {i} 缺少字段: {key}")
                    return False
            
            # 检查区域是否有效
            if item['area'] not in self.data['areas']:
                print(f"❌ 测试项目 {i} 区域无效: {item['area']}")
                return False
        
        print("✅ 测试项目数据验证通过")
        return True
    
    def validate_areas(self):
        """验证区域数据"""
        print("\n=== 验证区域数据 ===")
        
        areas = self.data['areas']
        expected_areas = ['motor', 'fineMotor', 'adaptive', 'language', 'social']
        
        for area in expected_areas:
            if area not in areas:
                print(f"❌ 缺少区域: {area}")
                return False
            else:
                print(f"✅ 区域存在: {area} ({areas[area]['name']})")
        
        print("✅ 区域数据验证通过")
        return True
    
    def analyze_data_distribution(self):
        """分析数据分布"""
        print("\n=== 数据分布分析 ===")
        
        # 按区域统计
        area_stats = {}
        for item in self.data['test_items']:
            area = item['area']
            if area not in area_stats:
                area_stats[area] = 0
            area_stats[area] += 1
        
        print("按区域分布:")
        for area, count in area_stats.items():
            area_name = self.data['areas'][area]['name']
            print(f"  {area_name}: {count} 个项目")
        
        # 按年龄组统计
        age_stats = {}
        for item in self.data['test_items']:
            age_key = item['age_group']['key']
            if age_key not in age_stats:
                age_stats[age_key] = 0
            age_stats[age_key] += 1
        
        print("\n按年龄组分布:")
        for age_key, count in sorted(age_stats.items()):
            print(f"  {age_key}: {count} 个项目")
        
        # 检查数据完整性
        total_expected = len(self.data['age_groups']) * len(self.data['areas'])
        total_actual = len(self.data['test_items'])
        
        print(f"\n数据完整性:")
        print(f"  预期项目数: {total_expected}")
        print(f"  实际项目数: {total_actual}")
        print(f"  完整性: {total_actual/total_expected*100:.1f}%")
    
    def check_duplicates(self):
        """检查重复项"""
        print("\n=== 检查重复项 ===")
        
        # 检查ID重复
        ids = [item['id'] for item in self.data['test_items']]
        duplicate_ids = [id for id in set(ids) if ids.count(id) > 1]
        
        if duplicate_ids:
            print(f"❌ 发现重复ID: {duplicate_ids}")
            return False
        else:
            print("✅ 无重复ID")
        
        # 检查项目编号重复
        item_numbers = [item['item_number'] for item in self.data['test_items']]
        duplicate_numbers = [num for num in set(item_numbers) if item_numbers.count(num) > 1]
        
        if duplicate_numbers:
            print(f"❌ 发现重复项目编号: {duplicate_numbers}")
            return False
        else:
            print("✅ 无重复项目编号")
        
        return True
    
    def run_validation(self):
        """运行完整验证"""
        print("=== 开始数据验证 ===")
        
        # 加载数据
        self.load_data()
        
        # 验证结构
        if not self.validate_structure():
            return False
        
        # 验证年龄组
        if not self.validate_age_groups():
            return False
        
        # 验证区域
        if not self.validate_areas():
            return False
        
        # 验证测试项目
        if not self.validate_test_items():
            return False
        
        # 检查重复项
        if not self.check_duplicates():
            return False
        
        # 分析数据分布
        self.analyze_data_distribution()
        
        print("\n✅ 所有验证通过！")
        return True

def main():
    """主函数"""
    # 验证完整解析的数据
    data_file = "data/complete_parsed_scale_data.json"
    
    if not os.path.exists(data_file):
        print(f"❌ 数据文件不存在: {data_file}")
        return
    
    validator = DataValidator(data_file)
    validator.run_validation()

if __name__ == "__main__":
    main() 