class AssessmentItem {
  final int id;
  final String name;
  final String desc;
  final String operation;
  final String passCondition;

  AssessmentItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.operation,
    required this.passCondition,
  });

  factory AssessmentItem.fromJson(Map<String, dynamic> json) {
    return AssessmentItem(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      operation: json['operation'],
      passCondition: json['passCondition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'operation': operation,
      'passCondition': passCondition,
    };
  }
} 