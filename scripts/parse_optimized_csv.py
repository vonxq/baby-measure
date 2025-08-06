#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
优化版儿童发育行为评估量表CSV数据解析脚本
输出简化的数组格式：{"month":1,"category": "motor", "id": 1, "description": "抬肩坐起头竖直片刻"}
"""

import pandas as pd
import json
import os
import re
from typing import Dict, List, Any, Optional

class OptimizedCSVParser:
    def __init__(self, csv_file_path: str):
        self.csv_file_path = csv_file_path
        self.parsed_data = []
        
    def parse_csv(self):
        """解析CSV文件"""
        print("=== 开始解析CSV文件（优化格式） ===")
        
        try:
            # 读取CSV文件
            df = pd.read_csv(self.csv_file_path, encoding='utf-8')
            print(f"CSV文件读取成功，共 {len(df)} 行数据")
            
            # 解析数据
            self._extract_test_items(df)
            
            print("=== 解析完成 ===")
            print(f"提取了 {len(self.parsed_data)} 个测试项目")
            
        except Exception as e:
            print(f"解析CSV文件时出错: {e}")
            raise
    
    def _extract_test_items(self, df: pd.DataFrame):
        """提取测试项目"""
        print("提取测试项目...")
        
        for index, row in df.iterrows():
            project_col = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
            
            # 检查是否是区域标题
            if self._is_area_title(project_col):
                area = self._get_area_key(project_col)
                print(f"发现区域: {project_col} -> {area}")
                
                # 提取该区域的所有测试项目
                items = self._extract_items_from_area_row(row, area)
                self.parsed_data.extend(items)
                print(f"  提取了 {len(items)} 个测试项目")
    
    def _is_area_title(self, text: str) -> bool:
        """判断是否是区域标题"""
        area_titles = ['大 运 动', '精细动作', '适应能力', '语    言', '社会行为']
        return text.strip() in area_titles
    
    def _get_area_key(self, area_title: str) -> str:
        """获取区域键名"""
        area_mapping = {
            '大 运 动': 'motor',
            '精细动作': 'fineMotor',
            '适应能力': 'adaptive',
            '语    言': 'language',
            '社会行为': 'social'
        }
        return area_mapping.get(area_title.strip(), 'unknown')
    
    def _extract_items_from_area_row(self, row: pd.Series, area: str) -> List[Dict]:
        """从区域行中提取测试项目"""
        items = []
        
        # 遍历所有列（除了第一列项目）
        for col_idx in range(1, len(row)):
            cell_value = str(row.iloc[col_idx]) if pd.notna(row.iloc[col_idx]) else ""
            
            if not cell_value.strip():
                continue
                
            # 查找测试项目编号和描述
            item_matches = re.findall(r'□(\d+)\s*([^□]*)', cell_value)
            
            for match in item_matches:
                item_number = int(match[0])
                item_description = match[1].strip()
                
                # 获取年龄组信息
                month = self._get_month_for_column(col_idx, row)
                
                if month and item_description:
                    item = {
                        "month": month,
                        "category": area,
                        "id": item_number,
                        "description": item_description
                    }
                    items.append(item)
        
        return items
    
    def _get_month_for_column(self, col_idx: int, row: pd.Series) -> Optional[int]:
        """根据列索引获取月份信息"""
        # 尝试从列名获取月份信息
        try:
            # 获取列名
            columns = row.index.tolist()
            if col_idx < len(columns):
                col_name = columns[col_idx]
                month = self._parse_month(col_name)
                if month:
                    return month
        except:
            pass
        
        # 如果无法从列名获取，尝试从单元格内容推断
        cell_value = str(row.iloc[col_idx]) if pd.notna(row.iloc[col_idx]) else ""
        month_matches = re.findall(r'(\d+)\s*月龄', cell_value)
        if month_matches:
            return int(month_matches[0])
        
        return None
    
    def _parse_month(self, text: str) -> Optional[int]:
        """解析月份文本"""
        # 匹配月份模式，如 "1 月龄", "6 月龄", "15 月龄", "24 月龄" 等
        pattern = r'(\d+)\s*月龄'
        match = re.search(pattern, text)
        
        if match:
            return int(match.group(1))
        
        return None
    
    def save_to_json(self, output_path: str):
        """保存解析结果到JSON文件"""
        print(f"保存解析结果到: {output_path}")
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(self.parsed_data, f, ensure_ascii=False, indent=2)
        
        print("数据保存完成")
    
    def print_summary(self):
        """打印解析摘要"""
        print("\n=== 解析摘要 ===")
        print(f"测试项目数量: {len(self.parsed_data)}")
        
        # 按区域统计
        category_stats = {}
        for item in self.parsed_data:
            category = item['category']
            if category not in category_stats:
                category_stats[category] = 0
            category_stats[category] += 1
        
        print("\n按区域统计:")
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
        for item in self.parsed_data:
            month = item['month']
            if month not in month_stats:
                month_stats[month] = 0
            month_stats[month] += 1
        
        print("\n按月份统计:")
        for month, count in sorted(month_stats.items()):
            print(f"  {month}月龄: {count} 个项目")
        
        # 显示月份列表
        months = sorted(set(item['month'] for item in self.parsed_data))
        print(f"\n月份列表: {months}")

def main():
    """主函数"""
    # 文件路径
    csv_file = "docs/表A.1  0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).csv"
    output_file = "data/optimized_scale_data.json"
    
    # 确保输出目录存在
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    # 创建解析器并解析数据
    parser = OptimizedCSVParser(csv_file)
    parser.parse_csv()
    parser.print_summary()
    parser.save_to_json(output_file)
    
    print(f"\n解析完成！结果已保存到: {output_file}")

if __name__ == "__main__":
    main() 