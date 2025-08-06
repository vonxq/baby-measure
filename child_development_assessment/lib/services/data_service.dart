import 'dart:convert';
import 'dart:io';
import '../models/assessment_data.dart';

class DataService {
  static const String _mockDataPath = 'mock_data/assessment_data.json';
  
  // 加载评估数据
  Future<List<AssessmentData>> loadAssessmentData() async {
    try {
      // 从mock数据文件加载
      final file = File(_mockDataPath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        
        return jsonList.map((json) => AssessmentData.fromJson(json)).toList();
      } else {
        throw Exception('Mock数据文件不存在: $_mockDataPath');
      }
    } catch (e) {
      throw Exception('加载评估数据失败: $e');
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