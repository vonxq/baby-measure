#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Excel数据转换脚本
从docs文件夹中的Excel文件读取数据并生成符合assessment_data.json格式的JSON文件
"""

import pandas as pd
import json
import os
import sys
from pathlib import Path
import re

class ExcelDataProcessor:
    def __init__(self, docs_path, output_path):
        self.docs_path = Path(docs_path)
        self.output_path = Path(output_path)
        self.assessment_data = []
        
        # 能区映射
        self.area_mapping = {
            '大运动': 'motor',
            '精细动作': 'fineMotor', 
            '语言': 'language',
            '适应能力': 'adaptive',
            '社会行为': 'social'
        }
        
        # 月龄计分规则
        self.score_rules = {
            (1, 12): 1.0,    # 1-12月龄：每个能区1.0分
            (15, 36): 3.0,   # 15-36月龄：每个能区3.0分
            (42, 84): 6.0    # 42-84月龄：每个能区6.0分
        }
    
    def get_score_for_age(self, age_month):
        """根据月龄获取计分"""
        for (min_age, max_age), score in self.score_rules.items():
            if min_age <= age_month <= max_age:
                return score
        return 1.0  # 默认值
    
    def process_excel_files(self):
        """处理Excel文件"""
        print("开始处理Excel文件...")
        
        # 查找Excel文件
        excel_files = list(self.docs_path.glob("*.xlsx"))
        print(f"找到 {len(excel_files)} 个Excel文件")
        
        for excel_file in excel_files:
            print(f"处理文件: {excel_file.name}")
            self.process_single_excel(excel_file)
        
        # 保存结果
        self.save_results()
    
    def process_single_excel(self, excel_file):
        """处理单个Excel文件"""
        try:
            # 读取Excel文件的所有工作表
            excel_data = pd.read_excel(excel_file, sheet_name=None)
            
            for sheet_name, df in excel_data.items():
                print(f"  处理工作表: {sheet_name}")
                self.process_sheet(df, sheet_name, excel_file.name)
                
        except Exception as e:
            print(f"处理文件 {excel_file.name} 时出错: {e}")
    
    def process_sheet(self, df, sheet_name, filename):
        """处理工作表"""
        # 清理数据
        df = df.dropna(how='all')
        
        # 根据文件名和工作表名判断数据类型
        if "表A.1" in filename:
            self.process_assessment_sheet(df, sheet_name)
        elif "表B.1" in filename:
            self.process_operation_sheet(df, sheet_name)
    
    def process_assessment_sheet(self, df, sheet_name):
        """处理评估量表工作表"""
        print(f"  数据形状: {df.shape}")
        
        # 获取月龄信息（从列名）
        age_info = {}
        for col in df.columns:
            if col == '项目':  # 跳过项目列
                continue
            age_month = self.extract_age_from_column(col)
            if age_month:
                age_info[col] = age_month
        
        print(f"  找到月龄: {list(age_info.values())}")
        
        # 从第1行开始处理数据
        current_area = None
        for row_idx in range(0, len(df)):
            try:
                row = df.iloc[row_idx]
                item_value = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
                
                # 检查是否是能区标题
                item_clean = item_value.replace(' ', '')
                print(f"    检查项目: '{item_value}' -> '{item_clean}'")
                if any(area in item_clean for area in ['大运动', '精细动作', '语言', '适应能力', '社会行为']):
                    current_area = self.extract_area(item_value)
                    print(f"  发现能区: {current_area} (从: {item_value})")
                    continue
                
                # 跳过空行和NaN
                if not item_value or item_value.strip() == "" or item_value == "nan":
                    continue
                
                print(f"    检查项目值: '{item_value}'")
                
                # 处理测试项目
                if current_area and item_value.strip():
                    # 提取项目名称（去掉□符号和多余空格）
                    item_name = item_value.replace('□', '').strip()
                    if not item_name or item_name == "nan":
                        continue
                    
                    print(f"    处理项目: {item_name} (能区: {current_area})")
                    
                    # 为每个月龄检查是否有测试项目
                    for col, age_month in age_info.items():
                        cell_value = str(row[col]) if pd.notna(row[col]) else ""
                        print(f"      月龄 {age_month}: 单元格值 = '{cell_value}'")
                        if cell_value.strip() and '□' in cell_value:
                            print(f"      月龄 {age_month}: 找到测试项目")
                            # 查找或创建该月龄和能区的数据
                            existing_data = self.find_existing_data(age_month, current_area)
                            
                            if existing_data:
                                # 添加到现有数据
                                test_item = {
                                    "id": self.generate_id(age_month, current_area, len(existing_data["testItems"])),
                                    "name": item_name,
                                    "desc": item_name,
                                    "operation": "",  # 从操作表中获取
                                    "passCondition": ""  # 从操作表中获取
                                }
                                existing_data["testItems"].append(test_item)
                            else:
                                # 创建新数据
                                new_data = {
                                    "ageMonth": age_month,
                                    "area": current_area,
                                    "score": self.get_score_for_age(age_month),
                                    "testItems": [{
                                        "id": self.generate_id(age_month, current_area, 0),
                                        "name": item_name,
                                        "desc": item_name,
                                        "operation": "",
                                        "passCondition": ""
                                    }]
                                }
                                self.assessment_data.append(new_data)
                
                # 处理能区标题行中的测试项目
                elif current_area and item_value == "":
                    print(f"    处理能区标题行: {current_area}")
                    # 检查能区标题行中的测试项目
                    for col, age_month in age_info.items():
                        cell_value = str(row[col]) if pd.notna(row[col]) else ""
                        print(f"      月龄 {age_month}: 单元格值 = '{cell_value}'")
                        if cell_value.strip() and '□' in cell_value:
                            # 提取项目名称
                            item_name = cell_value.replace('□', '').strip()
                            print(f"    从能区标题行处理项目: {item_name} (能区: {current_area}, 月龄: {age_month})")
                            
                            # 查找或创建该月龄和能区的数据
                            existing_data = self.find_existing_data(age_month, current_area)
                            
                            if existing_data:
                                # 添加到现有数据
                                test_item = {
                                    "id": self.generate_id(age_month, current_area, len(existing_data["testItems"])),
                                    "name": item_name,
                                    "desc": item_name,
                                    "operation": "",  # 从操作表中获取
                                    "passCondition": ""  # 从操作表中获取
                                }
                                existing_data["testItems"].append(test_item)
                            else:
                                # 创建新数据
                                new_data = {
                                    "ageMonth": age_month,
                                    "area": current_area,
                                    "score": self.get_score_for_age(age_month),
                                    "testItems": [{
                                        "id": self.generate_id(age_month, current_area, 0),
                                        "name": item_name,
                                        "desc": item_name,
                                        "operation": "",
                                        "passCondition": ""
                                    }]
                                }
                                self.assessment_data.append(new_data)
                        
            except Exception as e:
                print(f"  处理行 {row_idx} 时出错: {e}")
                continue
    
    def extract_age_from_text(self, text):
        """从文本中提取月龄"""
        if pd.isna(text):
            return None
        
        text_str = str(text).strip()
        
        # 提取数字
        import re
        match = re.search(r'(\d+)\s*月龄', text_str)
        if match:
            age = int(match.group(1))
            if 0 <= age <= 84:
                return age
        
        return None
    
    def extract_age_from_column(self, column_name):
        """从列名中提取月龄"""
        if pd.isna(column_name):
            return None
        
        column_str = str(column_name).strip()
        
        # 提取数字
        import re
        match = re.search(r'(\d+)\s*月龄', column_str)
        if match:
            age = int(match.group(1))
            if 0 <= age <= 84:
                return age
        
        return None
    
    def process_operation_sheet(self, df, sheet_name):
        """处理操作方法工作表"""
        # 这里可以处理操作方法和通过要求
        # 暂时跳过，因为需要与评估项目进行匹配
        pass
    
    def extract_age_month(self, value):
        """提取月龄"""
        if pd.isna(value):
            return None
        
        value_str = str(value).strip()
        
        # 尝试直接转换数字
        try:
            age = float(value_str)
            if 0 <= age <= 84:  # 0-84月龄范围
                return int(age)
        except ValueError:
            pass
        
        # 尝试从文本中提取月龄
        patterns = [
            r'(\d+)\s*月',
            r'(\d+)\s*个月',
            r'(\d+)\s*月龄',
            r'(\d+)'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, value_str)
            if match:
                age = int(match.group(1))
                if 0 <= age <= 84:
                    return age
        
        return None
    
    def extract_area(self, value):
        """提取能区"""
        if pd.isna(value):
            return None
        
        value_str = str(value).strip().replace(' ', '')
        
        # 直接映射
        for chinese, english in self.area_mapping.items():
            if chinese in value_str:
                return english
        
        # 模糊匹配
        if any(keyword in value_str for keyword in ['运动', '大运动']):
            return 'motor'
        elif any(keyword in value_str for keyword in ['精细', '手部']):
            return 'fineMotor'
        elif any(keyword in value_str for keyword in ['语言', '说话']):
            return 'language'
        elif any(keyword in value_str for keyword in ['适应', '认知']):
            return 'adaptive'
        elif any(keyword in value_str for keyword in ['社会', '交往']):
            return 'social'
        
        return None
    
    def find_existing_data(self, age_month, area):
        """查找现有的数据"""
        for data in self.assessment_data:
            if data["ageMonth"] == age_month and data["area"] == area:
                return data
        return None
    
    def generate_id(self, age_month, area, index):
        """生成项目ID"""
        area_code = {
            'motor': 1,
            'fineMotor': 2,
            'language': 3,
            'adaptive': 4,
            'social': 5
        }
        return age_month * 100 + area_code.get(area, 0) * 10 + index
    
    def save_results(self):
        """保存结果"""
        # 确保输出目录存在
        self.output_path.parent.mkdir(parents=True, exist_ok=True)
        
        # 按月龄和能区排序
        self.assessment_data.sort(key=lambda x: (x["ageMonth"], x["area"]))
        
        # 保存到文件
        with open(self.output_path, 'w', encoding='utf-8') as f:
            json.dump(self.assessment_data, f, ensure_ascii=False, indent=2)
        
        print(f"数据已保存到: {self.output_path}")
        print(f"共处理 {len(self.assessment_data)} 个数据项")
        
        # 统计信息
        if self.assessment_data:
            age_months = set()
            areas = set()
            total_items = 0
            
            for data in self.assessment_data:
                age_months.add(data["ageMonth"])
                areas.add(data["area"])
                total_items += len(data["testItems"])
            
            print(f"月龄范围: {min(age_months)} - {max(age_months)} 个月")
            print(f"能区: {', '.join(sorted(areas))}")
            print(f"总测试项目数: {total_items}")
        else:
            print("未处理到任何数据")

def main():
    """主函数"""
    # 设置路径
    docs_path = Path("../docs")
    output_path = Path("../child_development_assessment/assets/data/assessment_data.json")
    
    if not docs_path.exists():
        print(f"错误: docs文件夹不存在: {docs_path}")
        sys.exit(1)
    
    # 创建处理器并执行
    processor = ExcelDataProcessor(docs_path, output_path)
    processor.process_excel_files()

if __name__ == "__main__":
    main() 