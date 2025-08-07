import '../models/assessment_data.dart';
import '../models/assessment_item.dart';

class AssessmentService {
  static const List<int> _ageGroups = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84
  ];

  static const List<String> _areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];

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

  // 获取指定月龄和能区的测试项目
  List<AssessmentItem> getAreaItems(List<AssessmentData> allData, int age, String area) {
    return allData
        .where((data) => data.ageMonth == age && data.area == area)
        .expand((data) => data.testItems)
        .toList();
  }

  // 获取指定能区在指定月龄的测试项目
  List<AssessmentItem> getCurrentAgeAreaItems(List<AssessmentData> allData, int age, String area) {
    return getAreaItems(allData, age, area);
  }

  // 按能区进行测试 - 主要测试方法
  AreaTestResult testArea(List<AssessmentData> allData, int mainAge, String area, Map<int, bool> testResults) {
    // 1. 测试主测月龄的项目
    List<AssessmentItem> mainAgeItems = getCurrentAgeAreaItems(allData, mainAge, area);
    Map<int, bool> areaTestResults = {};
    
    // 记录主测月龄的测试结果
    for (var item in mainAgeItems) {
      if (testResults.containsKey(item.id)) {
        areaTestResults[item.id] = testResults[item.id]!;
      }
    }

    // 2. 向前测试
    List<int> forwardAges = getForwardTestAgesForArea(mainAge, area, testResults, allData);
    for (int age in forwardAges) {
      var items = getCurrentAgeAreaItems(allData, age, area);
      for (var item in items) {
        if (testResults.containsKey(item.id)) {
          areaTestResults[item.id] = testResults[item.id]!;
        }
      }
    }

    // 3. 向后测试
    List<int> backwardAges = getBackwardTestAgesForArea(mainAge, area, testResults, allData);
    for (int age in backwardAges) {
      var items = getCurrentAgeAreaItems(allData, age, area);
      for (var item in items) {
        if (testResults.containsKey(item.id)) {
          areaTestResults[item.id] = testResults[item.id]!;
        }
      }
    }

    // 4. 计算该能区的智龄
    double mentalAge = calculateAreaMentalAge(area, areaTestResults, allData);

    return AreaTestResult(
      area: area,
      mainAge: mainAge,
      forwardAges: forwardAges,
      backwardAges: backwardAges,
      testResults: areaTestResults,
      mentalAge: mentalAge,
    );
  }

  // 向前测试逻辑 - 按能区
  List<int> getForwardTestAgesForArea(int mainAge, String area, Map<int, bool> testResults, List<AssessmentData> allData) {
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
    bool continueForward = true;
    while (continueForward) {
      continueForward = false;
      
      for (int age in forwardAges) {
        var items = getCurrentAgeAreaItems(allData, age, area);
        bool allPassed = true;
        bool hasTested = false;
        
        for (var item in items) {
          if (testResults.containsKey(item.id)) {
            hasTested = true;
            if (!testResults[item.id]!) {
              allPassed = false;
              break;
            }
          }
        }
        
        // 如果该月龄有测试项目且不是全部通过，需要继续向前测试
        if (hasTested && !allPassed) {
          int nextPrevAge = getPreviousAge(age);
          if (nextPrevAge >= 1 && !forwardAges.contains(nextPrevAge)) {
            forwardAges.add(nextPrevAge);
            continueForward = true;
          }
        }
      }
    }
    
    return forwardAges;
  }

  // 向后测试逻辑 - 按能区
  List<int> getBackwardTestAgesForArea(int mainAge, String area, Map<int, bool> testResults, List<AssessmentData> allData) {
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
    bool continueBackward = true;
    while (continueBackward) {
      continueBackward = false;
      
      for (int age in backwardAges) {
        var items = getCurrentAgeAreaItems(allData, age, area);
        bool allFailed = true;
        bool hasTested = false;
        
        for (var item in items) {
          if (testResults.containsKey(item.id)) {
            hasTested = true;
            if (testResults[item.id]!) {
              allFailed = false;
              break;
            }
          }
        }
        
        // 如果该月龄有测试项目且不是全部不通过，需要继续向后测试
        if (hasTested && !allFailed) {
          int nextNextAge = getNextAge(age);
          if (nextNextAge <= 84 && !backwardAges.contains(nextNextAge)) {
            backwardAges.add(nextNextAge);
            continueBackward = true;
          }
        }
      }
    }
    
    return backwardAges;
  }

  // 计算能区智龄
  double calculateAreaMentalAge(String area, Map<int, bool> areaTestResults, List<AssessmentData> allData) {
    double totalScore = 0;
    
    // 获取所有测试过的项目，按月龄排序
    List<MapEntry<int, bool>> sortedResults = areaTestResults.entries.toList();
    sortedResults.sort((a, b) {
      int ageA = getItemAge(a.key, allData);
      int ageB = getItemAge(b.key, allData);
      return ageA.compareTo(ageB);
    });
    
    // 找到连续通过的最高月龄
    int highestPassedAge = 0;
    for (var entry in sortedResults) {
      if (entry.value) { // 通过的项目
        int itemAge = getItemAge(entry.key, allData);
        if (itemAge > highestPassedAge) {
          highestPassedAge = itemAge;
        }
      }
    }
    
    // 计算智龄：连续通过的项目读至最高分
    for (var entry in sortedResults) {
      if (entry.value) { // 只计算通过的项目
        int itemAge = getItemAge(entry.key, allData);
        if (itemAge <= highestPassedAge) {
          // 计算该月龄的分数
          double ageScore = getAreaScoreForAge(area, itemAge);
          // 获取该月龄该能区的项目数量
          int itemCount = getCurrentAgeAreaItems(allData, itemAge, area).length;
          if (itemCount > 0) {
            totalScore += ageScore / itemCount; // 平均分配分数
          }
        }
      }
    }
    
    return totalScore;
  }

  // 获取项目的月龄
  int getItemAge(int itemId, List<AssessmentData> allData) {
    for (var data in allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return data.ageMonth;
        }
      }
    }
    return 1; // 默认值
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

  // 获取所有能区
  List<String> getAllAreas() {
    return _areas;
  }

  // 获取指定月龄的测试项目（按能区分组）
  Map<String, List<AssessmentItem>> getCurrentAgeItemsByArea(List<AssessmentData> allData, int age) {
    Map<String, List<AssessmentItem>> areaItems = {};
    
    for (String area in _areas) {
      areaItems[area] = getCurrentAgeAreaItems(allData, age, area);
    }
    
    return areaItems;
  }

  // 获取测试阶段信息
  TestStageInfo getTestStageInfo(List<AssessmentData> allData, int mainAge, Map<int, bool> testResults) {
    int totalItems = 0;
    
    for (String area in _areas) {
      var mainItems = getCurrentAgeAreaItems(allData, mainAge, area);
      totalItems += mainItems.length;
      
      var forwardAges = getForwardTestAgesForArea(mainAge, area, testResults, allData);
      for (int age in forwardAges) {
        var items = getCurrentAgeAreaItems(allData, age, area);
        totalItems += items.length;
      }
      
      var backwardAges = getBackwardTestAgesForArea(mainAge, area, testResults, allData);
      for (int age in backwardAges) {
        var items = getCurrentAgeAreaItems(allData, age, area);
        totalItems += items.length;
      }
    }
    
    return TestStageInfo(totalItems: totalItems);
  }
}

// 能区测试结果
class AreaTestResult {
  final String area;
  final int mainAge;
  final List<int> forwardAges;
  final List<int> backwardAges;
  final Map<int, bool> testResults;
  final double mentalAge;

  AreaTestResult({
    required this.area,
    required this.mainAge,
    required this.forwardAges,
    required this.backwardAges,
    required this.testResults,
    required this.mentalAge,
  });
}

// 测试阶段信息
class TestStageInfo {
  final int totalItems;

  TestStageInfo({
    required this.totalItems,
  });
} 