#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
儿童发育行为评估数据提取脚本
分析Excel文件中的测试项目数据，生成标准化的JSON文件
"""

import pandas as pd
import json
import os
import re
from datetime import datetime
from typing import Dict, List, Any

class DataExtractor:
    def __init__(self, docs_path: str, data_path: str):
        self.docs_path = docs_path
        self.data_path = data_path
        self.test_items = []
        self.age_groups = []
        self.calculation_rules = {}
        self.methods_data = {}  # 存储操作方法数据
        
    def extract_test_items(self):
        """提取测试项目数据"""
        print("=== 提取测试项目数据 ===")
        
        # 首先提取操作方法数据
        method_file = os.path.join(self.docs_path, "0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ ) 操作方法和测查通过要求.xlsx")
        if os.path.exists(method_file):
            self._extract_methods_data(method_file)
        
        # 然后提取量表数据
        scale_file = os.path.join(self.docs_path, "0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).xlsx")
        if os.path.exists(scale_file):
            self._extract_scale_data(scale_file)
        
        print(f"提取完成，共 {len(self.test_items)} 个测试项目")
    
    def _extract_methods_data(self, file_path: str):
        """提取操作方法数据"""
        print("提取操作方法数据...")
        try:
            df = pd.read_excel(file_path)
            
            current_item = None
            current_method = None
            current_requirement = None
            
            for index, row in df.iterrows():
                # 获取第一列的数据
                col1 = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
                col2 = str(row.iloc[1]) if pd.notna(row.iloc[1]) else ""
                col3 = str(row.iloc[2]) if pd.notna(row.iloc[2]) else ""
                
                # 检查是否是新的测试项目
                if "．" in col1 or "、" in col1 or re.match(r'^\d+[．、]', col1):
                    # 保存前一个项目
                    if current_item:
                        self.methods_data[current_item] = {
                            "method": current_method,
                            "requirement": current_requirement
                        }
                    
                    # 开始新项目
                    current_item = col1.strip()
                    current_method = col2.strip()
                    current_requirement = col3.strip()
                else:
                    # 继续累积操作方法或要求
                    if current_method and col2.strip():
                        current_method += "\n" + col2.strip()
                    if current_requirement and col3.strip():
                        current_requirement += "\n" + col3.strip()
            
            # 保存最后一个项目
            if current_item:
                self.methods_data[current_item] = {
                    "method": current_method,
                    "requirement": current_requirement
                }
            
            print(f"提取了 {len(self.methods_data)} 个操作方法")
            
        except Exception as e:
            print(f"提取操作方法数据时出错: {e}")
    
    def _extract_scale_data(self, file_path: str):
        """提取量表数据"""
        print("提取量表数据...")
        try:
            df = pd.read_excel(file_path)
            
            # 定义能区映射
            area_mapping = {
                '大 运 动': 'motor',
                '精细动作': 'fineMotor', 
                '语言': 'language',
                '适应能力': 'adaptive',
                '社会行为': 'social'
            }
            
            current_area = None
            item_counter = 0
            
            for index, row in df.iterrows():
                project_col = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
                
                # 检查是否是能区标题
                for area_cn, area_en in area_mapping.items():
                    if area_cn in project_col:
                        current_area = area_en
                        print(f"  发现能区: {area_cn}")
                        break
                
                if current_area:
                    # 检查所有列中是否有测试项目
                    for col_idx in range(1, len(row)):
                        cell_value = str(row.iloc[col_idx]) if pd.notna(row.iloc[col_idx]) else ""
                        
                        if "□" in cell_value:
                            print(f"    发现测试项目: {cell_value}")
                            # 提取项目编号和标题
                            item_match = re.search(r'□(\d+)\s*(.+)', cell_value)
                            if item_match:
                                item_number = int(item_match.group(1))
                                item_title = item_match.group(2).strip()
                                
                                # 从列名提取月龄
                                col_name = str(df.columns[col_idx])
                                print(f"      列名: {col_name}")
                                age_match = re.search(r'(\d+)\s*月龄', col_name)
                                if age_match:
                                    age_group = int(age_match.group(1))
                                    print(f"      提取到月龄: {age_group}")
                                    
                                    # 创建测试项目
                                    test_item = {
                                        "id": f"{age_group}_{current_area}_{item_number}",
                                        "ageGroup": age_group,
                                        "area": current_area,
                                        "order": item_number,
                                        "title": item_title,
                                        "requirement": "",
                                        "method": "",
                                        "passStandard": "",
                                        "score": self._calculate_score(age_group),
                                        "imagePath": ""
                                    }
                                    
                                    # 查找对应的操作方法
                                    method_key = f"{item_number}．{item_title}"
                                    if method_key in self.methods_data:
                                        test_item["method"] = self.methods_data[method_key].get("method", "")
                                        test_item["passStandard"] = self.methods_data[method_key].get("requirement", "")
                                    else:
                                        # 尝试其他匹配方式
                                        for key, method_data in self.methods_data.items():
                                            if str(item_number) in key and item_title in key:
                                                test_item["method"] = method_data.get("method", "")
                                                test_item["passStandard"] = method_data.get("requirement", "")
                                                break
                                    
                                    self.test_items.append(test_item)
                                    print(f"      成功提取项目: {age_group}月龄 {current_area} {item_title}")
                                    item_counter += 1
                                else:
                                    print(f"      无法从列名提取月龄: {col_name}")
            
            print(f"从量表提取了 {item_counter} 个项目")
            
        except Exception as e:
            print(f"提取量表数据时出错: {e}")
            import traceback
            traceback.print_exc()
    
    def _calculate_score(self, age_group: int) -> float:
        """根据月龄组计算得分"""
        if age_group <= 12:
            return 1.0  # 1-12月龄，每个项目1.0分
        elif age_group <= 36:
            return 3.0  # 15-36月龄，每个项目3.0分
        else:
            return 6.0  # 42-84月龄，每个项目6.0分
    
    def generate_age_groups(self):
        """生成月龄组配置"""
        print("生成月龄组配置...")
        
        # 根据国家标准定义月龄组
        age_groups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84]
        
        self.age_groups = []
        for age in age_groups:
            age_group = {
                "age": age,
                "scorePerArea": self._calculate_score(age),
                "description": f"{age}月龄组"
            }
            self.age_groups.append(age_group)
    
    def generate_calculation_rules(self):
        """生成计算规则配置"""
        print("生成计算规则配置...")
        
        self.calculation_rules = {
            "developmentQuotientRanges": {
                "excellent": {"min": 130, "max": 200, "description": "优秀"},
                "good": {"min": 110, "max": 129, "description": "良好"},
                "average": {"min": 80, "max": 109, "description": "中等"},
                "low": {"min": 70, "max": 79, "description": "临界偏低"},
                "disability": {"min": 0, "max": 69, "description": "智力发育障碍"}
            },
            "scoreRules": {
                "1-12_months": {"scorePerArea": 1.0, "scorePerItem": 1.0},
                "15-36_months": {"scorePerArea": 3.0, "scorePerItem": 3.0},
                "42-84_months": {"scorePerArea": 6.0, "scorePerItem": 6.0}
            },
            "testFlow": {
                "forwardTestMonths": 2,  # 向前测查月数
                "backwardTestMonths": 2,  # 向后测查月数
                "maxTestMonths": 5       # 最大测查月数
            }
        }
    
    def save_data(self):
        """保存数据到JSON文件"""
        print("保存数据到JSON文件...")
        
        # 确保data目录存在
        os.makedirs(self.data_path, exist_ok=True)
        
        # 保存测试项目数据
        test_items_file = os.path.join(self.data_path, "test_items.json")
        with open(test_items_file, 'w', encoding='utf-8') as f:
            json.dump(self.test_items, f, ensure_ascii=False, indent=2)
        print(f"测试项目数据已保存到: {test_items_file}")
        
        # 保存月龄组配置
        age_groups_file = os.path.join(self.data_path, "age_groups.json")
        with open(age_groups_file, 'w', encoding='utf-8') as f:
            json.dump(self.age_groups, f, ensure_ascii=False, indent=2)
        print(f"月龄组配置已保存到: {age_groups_file}")
        
        # 保存计算规则
        rules_file = os.path.join(self.data_path, "calculation_rules.json")
        with open(rules_file, 'w', encoding='utf-8') as f:
            json.dump(self.calculation_rules, f, ensure_ascii=False, indent=2)
        print(f"计算规则已保存到: {rules_file}")

def main():
    """主函数"""
    print("=== 儿童发育行为评估数据提取脚本 ===")
    
    # 设置路径
    docs_path = "docs"
    data_path = "data"
    
    # 创建提取器
    extractor = DataExtractor(docs_path, data_path)
    
    # 提取数据
    extractor.extract_test_items()
    
    # 生成配置数据
    extractor.generate_age_groups()
    extractor.generate_calculation_rules()
    
    # 保存数据
    extractor.save_data()
    
    print("数据提取完成！")

if __name__ == "__main__":
    main() 