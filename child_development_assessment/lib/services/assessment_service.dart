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

  // 获取测试项目 - 按照标准测查程序
  List<AssessmentItem> getTestItems(List<AssessmentData> allData, double actualAge) {
    int mainTestAge = determineMainTestAge(actualAge);
    List<AssessmentItem> allItems = [];
    
    // 按照标准测查程序：主测月龄±2个月龄的基础范围
    // 注意：实际测试中应该根据通过情况动态调整，但为了简化实现，我们先提供足够的测试项目
    for (int age in [mainTestAge - 2, mainTestAge - 1, mainTestAge, mainTestAge + 1, mainTestAge + 2]) {
      if (age > 0) {
        var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
        allItems.addAll(items);
      }
    }
    
    // 为每个能区添加更多月龄的项目，确保有足够的测试范围
    // 这样可以支持动态测查逻辑（虽然当前UI是静态的）
    Map<String, List<AssessmentItem>> areaItems = {};
    for (var item in allItems) {
      String area = _getAreaFromId(item.id);
      if (!areaItems.containsKey(area)) {
        areaItems[area] = [];
      }
      areaItems[area]!.add(item);
    }
    
    // 为每个能区添加更多月龄的项目，支持向前和向后测查
    for (String area in areaItems.keys) {
      var existingItems = areaItems[area]!;
      var existingAges = existingItems.map((item) => (item.id / 100).floor()).toSet();
      
      // 向前扩展更多月龄（支持向前测查）
      for (int age in [mainTestAge - 3, mainTestAge - 4, mainTestAge - 5, mainTestAge - 6]) {
        if (age > 0 && !existingAges.contains(age)) {
          var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
          var areaSpecificItems = items.where((item) => _getAreaFromId(item.id) == area).toList();
          allItems.addAll(areaSpecificItems);
        }
      }
      
      // 向后扩展更多月龄（支持向后测查）
      for (int age in [mainTestAge + 3, mainTestAge + 4, mainTestAge + 5, mainTestAge + 6]) {
        if (age <= 84 && !existingAges.contains(age)) {
          var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
          var areaSpecificItems = items.where((item) => _getAreaFromId(item.id) == area).toList();
          allItems.addAll(areaSpecificItems);
        }
      }
    }
    
    return allItems;
  }

  // 动态测查逻辑（供未来实现使用）
  List<AssessmentItem> getDynamicTestItems(List<AssessmentData> allData, double actualAge, Map<int, bool> currentResults) {
    int mainTestAge = determineMainTestAge(actualAge);
    List<AssessmentItem> dynamicItems = [];
    
    // 按能区分别处理
    List<String> areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];
    
    for (String area in areas) {
      var areaItems = _getAreaItemsForAge(allData, mainTestAge, area);
      
      // 根据当前结果动态决定是否需要更多测试项目
      var additionalItems = _getAdditionalItemsForArea(allData, mainTestAge, area, currentResults);
      areaItems.addAll(additionalItems);
      
      dynamicItems.addAll(areaItems);
    }
    
    return dynamicItems;
  }

  // 获取指定能区在指定月龄的项目
  List<AssessmentItem> _getAreaItemsForAge(List<AssessmentData> allData, int age, String area) {
    var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
    return items.where((item) => _getAreaFromId(item.id) == area).toList();
  }

  // 根据当前结果获取额外需要的项目
  List<AssessmentItem> _getAdditionalItemsForArea(List<AssessmentData> allData, int mainTestAge, String area, Map<int, bool> currentResults) {
    List<AssessmentItem> additionalItems = [];
    
    // 分析当前结果，决定是否需要向前或向后测查
    // 这里可以实现真正的动态逻辑
    // 暂时返回空列表，保持当前静态实现
    
    return additionalItems;
  }

  // 根据itemId推断能区（临时方案）
  String _getAreaFromId(int itemId) {
    // 根据itemId的范围推断能区
    // 这是一个简化的实现，实际应该从数据中获取
    int monthAge = (itemId / 100).floor();
    int itemIndex = itemId % 100;
    
    // 根据月龄和项目索引推断能区
    if (monthAge <= 12) {
      // 1-12月龄：每个能区2个项目
      if (itemIndex <= 2) return 'motor';
      if (itemIndex <= 4) return 'fineMotor';
      if (itemIndex <= 6) return 'adaptive';
      if (itemIndex <= 8) return 'language';
      return 'social';
    } else {
      // 其他月龄：每个能区1个项目
      if (itemIndex <= 1) return 'motor';
      if (itemIndex <= 2) return 'fineMotor';
      if (itemIndex <= 3) return 'adaptive';
      if (itemIndex <= 4) return 'language';
      return 'social';
    }
  }

  // 从数据中获取月龄
  int getMonthAgeFromData(List<AssessmentData> allData, int itemId) {
    for (var data in allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return data.ageMonth;
        }
      }
    }
    return 0;
  }

  // 计算各能区智龄 - 按照标准计算规则
  double calculateMentalAge(String area, List<AssessmentItem> items, Map<int, bool> results, Map<int, String> itemAreaMap) {
    // 过滤出该能区的项目
    var areaItems = items.where((item) {
      return itemAreaMap[item.id] == area;
    }).toList();
    
    // 按月龄从高到低排序（从高月龄开始计算）
    areaItems.sort((a, b) => b.id.compareTo(a.id));
    
    double totalScore = 0;
    int consecutivePasses = 0;
    
    // 按照标准：把连续通过的测查项目读至最高分
    for (var item in areaItems) {
      if (results[item.id] == true) {
        totalScore += getScore(item.id);
        consecutivePasses++;
      } else {
        // 遇到不通过的项目就停止
        break;
      }
    }
    
    // 按照标准：连续两个月龄通过则不再往前继续测，默认前面的全部通过
    if (consecutivePasses >= 2) {
      // 计算默认通过的项目分数
      totalScore += _calculateDefaultPassScore(area, areaItems, consecutivePasses);
    }
    
    return totalScore;
  }

  // 计算默认通过的项目分数 - 按照标准规则
  double _calculateDefaultPassScore(String area, List<AssessmentItem> areaItems, int consecutivePasses) {
    if (consecutivePasses < 2) return 0;
    
    // 找到连续通过的最高月龄
    int highestPassAge = 0;
    for (int i = 0; i < consecutivePasses; i++) {
      int itemAge = (areaItems[i].id / 100).floor();
      if (itemAge > highestPassAge) {
        highestPassAge = itemAge;
      }
    }
    
    // 计算默认通过的项目分数（从最高月龄往前计算）
    double defaultScore = 0;
    for (var item in areaItems) {
      int itemAge = (item.id / 100).floor();
      if (itemAge < highestPassAge) {
        defaultScore += getScore(item.id);
      }
    }
    
    return defaultScore;
  }

  // 获取能区在指定月龄的分数 - 按照标准规则
  double getAreaScoreForAge(String area, int age) {
    // 按照标准：每个能区的分数
    if (age >= 1 && age <= 12) {
      return 1.0; // 1月龄～12月龄：每个能区1.0分
    } else if (age >= 15 && age <= 36) {
      return 3.0; // 15月龄～36月龄：每个能区3.0分
    } else if (age >= 42 && age <= 84) {
      return 6.0; // 42月龄～84月龄：每个能区6.0分
    }
    return 1.0; // 默认
  }

  // 获取项目分数 - 按照标准计分规则
  double getScore(int itemId) {
    int monthAge = (itemId / 100).floor();
    
    // 按照标准计分规则
    if (monthAge >= 1 && monthAge <= 12) {
      // 1月龄～12月龄：每个能区1.0分
      return 1.0;
    } else if (monthAge >= 15 && monthAge <= 36) {
      // 15月龄～36月龄：每个能区3.0分
      return 3.0;
    } else if (monthAge >= 42 && monthAge <= 84) {
      // 42月龄～84月龄：每个能区6.0分
      return 6.0;
    }
    
    // 默认情况
    return 1.0;
  }

  // 获取默认通过分数 - 按照标准计算
  double getDefaultPassScore(String area) {
    // 根据能区和月龄计算默认通过分数
    // 这里需要根据具体的月龄范围来计算
    // 暂时使用简化实现
    return 5.0;
  }

  // 计算发育商
  double calculateDevelopmentQuotient(double mentalAge, double actualAge) {
    if (actualAge == 0) return 0;
    return (mentalAge / actualAge) * 100;
  }

  // 计算总体智龄 - 按照标准计算规则
  double calculateTotalMentalAge(Map<String, double> areaResults) {
    if (areaResults.isEmpty) return 0;
    
    // 按照标准：将五个能区所得分数相加，再除以5就是总的智龄，保留一位小数
    double total = areaResults.values.reduce((a, b) => a + b);
    double average = total / areaResults.length;
    
    // 保留一位小数
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