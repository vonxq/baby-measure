import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assessment_item.dart';
import '../models/assessment_result.dart';

class AssessmentRepository {
  static const String _resultsStorageKey = 'assessment_results';
  
  // 获取所有评估项目
  Future<List<AssessmentItem>> getAllItems() async {
    try {
      final String jsonString = await rootBundle.loadString('data/optimized_scale_data.json');
      final List<dynamic> itemsJson = json.decode(jsonString);
      
      return itemsJson
          .map((json) => AssessmentItem.fromOptimizedJson(json))
          .toList();
    } catch (e) {
      throw Exception('加载评估项目失败: $e');
    }
  }
  
  // 保存评估结果
  Future<AssessmentResult> saveResult(AssessmentResult result) async {
    try {
      final List<AssessmentResult> results = await getAllResults();
      results.add(result);
      await _saveResults(results);
      return result;
    } catch (e) {
      throw Exception('保存评估结果失败: $e');
    }
  }
  
  // 获取所有评估结果
  Future<List<AssessmentResult>> getAllResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? resultsJson = prefs.getString(_resultsStorageKey);
      
      if (resultsJson == null || resultsJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> resultsList = json.decode(resultsJson);
      return resultsList
          .map((json) => AssessmentResult.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('获取评估结果失败: $e');
    }
  }
  
  // 根据宝宝ID获取评估结果
  Future<List<AssessmentResult>> getResultsByBabyId(String babyId) async {
    try {
      final List<AssessmentResult> allResults = await getAllResults();
      return allResults
          .where((result) => result.babyId == babyId)
          .toList()
        ..sort((a, b) => b.testDate.compareTo(a.testDate));
    } catch (e) {
      throw Exception('获取宝宝评估结果失败: $e');
    }
  }
  
  // 根据ID获取评估结果
  Future<AssessmentResult?> getResultById(String resultId) async {
    try {
      final List<AssessmentResult> allResults = await getAllResults();
      return allResults.firstWhere((result) => result.id == resultId);
    } catch (e) {
      return null;
    }
  }
  
  // 删除评估结果
  Future<void> deleteResult(String resultId) async {
    try {
      final List<AssessmentResult> results = await getAllResults();
      results.removeWhere((result) => result.id == resultId);
      await _saveResults(results);
    } catch (e) {
      throw Exception('删除评估结果失败: $e');
    }
  }
  
  // 保存评估结果列表
  Future<void> _saveResults(List<AssessmentResult> results) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String resultsJson = json.encode(
        results.map((result) => result.toJson()).toList(),
      );
      await prefs.setString(_resultsStorageKey, resultsJson);
    } catch (e) {
      throw Exception('保存评估结果失败: $e');
    }
  }
  
  // 清空所有评估结果
  Future<void> clearAllResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_resultsStorageKey);
    } catch (e) {
      throw Exception('清空评估结果失败: $e');
    }
  }
  
  // 获取指定能区的项目
  Future<List<AssessmentItem>> getItemsByArea(String areaType) async {
    try {
      final List<AssessmentItem> allItems = await getAllItems();
      return allItems
          .where((item) => item.areaType == areaType)
          .toList();
    } catch (e) {
      throw Exception('获取能区项目失败: $e');
    }
  }
  
  // 获取指定月龄组的项目
  Future<List<AssessmentItem>> getItemsByAgeGroup(String ageGroup) async {
    try {
      final List<AssessmentItem> allItems = await getAllItems();
      return allItems
          .where((item) => item.ageGroup == ageGroup)
          .toList();
    } catch (e) {
      throw Exception('获取月龄组项目失败: $e');
    }
  }
} 