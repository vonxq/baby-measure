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

  // 获取当前月龄的测试项目
  List<AssessmentItem> getCurrentAgeItems(List<AssessmentData> allData, int mainTestAge) {
    var items = allData.where((data) => data.ageMonth == mainTestAge).expand((data) => data.testItems).toList();
    return items;
  }

  // 获取向前测查项目（低月龄）
  List<AssessmentItem> getForwardItems(List<AssessmentData> allData, int mainTestAge, Map<int, bool> currentResults) {
    List<AssessmentItem> forwardItems = [];
    
    // 检查当前月龄的测试结果
    var currentAgeItems = getCurrentAgeItems(allData, mainTestAge);
    var currentAgeResults = <String, List<bool>>{};
    
    // 按能区分组当前月龄的结果
    for (var item in currentAgeItems) {
      String area = _getAreaFromId(item.id);
      if (!currentAgeResults.containsKey(area)) {
        currentAgeResults[area] = [];
      }
      if (currentResults.containsKey(item.id)) {
        currentAgeResults[area]!.add(currentResults[item.id]!);
      }
    }
    
    // 检查每个能区是否需要向前测查
    for (String area in currentAgeResults.keys) {
      if (_shouldForwardTestForArea(allData, mainTestAge, area, currentResults)) {
        var areaForwardItems = _getForwardItemsForArea(allData, mainTestAge, area, currentResults);
        forwardItems.addAll(areaForwardItems);
      }
    }
    
    return forwardItems;
  }

  // 检查特定能区是否需要向前测查
  bool _shouldForwardTestForArea(List<AssessmentData> allData, int mainTestAge, String area, Map<int, bool> currentResults) {
    // 获取当前月龄该能区的项目
    var currentAreaItems = getCurrentAgeItems(allData, mainTestAge)
        .where((item) => _getAreaFromId(item.id) == area)
        .toList();
    
    // 检查当前月龄该能区的测试结果
    bool hasAllResults = currentAreaItems.every((item) => currentResults.containsKey(item.id));
    if (!hasAllResults) return false;
    
    // 如果当前月龄该能区全部通过，需要向前测查
    bool allPassed = currentAreaItems.every((item) => currentResults[item.id] == true);
    return allPassed;
  }

  // 获取特定能区的向前测查项目
  List<AssessmentItem> _getForwardItemsForArea(List<AssessmentData> allData, int mainTestAge, String area, Map<int, bool> currentResults) {
    List<AssessmentItem> forwardItems = [];
    
    // 从主测月龄向前查找，直到找到连续两个月龄都通过的项目
    for (int age = mainTestAge - 1; age >= 1; age--) {
      var ageItems = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
      var areaItems = ageItems.where((item) => _getAreaFromId(item.id) == area).toList();
      
      if (areaItems.isEmpty) continue;
      
      // 检查该月龄该能区的项目是否已经测试过
      bool hasTestedItems = areaItems.any((item) => currentResults.containsKey(item.id));
      
      if (!hasTestedItems) {
        forwardItems.addAll(areaItems);
      } else {
        // 如果已经测试过，检查是否全部通过
        bool allPassed = areaItems.every((item) => currentResults[item.id] == true);
        if (allPassed) {
          // 继续向前查找
          continue;
        } else {
          // 遇到不通过的项目就停止
          break;
        }
      }
    }
    
    return forwardItems;
  }

  // 获取向后测查项目（高月龄）
  List<AssessmentItem> getBackwardItems(List<AssessmentData> allData, int mainTestAge, Map<int, bool> currentResults) {
    List<AssessmentItem> backwardItems = [];
    
    // 检查当前月龄的测试结果
    var currentAgeItems = getCurrentAgeItems(allData, mainTestAge);
    var currentAgeResults = <String, List<bool>>{};
    
    // 按能区分组当前月龄的结果
    for (var item in currentAgeItems) {
      String area = _getAreaFromId(item.id);
      if (!currentAgeResults.containsKey(area)) {
        currentAgeResults[area] = [];
      }
      if (currentResults.containsKey(item.id)) {
        currentAgeResults[area]!.add(currentResults[item.id]!);
      }
    }
    
    // 检查每个能区是否需要向后测查
    for (String area in currentAgeResults.keys) {
      if (_shouldBackwardTestForArea(allData, mainTestAge, area, currentResults)) {
        var areaBackwardItems = _getBackwardItemsForArea(allData, mainTestAge, area, currentResults);
        backwardItems.addAll(areaBackwardItems);
      }
    }
    
    return backwardItems;
  }

  // 检查特定能区是否需要向后测查
  bool _shouldBackwardTestForArea(List<AssessmentData> allData, int mainTestAge, String area, Map<int, bool> currentResults) {
    // 获取当前月龄该能区的项目
    var currentAreaItems = getCurrentAgeItems(allData, mainTestAge)
        .where((item) => _getAreaFromId(item.id) == area)
        .toList();
    
    // 检查当前月龄该能区的测试结果
    bool hasAllResults = currentAreaItems.every((item) => currentResults.containsKey(item.id));
    if (!hasAllResults) return false;
    
    // 如果当前月龄该能区全部不通过，需要向后测查
    bool allFailed = currentAreaItems.every((item) => currentResults[item.id] == false);
    return allFailed;
  }

  // 获取特定能区的向后测查项目
  List<AssessmentItem> _getBackwardItemsForArea(List<AssessmentData> allData, int mainTestAge, String area, Map<int, bool> currentResults) {
    List<AssessmentItem> backwardItems = [];
    
    // 从主测月龄向后查找，直到找到连续两个月龄都不通过的项目
    for (int age = mainTestAge + 1; age <= 84; age++) {
      var ageItems = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
      var areaItems = ageItems.where((item) => _getAreaFromId(item.id) == area).toList();
      
      if (areaItems.isEmpty) continue;
      
      // 检查该月龄该能区的项目是否已经测试过
      bool hasTestedItems = areaItems.any((item) => currentResults.containsKey(item.id));
      
      if (!hasTestedItems) {
        backwardItems.addAll(areaItems);
      } else {
        // 如果已经测试过，检查是否全部不通过
        bool allFailed = areaItems.every((item) => currentResults[item.id] == false);
        if (allFailed) {
          // 继续向后查找
          continue;
        } else {
          // 遇到通过的项目就停止
          break;
        }
      }
    }
    
    return backwardItems;
  }

  // 获取测试项目 - 动态测查程序
  List<AssessmentItem> getTestItems(List<AssessmentData> allData, double actualAge, Map<int, bool> currentResults) {
    int mainTestAge = determineMainTestAge(actualAge);
    List<AssessmentItem> allItems = [];
    
    // 1. 先测试当前月龄的项目
    var currentItems = getCurrentAgeItems(allData, mainTestAge);
    allItems.addAll(currentItems);
    
    // 2. 根据当前结果决定是否需要向前测查
    var forwardItems = getForwardItems(allData, mainTestAge, currentResults);
    allItems.addAll(forwardItems);
    
    // 3. 根据当前结果决定是否需要向后测查
    var backwardItems = getBackwardItems(allData, mainTestAge, currentResults);
    allItems.addAll(backwardItems);
    
    return allItems;
  }

  // 检查是否需要继续向前测查
  bool shouldContinueForward(String area, int mainTestAge, Map<int, bool> currentResults, List<AssessmentData> allData) {
    int consecutivePasses = 0;
    
    // 检查主测月龄及之前的连续通过情况
    for (int age = mainTestAge; age >= 1; age--) {
      var areaItems = allData
          .where((data) => data.ageMonth == age)
          .expand((data) => data.testItems)
          .where((item) => _getAreaFromId(item.id) == area)
          .toList();
      
      if (areaItems.isEmpty) continue;
      
      bool allPassed = areaItems.every((item) => currentResults[item.id] == true);
      
      if (allPassed) {
        consecutivePasses++;
      } else {
        break;
      }
    }
    
    // 如果连续两个月龄都通过，则不需要继续向前测查
    return consecutivePasses < 2;
  }

  // 检查是否需要继续向后测查
  bool shouldContinueBackward(String area, int mainTestAge, Map<int, bool> currentResults, List<AssessmentData> allData) {
    int consecutiveFails = 0;
    
    // 检查主测月龄及之后的连续不通过情况
    for (int age = mainTestAge; age <= 84; age++) {
      var areaItems = allData
          .where((data) => data.ageMonth == age)
          .expand((data) => data.testItems)
          .where((item) => _getAreaFromId(item.id) == area)
          .toList();
      
      if (areaItems.isEmpty) continue;
      
      bool allFailed = areaItems.every((item) => currentResults[item.id] == false);
      
      if (allFailed) {
        consecutiveFails++;
      } else {
        break;
      }
    }
    
    // 如果连续两个月龄都不通过，则不需要继续向后测查
    return consecutiveFails < 2;
  }

  // 获取指定能区在指定月龄的项目
  List<AssessmentItem> _getAreaItemsForAge(List<AssessmentData> allData, int age, String area) {
    var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
    return items.where((item) => _getAreaFromId(item.id) == area).toList();
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

  // 获取测试阶段信息
  TestStageInfo getTestStageInfo(List<AssessmentData> allData, int mainTestAge, Map<int, bool> currentResults) {
    var currentItems = getCurrentAgeItems(allData, mainTestAge);
    var forwardItems = getForwardItems(allData, mainTestAge, currentResults);
    var backwardItems = getBackwardItems(allData, mainTestAge, currentResults);
    
    return TestStageInfo(
      currentAge: mainTestAge,
      currentItems: currentItems,
      forwardItems: forwardItems,
      backwardItems: backwardItems,
    );
  }

  // 获取各能区在当前月龄的项目数量
  Map<String, int> getAreaItemCounts(List<AssessmentItem> items) {
    Map<String, int> counts = {
      'motor': 0,
      'fineMotor': 0,
      'language': 0,
      'adaptive': 0,
      'social': 0,
    };
    
    for (var item in items) {
      String area = _getAreaFromId(item.id);
      counts[area] = (counts[area] ?? 0) + 1;
    }
    
    return counts;
  }
}

// 测试阶段信息
class TestStageInfo {
  final int currentAge;
  final List<AssessmentItem> currentItems;
  final List<AssessmentItem> forwardItems;
  final List<AssessmentItem> backwardItems;

  TestStageInfo({
    required this.currentAge,
    required this.currentItems,
    required this.forwardItems,
    required this.backwardItems,
  });

  int get totalItems => currentItems.length + forwardItems.length + backwardItems.length;
} 