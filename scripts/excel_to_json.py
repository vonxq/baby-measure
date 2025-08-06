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
        # 查找关键列
        age_col = None
        area_col = None
        item_col = None
        desc_col = None
        
        # 查找列名
        for col in df.columns:
            col_str = str(col).lower()
            if any(keyword in col_str for keyword in ['月龄', '年龄', '月']):
                age_col = col
            elif any(keyword in col_str for keyword in ['能区', '领域', '区域']):
                area_col = col
            elif any(keyword in col_str for keyword in ['项目', '测试', '题目']):
                item_col = col
            elif any(keyword in col_str for keyword in ['描述', '说明', '内容']):
                desc_col = col
        
        if not age_col or not area_col or not item_col:
            print(f"  警告: 工作表 {sheet_name} 缺少必要的列")
            return
        
        # 处理每一行数据
        for index, row in df.iterrows():
            try:
                age_month = self.extract_age_month(row[age_col])
                area = self.extract_area(row[area_col])
                item_name = str(row[item_col]) if pd.notna(row[item_col]) else ""
                item_desc = str(row[desc_col]) if desc_col and pd.notna(row[desc_col]) else ""
                
                if age_month and area and item_name:
                    # 查找或创建该月龄和能区的数据
                    existing_data = self.find_existing_data(age_month, area)
                    
                    if existing_data:
                        # 添加到现有数据
                        test_item = {
                            "id": self.generate_id(age_month, area, len(existing_data["testItems"])),
                            "name": item_name,
                            "desc": item_desc,
                            "operation": "",  # 从操作表中获取
                            "passCondition": ""  # 从操作表中获取
                        }
                        existing_data["testItems"].append(test_item)
                    else:
                        # 创建新数据
                        new_data = {
                            "ageMonth": age_month,
                            "area": area,
                            "score": self.get_score_for_age(age_month),
                            "testItems": [{
                                "id": self.generate_id(age_month, area, 0),
                                "name": item_name,
                                "desc": item_desc,
                                "operation": "",
                                "passCondition": ""
                            }]
                        }
                        self.assessment_data.append(new_data)
                        
            except Exception as e:
                print(f"  处理行 {index} 时出错: {e}")
    
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
        
        value_str = str(value).strip()
        
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