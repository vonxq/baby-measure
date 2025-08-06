class AppConstants {
  // 应用信息
  static const String appName = '儿童发育评估';
  static const String appVersion = '1.0.0';
  
  // 存储键
  static const String babiesStorageKey = 'babies';
  static const String resultsStorageKey = 'assessment_results';
  
  // 月龄范围
  static const double minAgeInMonths = 0.0;
  static const double maxAgeInMonths = 84.0;
  
  // 发育水平阈值
  static const double excellentThreshold = 130.0;
  static const double goodThreshold = 110.0;
  static const double averageThreshold = 80.0;
  static const double lowThreshold = 70.0;
  
  // 能区类型
  static const List<String> areaTypes = [
    'motor',
    'fineMotor', 
    'language',
    'adaptive',
    'social',
  ];
  
  // 能区中文名称
  static const Map<String, String> areaNames = {
    'motor': '大运动能区',
    'fineMotor': '精细动作能区',
    'language': '语言能区',
    'adaptive': '适应能力能区',
    'social': '社会行为能区',
  };
  
  // 发育水平描述
  static const Map<String, String> levelDescriptions = {
    'excellent': '优秀',
    'good': '良好',
    'average': '中等',
    'low': '临界偏低',
    'disability': '智力发育障碍',
  };
  
  // 发育水平颜色
  static const Map<String, int> levelColors = {
    'excellent': 0xFF4CAF50, // 绿色
    'good': 0xFF2196F3,      // 蓝色
    'average': 0xFFFF9800,    // 橙色
    'low': 0xFFFF5722,        // 红色
    'disability': 0xFF9C27B0, // 紫色
  };
  
  // 月龄组
  static const List<int> ageGroups = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
    15, 18, 21, 24, 27, 30, 33, 36,
    42, 48, 54, 60, 66, 72, 78, 84,
  ];
  
  // 性别选项
  static const Map<String, String> genderOptions = {
    'male': '男',
    'female': '女',
  };
  
  // 错误消息
  static const String errorLoadBabies = '加载宝宝信息失败';
  static const String errorAddBaby = '添加宝宝失败';
  static const String errorUpdateBaby = '更新宝宝信息失败';
  static const String errorDeleteBaby = '删除宝宝失败';
  static const String errorLoadItems = '加载评估项目失败';
  static const String errorSaveResult = '保存评估结果失败';
  static const String errorLoadResults = '加载评估结果失败';
  static const String errorInitializeAssessment = '初始化评估失败';
  static const String errorCompleteAssessment = '完成评估失败';
  
  // 成功消息
  static const String successAddBaby = '宝宝添加成功';
  static const String successUpdateBaby = '宝宝信息更新成功';
  static const String successDeleteBaby = '宝宝删除成功';
  static const String successSaveResult = '评估结果保存成功';
  
  // 验证消息
  static const String validationNameRequired = '请输入宝宝姓名';
  static const String validationNameLength = '姓名长度不能超过20个字符';
  static const String validationBirthDateRequired = '请选择出生日期';
  static const String validationBirthDateInvalid = '出生日期无效';
  static const String validationAgeInvalid = '月龄必须在0-84个月之间';
} 