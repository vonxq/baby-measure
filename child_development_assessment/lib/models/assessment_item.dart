class AssessmentItem {
  final int id;
  final String name;
  final String desc;
  final String operation;
  final String passCondition;
  final double score; // 单个项目的分值
  final String area; // 添加能区字段

  AssessmentItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.operation,
    required this.passCondition,
    required this.score,
    required this.area, // 添加能区参数
  });

  factory AssessmentItem.fromJson(Map<String, dynamic> json) {
    return AssessmentItem(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      operation: json['operation'],
      passCondition: json['passCondition'],
      score: json['score']?.toDouble() ?? 0.0,
      area: json['area'] ?? '', // 从JSON读取能区
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'operation': operation,
      'passCondition': passCondition,
      'score': score,
      'area': area, // 序列化能区
    };
  }
} 