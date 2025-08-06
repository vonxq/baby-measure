import '../models/assessment_data.dart';
import '../models/assessment_item.dart';

class AssessmentService {
  static const List<int> _ageGroups = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84
  ];

  // 确定主测月龄
  int determineMainTestAge(double actualAge) {
    int mainTestAge = _ageGroups[0];
    double minDiff = (actualAge - _ageGroups[0]).abs();
    
    for (int age in _ageGroups) {
      double diff = (actualAge - age).abs();
      if (diff < minDiff) {
        minDiff = diff;
        mainTestAge = age;
      }
    }
    
    return mainTestAge;
  }

  // 获取指定月龄的下一个标准月龄
  int getNextAge(int currentAge) {
    int currentIndex = _ageGroups.indexOf(currentAge);
    if (currentIndex == -1 || currentIndex >= _ageGroups.length - 1) {
      return currentAge + 1; // 如果找不到，返回下一个数字
    }
    return _ageGroups[currentIndex + 1];
  }

  // 获取指定月龄的上一个标准月龄
  int getPreviousAge(int currentAge) {
    int currentIndex = _ageGroups.indexOf(currentAge);
    if (currentIndex == -1 || currentIndex <= 0) {
      return currentAge - 1; // 如果找不到，返回上一个数字
    }
    return _ageGroups[currentIndex - 1];
  }

  // 获取指定月龄的测试项目
  List<AssessmentItem> getCurrentAgeItems(List<AssessmentData> allData, int age) {
    return allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
  }

  // 获取向前测试项目
  List<AssessmentItem> getForwardItems(List<AssessmentData> allData, int mainAge, Map<int, bool> testResults) {
    List<AssessmentItem> items = [];
    var forwardAges = getForwardTestAges(mainAge, _convertTestResults(testResults));
    for (int age in forwardAges) {
      items.addAll(getCurrentAgeItems(allData, age));
    }
    return items;
  }

  // 获取向后测试项目
  List<AssessmentItem> getBackwardItems(List<AssessmentData> allData, int mainAge, Map<int, bool> testResults) {
    List<AssessmentItem> items = [];
    var backwardAges = getBackwardTestAges(mainAge, _convertTestResults(testResults));
    for (int age in backwardAges) {
      items.addAll(getCurrentAgeItems(allData, age));
    }
    return items;
  }

  // 获取测试阶段信息
  TestStageInfo getTestStageInfo(List<AssessmentData> allData, int mainAge, Map<int, bool> testResults) {
    int totalItems = getCurrentAgeItems(allData, mainAge).length;
    var forwardItems = getForwardItems(allData, mainAge, testResults);
    var backwardItems = getBackwardItems(allData, mainAge, testResults);
    totalItems += forwardItems.length + backwardItems.length;
    
    return TestStageInfo(totalItems: totalItems);
  }

  // 获取各能区项目数量
  Map<String, int> getAreaItemCounts(List<AssessmentItem> items) {
    Map<String, int> counts = {
      'motor': 0,
      'fineMotor': 0,
      'language': 0,
      'adaptive': 0,
      'social': 0,
    };
    
    for (var item in items) {
      // 这里需要根据实际情况获取能区信息
      String area = 'motor'; // 默认值，实际应该从数据中获取
      counts[area] = (counts[area] ?? 0) + 1;
    }
    
    return counts;
  }

  // 转换测试结果格式
  Map<int, Map<String, bool>> _convertTestResults(Map<int, bool> testResults) {
    Map<int, Map<String, bool>> converted = {};
    for (var entry in testResults.entries) {
      int itemId = entry.key;
      bool passed = entry.value;
      // 这里需要根据itemId获取月龄和能区信息
      int age = 1; // 默认值，实际应该从数据中获取
      String area = 'motor'; // 默认值，实际应该从数据中获取
      
      if (!converted.containsKey(age)) {
        converted[age] = {};
      }
      converted[age]![area] = passed;
    }
    return converted;
  }

  // 测试指定月龄并返回结果
  AgeTestResult testAge(List<AssessmentData> allData, int age) {
    var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
    
    // 按能区分组
    Map<String, List<AssessmentItem>> areaItems = {};
    for (var item in items) {
      String area = getAreaFromData(allData, item.id);
      if (!areaItems.containsKey(area)) {
        areaItems[area] = [];
      }
      areaItems[area]!.add(item);
    }
    
    return AgeTestResult(
      age: age,
      totalItems: items.length,
      areaItems: areaItems,
    );
  }

  // 向前测试逻辑
  List<int> getForwardTestAges(int mainAge, Map<int, Map<String, bool>> ageResults) {
    List<int> forwardAges = [];
    int currentAge = mainAge;
    
    // 先测试前两个标准月龄
    for (int i = 0; i < 2; i++) {
      int prevAge = getPreviousAge(currentAge);
      if (prevAge >= 1) {
        forwardAges.add(prevAge);
        currentAge = prevAge;
      } else {
        break;
      }
    }
    
    // 检查是否需要继续向前测试
    for (int age in forwardAges) {
      if (ageResults.containsKey(age)) {
        var results = ageResults[age]!;
        // 检查是否有不通过的能区
        bool hasFailed = results.values.any((passed) => !passed);
        if (hasFailed) {
          // 继续向前测试
          int nextPrevAge = getPreviousAge(age);
          if (nextPrevAge >= 1 && !forwardAges.contains(nextPrevAge)) {
            forwardAges.add(nextPrevAge);
          }
        }
      }
    }
    
    return forwardAges;
  }

  // 向后测试逻辑
  List<int> getBackwardTestAges(int mainAge, Map<int, Map<String, bool>> ageResults) {
    List<int> backwardAges = [];
    int currentAge = mainAge;
    
    // 先测试后两个标准月龄
    for (int i = 0; i < 2; i++) {
      int nextAge = getNextAge(currentAge);
      if (nextAge <= 84) {
        backwardAges.add(nextAge);
        currentAge = nextAge;
      } else {
        break;
      }
    }
    
    // 检查是否需要继续向后测试
    for (int age in backwardAges) {
      if (ageResults.containsKey(age)) {
        var results = ageResults[age]!;
        // 检查是否有通过的能区
        bool hasPassed = results.values.any((passed) => passed);
        if (hasPassed) {
          // 继续向后测试
          int nextNextAge = getNextAge(age);
          if (nextNextAge <= 84 && !backwardAges.contains(nextNextAge)) {
            backwardAges.add(nextNextAge);
          }
        }
      }
    }
    
    return backwardAges;
  }

  // 计算指定月龄的分数
  double calculateAgeScore(int age, Map<String, bool> areaResults) {
    double totalScore = 0;
    
    for (String area in areaResults.keys) {
      if (areaResults[area] == true) {
        totalScore += getAreaScoreForAge(area, age);
      }
    }
    
    return totalScore;
  }

  // 获取能区在指定月龄的分数
  double getAreaScoreForAge(String area, int age) {
    if (age >= 1 && age <= 12) {
      return 1.0; // 1月龄～12月龄：每个能区1.0分
    } else if (age >= 15 && age <= 36) {
      return 3.0; // 15月龄～36月龄：每个能区3.0分
    } else if (age >= 42 && age <= 84) {
      return 6.0; // 42月龄～84月龄：每个能区6.0分
    }
    return 1.0; // 默认
  }

  // 计算智龄 - 按照标准规则
  double calculateMentalAge(String area, List<AssessmentItem> currentTestItems, Map<int, bool> testResults, Map<int, String> itemAreaMap) {
    double totalScore = 0;
    
    // 计算当前测试项目中该能区的分数
    for (var item in currentTestItems) {
      if (itemAreaMap[item.id] == area && testResults[item.id] == true) {
        // 根据item的月龄计算分数
        int age = getItemAge(item.id);
        totalScore += getAreaScoreForAge(area, age);
      }
    }
    
    return totalScore;
  }

  // 获取项目的月龄
  int getItemAge(int itemId) {
    // 这里需要根据实际情况获取item的月龄
    // 暂时返回默认值
    return 1;
  }

  // 从数据中获取能区信息
  String getAreaFromData(List<AssessmentData> allData, int itemId) {
    for (var data in allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return data.area;
        }
      }
    }
    // 如果找不到，使用推断方法
    return _getAreaFromId(itemId);
  }

  // 根据itemId推断能区（临时方案）
  String _getAreaFromId(int itemId) {
    // 根据实际数据结构分析ID规律
    int monthAge = (itemId / 10).floor(); // 每10个ID为一个周期
    int itemIndex = itemId % 10;
    
    // 根据实际数据结构调整
    if (monthAge <= 12) {
      if (itemIndex <= 1) return 'motor';
      if (itemIndex <= 3) return 'fineMotor';
      if (itemIndex <= 5) return 'adaptive';
      if (itemIndex <= 7) return 'language';
      return 'social';
    } else {
      if (itemIndex <= 0) return 'motor';
      if (itemIndex <= 1) return 'fineMotor';
      if (itemIndex <= 2) return 'adaptive';
      if (itemIndex <= 3) return 'language';
      return 'social';
    }
  }

  // 计算发育商
  double calculateDevelopmentQuotient(double mentalAge, double actualAge) {
    if (actualAge == 0) return 0;
    return (mentalAge / actualAge) * 100;
  }

  // 计算总体智龄
  double calculateTotalMentalAge(Map<String, double> areaResults) {
    if (areaResults.isEmpty) return 0;
    
    double total = areaResults.values.reduce((a, b) => a + b);
    double average = total / areaResults.length;
    
    return double.parse(average.toStringAsFixed(1));
  }

  // 获取能区名称
  String getAreaName(String area) {
    switch (area) {
      case 'motor':
        return '大运动';
      case 'fineMotor':
        return '精细动作';
      case 'language':
        return '语言';
      case 'adaptive':
        return '适应能力';
      case 'social':
        return '社会行为';
      default:
        return '未知';
    }
  }
}

// 月龄测试结果
class AgeTestResult {
  final int age;
  final int totalItems;
  final Map<String, List<AssessmentItem>> areaItems;

  AgeTestResult({
    required this.age,
    required this.totalItems,
    required this.areaItems,
  });
}

// 测试阶段信息
class TestStageInfo {
  final int totalItems;

  TestStageInfo({
    required this.totalItems,
  });
} 