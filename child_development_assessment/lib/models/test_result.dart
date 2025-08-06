class TestResult {
  final String userName;
  final String date;
  final String birthDate;
  final double month;
  final List<AreaResult> testResults;
  final AreaResult allResult;

  TestResult({
    required this.userName,
    required this.date,
    required this.birthDate,
    required this.month,
    required this.testResults,
    required this.allResult,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      userName: json['userName'],
      date: json['date'],
      birthDate: json['birthDate'],
      month: json['month'].toDouble(),
      testResults: (json['testResults'] as List)
          .map((item) => AreaResult.fromJson(item))
          .toList(),
      allResult: AreaResult.fromJson(json['allResult']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'date': date,
      'birthDate': birthDate,
      'month': month,
      'testResults': testResults.map((result) => result.toJson()).toList(),
      'allResult': allResult.toJson(),
    };
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