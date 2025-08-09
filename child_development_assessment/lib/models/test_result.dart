import 'package:flutter/material.dart';
import '../utils/dq_utils.dart';

class TestResult {
  final String userName;
  final double actualAge;
  final int mainTestAge;
  final Map<String, double> areaScores;
  final double totalScore;
  final double averageScore;
  final double dq;
  final Map<int, bool> testResults;

  TestResult({
    required this.userName,
    required this.actualAge,
    required this.mainTestAge,
    required this.areaScores,
    required this.totalScore,
    required this.averageScore,
    required this.dq,
    required this.testResults,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      userName: json['userName'],
      actualAge: json['actualAge'].toDouble(),
      mainTestAge: json['mainTestAge'],
      areaScores: Map<String, double>.from(json['areaScores']),
      totalScore: json['totalScore'].toDouble(),
      averageScore: json['averageScore'].toDouble(),
      dq: json['dq'].toDouble(),
      testResults: Map<int, bool>.from(json['testResults']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'actualAge': actualAge,
      'mainTestAge': mainTestAge,
      'areaScores': areaScores,
      'totalScore': totalScore,
      'averageScore': averageScore,
      'dq': dq,
      'testResults': testResults,
    };
  }

  // 获取发育商等级描述
  String get dqLevel => DqUtils.labelByDq(dq);

  // 获取发育商等级颜色（新方案）
  Color get dqLevelColor => DqUtils.colorByDq(dq);
}

class AreaResult {
  final String area;
  final double mentalAge;
  final double developmentQuotient;

  AreaResult({
    required this.area,
    required this.mentalAge,
    required this.developmentQuotient,
  });

  factory AreaResult.fromJson(Map<String, dynamic> json) {
    return AreaResult(
      area: json['area'],
      mentalAge: json['mentalAge'].toDouble(),
      developmentQuotient: json['developmentQuotient'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'mentalAge': mentalAge,
      'developmentQuotient': developmentQuotient,
    };
  }
} 