class AssessmentResult {
  final String id;
  final String babyId;
  final DateTime testDate;
  final double ageInMonths;
  final int mainTestAge;
  final Map<String, AreaResult> areaResults;
  final double totalMentalAge;
  final double developmentQuotient;
  final String level;
  final String status;
  final DateTime createdAt;

  AssessmentResult({
    required this.id,
    required this.babyId,
    required this.testDate,
    required this.ageInMonths,
    required this.mainTestAge,
    required this.areaResults,
    required this.totalMentalAge,
    required this.developmentQuotient,
    required this.level,
    required this.status,
    required this.createdAt,
  });

  // 从JSON创建对象
  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    Map<String, AreaResult> areaResults = {};
    if (json['areaResults'] != null) {
      (json['areaResults'] as Map<String, dynamic>).forEach((key, value) {
        areaResults[key] = AreaResult.fromJson(value);
      });
    }

    return AssessmentResult(
      id: json['id'],
      babyId: json['babyId'],
      testDate: DateTime.parse(json['testDate']),
      ageInMonths: (json['ageInMonths'] as num).toDouble(),
      mainTestAge: json['mainTestAge'],
      areaResults: areaResults,
      totalMentalAge: (json['totalMentalAge'] as num).toDouble(),
      developmentQuotient: (json['developmentQuotient'] as num).toDouble(),
      level: json['level'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> areaResultsJson = {};
    areaResults.forEach((key, value) {
      areaResultsJson[key] = value.toJson();
    });

    return {
      'id': id,
      'babyId': babyId,
      'testDate': testDate.toIso8601String(),
      'ageInMonths': ageInMonths,
      'mainTestAge': mainTestAge,
      'areaResults': areaResultsJson,
      'totalMentalAge': totalMentalAge,
      'developmentQuotient': developmentQuotient,
      'level': level,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 获取发育水平描述
  String get levelDescription {
    switch (level) {
      case 'excellent':
        return '优秀';
      case 'good':
        return '良好';
      case 'average':
        return '中等';
      case 'low':
        return '临界偏低';
      case 'disability':
        return '智力发育障碍';
      default:
        return '未知';
    }
  }

  // 获取发育水平颜色
  int get levelColor {
    switch (level) {
      case 'excellent':
        return 0xFF4CAF50; // 绿色
      case 'good':
        return 0xFF2196F3; // 蓝色
      case 'average':
        return 0xFFFF9800; // 橙色
      case 'low':
        return 0xFFFF5722; // 红色
      case 'disability':
        return 0xFF9C27B0; // 紫色
      default:
        return 0xFF757575; // 灰色
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssessmentResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AssessmentResult(id: $id, babyId: $babyId, developmentQuotient: $developmentQuotient)';
  }
}

class AreaResult {
  final double score;
  final double mentalAge;

  AreaResult({
    required this.score,
    required this.mentalAge,
  });

  factory AreaResult.fromJson(Map<String, dynamic> json) {
    return AreaResult(
      score: (json['score'] as num).toDouble(),
      mentalAge: (json['mentalAge'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'mentalAge': mentalAge,
    };
  }
} 