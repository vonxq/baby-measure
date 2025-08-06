class AssessmentItem {
  final String id;
  final String category;
  final String ageGroup;
  final String itemName;
  final String description;
  final String passCriteria;
  final double score;
  final bool isImportant;
  final bool canAskParent;

  AssessmentItem({
    required this.id,
    required this.category,
    required this.ageGroup,
    required this.itemName,
    required this.description,
    required this.passCriteria,
    required this.score,
    required this.isImportant,
    required this.canAskParent,
  });

  // 从JSON创建对象
  factory AssessmentItem.fromJson(Map<String, dynamic> json) {
    return AssessmentItem(
      id: json['id'],
      category: json['category'],
      ageGroup: json['age_group'],
      itemName: json['item_name'],
      description: json['description'],
      passCriteria: json['pass_criteria'],
      score: (json['score'] as num).toDouble(),
      isImportant: json['is_important'] ?? false,
      canAskParent: json['can_ask_parent'] ?? false,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'age_group': ageGroup,
      'item_name': itemName,
      'description': description,
      'pass_criteria': passCriteria,
      'score': score,
      'is_important': isImportant,
      'can_ask_parent': canAskParent,
    };
  }

  // 获取能区类型
  String get areaType {
    switch (category) {
      case '大运动':
        return 'motor';
      case '精细动作':
        return 'fineMotor';
      case '语言':
        return 'language';
      case '适应能力':
        return 'adaptive';
      case '社会行为':
        return 'social';
      default:
        return 'unknown';
    }
  }

  // 获取能区中文名称
  String get areaName {
    switch (category) {
      case '大运动':
        return '大运动能区';
      case '精细动作':
        return '精细动作能区';
      case '语言':
        return '语言能区';
      case '适应能力':
        return '适应能力能区';
      case '社会行为':
        return '社会行为能区';
      default:
        return '未知能区';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssessmentItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AssessmentItem(id: $id, category: $category, itemName: $itemName)';
  }
} 