#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
儿童发育行为评估量表CSV数据解析脚本
解析表A.1 CSV文件，提取测试项目数据
"""

import pandas as pd
import json
import os
import re
from typing import Dict, List, Any, Optional

class CSVScaleParser:
    def __init__(self, csv_file_path: str):
        self.csv_file_path = csv_file_path
        self.parsed_data = {
            "age_groups": [],
            "test_items": [],
            "areas": {
                "motor": {"name": "大运动", "items": []},
                "fineMotor": {"name": "精细动作", "items": []},
                "adaptive": {"name": "适应能力", "items": []},
                "language": {"name": "语言", "items": []},
                "social": {"name": "社会行为", "items": []}
            }
        }
        
    def parse_csv(self):
        """解析CSV文件"""
        print("=== 开始解析CSV文件 ===")
        
        try:
            # 读取CSV文件
            df = pd.read_csv(self.csv_file_path, encoding='utf-8')
            print(f"CSV文件读取成功，共 {len(df)} 行数据")
            
            # 解析数据
            self._extract_age_groups(df)
            self._extract_test_items(df)
            
            print("=== 解析完成 ===")
            print(f"提取了 {len(self.parsed_data['age_groups'])} 个年龄组")
            print(f"提取了 {len(self.parsed_data['test_items'])} 个测试项目")
            
        except Exception as e:
            print(f"解析CSV文件时出错: {e}")
            raise
    
    def _extract_age_groups(self, df: pd.DataFrame):
        """提取年龄组信息"""
        print("提取年龄组信息...")
        
        # 获取列名（年龄组）
        columns = df.columns.tolist()
        
        for col in columns:
            if col != '项目' and pd.notna(col) and col.strip():
                # 解析年龄组名称
                age_group = self._parse_age_group(col.strip())
                if age_group:
                    self.parsed_data['age_groups'].append(age_group)
        
        print(f"提取了 {len(self.parsed_data['age_groups'])} 个年龄组")
    
    def _parse_age_group(self, age_text: str) -> Optional[Dict]:
        """解析年龄组文本"""
        # 匹配年龄组模式，如 "1 月龄", "6 月龄", "15 月龄", "24 月龄" 等
        pattern = r'(\d+)\s*月龄'
        match = re.search(pattern, age_text)
        
        if match:
            age_months = int(match.group(1))
            return {
                "age_months": age_months,
                "display_name": age_text,
                "key": f"{age_months}_months"
            }
        
        return None
    
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
                self.parsed_data['test_items'].extend(items)
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
                age_group = self._get_age_group_for_column(col_idx)
                
                if age_group and item_description:
                    item = {
                        "id": f"{area}_{item_number}",
                        "item_number": item_number,
                        "area": area,
                        "description": item_description,
                        "age_group": age_group,
                        "display_name": f"{item_number} {item_description}"
                    }
                    items.append(item)
        
        return items
    
    def _get_age_group_for_column(self, col_idx: int) -> Optional[Dict]:
        """根据列索引获取年龄组信息"""
        # 获取列名
        columns = ['项目', '1 月龄', '2 月龄', '3 月龄', 'Unnamed: 4', '4 月龄', '5 月龄']
        
        if col_idx < len(columns):
            col_name = columns[col_idx]
            if col_name != '项目' and col_name != 'Unnamed: 4':
                return self._parse_age_group(col_name)
        
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
        print(f"年龄组数量: {len(self.parsed_data['age_groups'])}")
        print(f"测试项目数量: {len(self.parsed_data['test_items'])}")
        
        # 按区域统计
        area_stats = {}
        for item in self.parsed_data['test_items']:
            area = item['area']
            if area not in area_stats:
                area_stats[area] = 0
            area_stats[area] += 1
        
        print("\n按区域统计:")
        for area, count in area_stats.items():
            area_name = self.parsed_data['areas'][area]['name']
            print(f"  {area_name}: {count} 个项目")
        
        # 按年龄组统计
        age_stats = {}
        for item in self.parsed_data['test_items']:
            age_key = item['age_group']['key']
            if age_key not in age_stats:
                age_stats[age_key] = 0
            age_stats[age_key] += 1
        
        print("\n按年龄组统计:")
        for age_key, count in sorted(age_stats.items()):
            print(f"  {age_key}: {count} 个项目")

def main():
    """主函数"""
    # 文件路径
    csv_file = "docs/表A.1  0 岁～6 岁儿童发育行为评估量表（儿心量表- Ⅱ).csv"
    output_file = "data/parsed_scale_data.json"
    
    # 确保输出目录存在
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    # 创建解析器并解析数据
    parser = CSVScaleParser(csv_file)
    parser.parse_csv()
    parser.print_summary()
    parser.save_to_json(output_file)
    
    print(f"\n解析完成！结果已保存到: {output_file}")

if __name__ == "__main__":
    main() 