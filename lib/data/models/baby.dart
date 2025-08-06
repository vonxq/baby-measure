class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  // 计算当前月龄
  double get ageInMonths {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;
    
    double totalMonths = years * 12 + months + days / 30.0;
    return double.parse(totalMonths.toStringAsFixed(1));
  }

  // 从JSON创建对象
  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      gender: json['gender'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 复制对象
  Baby copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Baby && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Baby(id: $id, name: $name, birthDate: $birthDate, gender: $gender)';
  }
} 