import 'assessment_item.dart';

class AssessmentData {
  final int ageMonth;
  final String area;
  final double score;
  final List<AssessmentItem> testItems;

  AssessmentData({
    required this.ageMonth,
    required this.area,
    required this.score,
    required this.testItems,
  });

  factory AssessmentData.fromJson(Map<String, dynamic> json) {
    return AssessmentData(
      ageMonth: json['ageMonth'],
      area: json['area'],
      score: json['score'].toDouble(),
      testItems: (json['testItems'] as List)
          .map((item) => AssessmentItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageMonth': ageMonth,
      'area': area,
      'score': score,
      'testItems': testItems.map((item) => item.toJson()).toList(),
    };
  }
} 