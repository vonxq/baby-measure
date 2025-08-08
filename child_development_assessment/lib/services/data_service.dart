import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/assessment_data.dart';
import '../models/assessment_history.dart';

class DataService {
  // 加载评估数据
  Future<List<AssessmentData>> loadAssessmentData() async {
    try {
      // 从assets加载标准数据
      final jsonString = await rootBundle.loadString('assets/data/assessment_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((json) => AssessmentData.fromJson(json)).toList();
    } catch (e) {
      throw Exception('加载评估数据失败: $e');
    }
  }

  // 保存测试结果到本地
  Future<void> saveTestResult(Map<String, dynamic> result) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/test_results.json');
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
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/test_results.json');
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

  // 保存测评历史
  Future<void> saveAssessmentHistory(AssessmentHistory history) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assessment_history.json');
      final histories = await loadAssessmentHistories();
      histories.add(history);
      
      await file.writeAsString(json.encode(histories.map((h) => h.toJson()).toList()));
    } catch (e) {
      throw Exception('保存测评历史失败: $e');
    }
  }

  // 加载测评历史
  Future<List<AssessmentHistory>> loadAssessmentHistories() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assessment_history.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        final histories = jsonList.map((json) => AssessmentHistory.fromJson(json)).toList();
        
        // 按开始时间降序排列（最新的在前）
        histories.sort((a, b) => b.startTime.compareTo(a.startTime));
        
        return histories;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 删除测评历史
  Future<void> deleteAssessmentHistory(String id) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assessment_history.json');
      final histories = await loadAssessmentHistories();
      histories.removeWhere((history) => history.id == id);
      
      await file.writeAsString(json.encode(histories.map((h) => h.toJson()).toList()));
    } catch (e) {
      throw Exception('删除测评历史失败: $e');
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