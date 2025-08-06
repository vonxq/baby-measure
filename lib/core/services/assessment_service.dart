import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/assessment_item.dart';
import '../../data/models/assessment_result.dart';

class AssessmentService {
  static const List<int> _ageGroups = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84
  ];

  // 确定主测月龄
  int determineMainTestAge(double ageInMonths) {
    int mainTestAge = _ageGroups[0];
    double minDiff = (ageInMonths - _ageGroups[0]).abs();
    
    for (int age in _ageGroups) {
      double diff = (ageInMonths - age).abs();
      if (diff < minDiff) {
        minDiff = diff;
        mainTestAge = age;
      }
    }
    
    return mainTestAge;
  }

  // 获取指定月龄的测试项目
  List<AssessmentItem> getTestItemsForAge(List<AssessmentItem> allItems, double ageInMonths) {
    int mainTestAge = determineMainTestAge(ageInMonths);
    
    // 获取主测月龄的项目
    List<AssessmentItem> testItems = allItems
        .where((item) => int.tryParse(item.ageGroup) == mainTestAge)
        .toList();
    
    // 按能区排序
    testItems.sort((a, b) => a.areaType.compareTo(b.areaType));
    
    return testItems;
  }

  // 计算智龄
  double calculateMentalAge(List<AssessmentItem> items, Map<String, bool> results, String areaType) {
    // 筛选指定能区的项目
    List<AssessmentItem> areaItems = items
        .where((item) => item.areaType == areaType)
        .toList();
    
    // 按月龄组排序（从高到低）
    areaItems.sort((a, b) => int.parse(b.ageGroup).compareTo(int.parse(a.ageGroup)));
    
    double totalScore = 0.0;
    bool foundFail = false;
    
    for (AssessmentItem item in areaItems) {
      bool? result = results[item.id];
      if (result == null) continue; // 跳过未测试的项目
      
      if (result) {
        // 通过的项目
        totalScore += item.score;
        // 继续计算，直到遇到失败的项目
      } else {
        // 失败的项目，停止计算
        break;
      }
    }
    
    return totalScore;
  }

  // 计算发育商
  double calculateDevelopmentQuotient(double totalMentalAge, double actualAgeInMonths) {
    if (actualAgeInMonths == 0) return 0.0;
    return (totalMentalAge / actualAgeInMonths) * 100;
  }

  // 确定发育水平
  String determineLevel(double developmentQuotient) {
    if (developmentQuotient > 130) {
      return 'excellent';
    } else if (developmentQuotient >= 110) {
      return 'good';
    } else if (developmentQuotient >= 80) {
      return 'average';
    } else if (developmentQuotient >= 70) {
      return 'low';
    } else {
      return 'disability';
    }
  }

  // 计算评估结果
  AssessmentResult calculateResult(
    List<AssessmentItem> items,
    Map<String, bool> results,
    String babyId,
    double ageInMonths,
  ) {
    int mainTestAge = determineMainTestAge(ageInMonths);
    
    // 计算各能区智龄
    Map<String, AreaResult> areaResults = {};
    List<String> areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];
    
    for (String area in areas) {
      double mentalAge = calculateMentalAge(items, results, area);
      double maxScore = 10.0; // 假设最大分数为10
      double percentage = (mentalAge / maxScore) * 100;
      areaResults[area] = AreaResult(
        score: mentalAge,
        mentalAge: mentalAge,
        maxScore: maxScore,
        percentage: percentage,
      );
    }
    
    // 计算总体智龄
    double totalMentalAge = areaResults.values
        .map((result) => result.mentalAge)
        .reduce((a, b) => a + b) / areaResults.length;
    
    // 计算发育商
    double developmentQuotient = calculateDevelopmentQuotient(totalMentalAge, ageInMonths);
    
    // 确定发育水平
    String level = determineLevel(developmentQuotient);
    
    // 计算总分和满分
    double totalScore = areaResults.values
        .map((result) => result.score)
        .reduce((a, b) => a + b);
    double maxTotalScore = areaResults.values
        .map((result) => result.maxScore)
        .reduce((a, b) => a + b);
    
    return AssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      babyId: babyId,
      testDate: DateTime.now(),
      ageInMonths: ageInMonths,
      mainTestAge: mainTestAge,
      areaResults: areaResults,
      totalMentalAge: totalMentalAge,
      developmentQuotient: developmentQuotient,
      level: level,
      status: 'completed',
      createdAt: DateTime.now(),
      totalScore: totalScore,
      maxTotalScore: maxTotalScore,
    );
  }

  // 加载评估项目数据
  Future<List<AssessmentItem>> loadAssessmentItems() async {
    try {
      final String jsonString = await rootBundle.loadString('data/assessment_items.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> itemsJson = jsonData['items'];
      
      return itemsJson
          .map((json) => AssessmentItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('加载评估项目数据失败: $e');
    }
  }
} 