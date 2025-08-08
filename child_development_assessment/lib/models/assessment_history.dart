import 'package:flutter/material.dart';

class AssessmentHistory {
  final String id;
  final String babyName;
  final double actualAge;
  final DateTime startTime;
  final DateTime endTime;
  final Map<TestArea, double> areaScores; // 各能区智龄
  final Map<TestArea, double> areaDQs; // 各能区发育商
  final double overallMentalAge; // 整体智龄
  final double overallDQ; // 整体发育商
  final String overallLevel; // 整体评级

  AssessmentHistory({
    required this.id,
    required this.babyName,
    required this.actualAge,
    required this.startTime,
    required this.endTime,
    required this.areaScores,
    required this.areaDQs,
    required this.overallMentalAge,
    required this.overallDQ,
    required this.overallLevel,
  });

  // 从JSON创建对象
  factory AssessmentHistory.fromJson(Map<String, dynamic> json) {
    return AssessmentHistory(
      id: json['id'] as String,
      babyName: json['babyName'] as String,
      actualAge: json['actualAge'] as double,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      areaScores: Map.from(json['areaScores'] as Map).map(
        (key, value) => MapEntry(TestArea.values.firstWhere((e) => e.toString() == key), value as double),
      ),
      areaDQs: Map.from(json['areaDQs'] as Map).map(
        (key, value) => MapEntry(TestArea.values.firstWhere((e) => e.toString() == key), value as double),
      ),
      overallMentalAge: json['overallMentalAge'] as double,
      overallDQ: json['overallDQ'] as double,
      overallLevel: json['overallLevel'] as String,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyName': babyName,
      'actualAge': actualAge,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'areaScores': areaScores.map((key, value) => MapEntry(key.toString(), value)),
      'areaDQs': areaDQs.map((key, value) => MapEntry(key.toString(), value)),
      'overallMentalAge': overallMentalAge,
      'overallDQ': overallDQ,
      'overallLevel': overallLevel,
    };
  }

  // 获取测试时长
  Duration get duration => endTime.difference(startTime);

  // 获取测试时长文本
  String get durationText {
    final duration = this.duration;
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}分钟';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}小时${minutes}分钟';
    }
  }

  // 获取开始时间文本
  String get startTimeText {
    return '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} '
           '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  // 获取结束时间文本
  String get endTimeText {
    return '${endTime.year}-${endTime.month.toString().padLeft(2, '0')}-${endTime.day.toString().padLeft(2, '0')} '
           '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  // 获取整体发育商颜色
  Color get overallDQColor {
    if (overallDQ > 130) return Colors.green[600]!;
    if (overallDQ >= 110) return Colors.blue[600]!;
    if (overallDQ >= 80) return Colors.orange[600]!;
    if (overallDQ >= 70) return Colors.orange[700]!;
    return Colors.red[600]!;
  }
}

enum TestArea {
  motor,      // 大运动
  fineMotor,  // 精细动作
  language,   // 语言
  adaptive,   // 适应能力
  social,     // 社会行为
}

extension TestAreaExtension on TestArea {
  String get name {
    switch (this) {
      case TestArea.motor:
        return '大运动';
      case TestArea.fineMotor:
        return '精细动作';
      case TestArea.language:
        return '语言';
      case TestArea.adaptive:
        return '适应能力';
      case TestArea.social:
        return '社会行为';
    }
  }

  Color get color {
    switch (this) {
      case TestArea.motor:
        return Colors.green[600]!;
      case TestArea.fineMotor:
        return Colors.blue[600]!;
      case TestArea.language:
        return Colors.orange[600]!;
      case TestArea.adaptive:
        return Colors.purple[600]!;
      case TestArea.social:
        return Colors.red[600]!;
    }
  }
} 