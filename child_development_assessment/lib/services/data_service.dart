import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/assessment_data.dart';

class DataService {
  // 加载评估数据
  Future<List<AssessmentData>> loadAssessmentData() async {
    try {
      // 首先尝试从assets加载
      final jsonString = await rootBundle.loadString('mock_data/assessment_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((json) => AssessmentData.fromJson(json)).toList();
    } catch (e) {
      // 如果从assets加载失败，尝试从文件系统加载
      try {
        final file = File('mock_data/assessment_data.json');
        if (await file.exists()) {
          final jsonString = await file.readAsString();
          final List<dynamic> jsonList = json.decode(jsonString);
          
          return jsonList.map((json) => AssessmentData.fromJson(json)).toList();
        } else {
          throw Exception('Mock数据文件不存在');
        }
      } catch (fileError) {
        throw Exception('加载评估数据失败: $e, 文件错误: $fileError');
      }
    }
  }

  // 保存测试结果到本地
  Future<void> saveTestResult(Map<String, dynamic> result) async {
    try {
      final file = File('mock_data/test_results.json');
      final results = await loadTestResults();
      results.add(result);
      
      await file.writeAsString(json.encode(results));
    } catch (e) {
      throw Exception('保存测试结果失败: $e');
    }
  }

  // 加载测试结果
  Future<List<Map<String, dynamic>>> loadTestResults() async {
    try {
      final file = File('mock_data/test_results.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 获取可用的月龄列表
  List<int> getAvailableAges(List<AssessmentData> data) {
    final ages = data.map((item) => item.ageMonth).toSet().toList();
    ages.sort();
    return ages;
  }

  // 根据月龄获取数据
  List<AssessmentData> getDataByAge(List<AssessmentData> data, int age) {
    return data.where((item) => item.ageMonth == age).toList();
  }
} 