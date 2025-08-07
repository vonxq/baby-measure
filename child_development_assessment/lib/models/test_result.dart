import 'package:flutter/material.dart';

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
  String get dqLevel {
    if (dq > 130) return '优秀';
    if (dq >= 110) return '良好';
    if (dq >= 80) return '中等';
    if (dq >= 70) return '临界偏低';
    return '智力发育障碍';
  }

  // 获取发育商等级颜色
  Color get dqLevelColor {
    if (dq > 130) return Colors.green;
    if (dq >= 110) return Colors.blue;
    if (dq >= 80) return Colors.orange;
    if (dq >= 70) return Colors.red;
    return Colors.red[900]!;
  }
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