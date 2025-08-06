import '../models/assessment_data.dart';
import '../models/assessment_item.dart';

class DynamicAssessmentService {
  static const List<int> _ageGroups = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84
  ];

  // 从JSON数据中获取itemId到area的映射
  Map<int, String> _buildItemIdToAreaMap(List<AssessmentData> allData) {
    Map<int, String> itemIdToArea = {};
    for (var data in allData) {
      for (var item in data.testItems) {
        itemIdToArea[item.id] = data.area;
      }
    }
    return itemIdToArea;
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

  // 测试指定月龄并返回结果
  AgeTestResult testAge(List<AssessmentData> allData, int age) {
    var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
    
    // 按能区分组
    Map<String, List<AssessmentItem>> areaItems = {};
    for (var item in items) {
      String area = _getAreaFromData(allData, item.id);
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

  // 从数据中获取能区信息
  String _getAreaFromData(List<AssessmentData> allData, int itemId) {
    for (var data in allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return data.area;
        }
      }
    }
    return 'unknown'; // 如果找不到，返回unknown
  }

  // 执行完整的动态测评流程
  DynamicAssessmentResult executeDynamicAssessment(
    List<AssessmentData> allData,
    int mainTestAge,
    Map<int, Map<String, List<bool>>> testResults, // 月龄 -> 能区 -> 项目通过情况
  ) {
    // 1. 测试主测月龄
    var mainAgeResult = _testAgeWithResults(allData, mainTestAge, testResults[mainTestAge] ?? {});
    
    // 2. 向前测试
    List<int> forwardAges = _getForwardTestAges(mainTestAge, testResults);
    Map<int, AgeTestResult> forwardResults = {};
    for (int age in forwardAges) {
      forwardResults[age] = _testAgeWithResults(allData, age, testResults[age] ?? {});
    }
    
    // 3. 向后测试
    List<int> backwardAges = _getBackwardTestAges(mainTestAge, testResults);
    Map<int, AgeTestResult> backwardResults = {};
    for (int age in backwardAges) {
      backwardResults[age] = _testAgeWithResults(allData, age, testResults[age] ?? {});
    }
    
    // 4. 汇总所有测试月龄
    List<int> allTestAges = [mainTestAge, ...forwardAges, ...backwardAges];
    allTestAges.sort();
    
    // 5. 计算总分
    double totalScore = _calculateTotalScore(allTestAges, testResults);
    
    return DynamicAssessmentResult(
      mainTestAge: mainTestAge,
      allTestAges: allTestAges,
      forwardAges: forwardAges,
      backwardAges: backwardAges,
      mainAgeResult: mainAgeResult,
      forwardResults: forwardResults,
      backwardResults: backwardResults,
      totalScore: totalScore,
    );
  }

  // 向前测试逻辑
  List<int> getForwardTestAges(int mainAge, Map<int, Map<String, List<bool>>> ageResults) {
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
    bool needMoreForward = true;
    while (needMoreForward) {
      needMoreForward = false;
      for (int age in forwardAges) {
        if (ageResults.containsKey(age)) {
          var results = ageResults[age]!;
          // 检查是否有不通过的能区
          bool hasFailed = false;
          for (String area in results.keys) {
            if (results[area]!.contains(false)) {
              hasFailed = true;
              break;
            }
          }
          if (hasFailed) {
            // 继续向前测试
            int nextPrevAge = getPreviousAge(age);
            if (nextPrevAge >= 1 && !forwardAges.contains(nextPrevAge)) {
              forwardAges.add(nextPrevAge);
              needMoreForward = true;
            }
          }
        }
      }
    }
    
    return forwardAges;
  }

  // 向后测试逻辑
  List<int> getBackwardTestAges(int mainAge, Map<int, Map<String, List<bool>>> ageResults) {
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
    bool needMoreBackward = true;
    while (needMoreBackward) {
      needMoreBackward = false;
      for (int age in backwardAges) {
        if (ageResults.containsKey(age)) {
          var results = ageResults[age]!;
          // 检查是否有通过的能区
          bool hasPassed = false;
          for (String area in results.keys) {
            if (results[area]!.contains(true)) {
              hasPassed = true;
              break;
            }
          }
          if (hasPassed) {
            // 继续向后测试
            int nextNextAge = getNextAge(age);
            if (nextNextAge <= 84 && !backwardAges.contains(nextNextAge)) {
              backwardAges.add(nextNextAge);
              needMoreBackward = true;
            }
          }
        }
      }
    }
    
    return backwardAges;
  }

  // 测试月龄并返回结果
  AgeTestResult _testAgeWithResults(
    List<AssessmentData> allData,
    int age,
    Map<String, List<bool>> areaResults,
  ) {
    var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
    
    // 按能区分组
    Map<String, List<AssessmentItem>> areaItems = {};
    Map<String, int> passedCounts = {};
    Map<String, int> totalCounts = {};
    
    for (var item in items) {
      String area = _getAreaFromData(allData, item.id);
      if (!areaItems.containsKey(area)) {
        areaItems[area] = [];
        passedCounts[area] = 0;
        totalCounts[area] = 0;
      }
      areaItems[area]!.add(item);
      totalCounts[area] = totalCounts[area]! + 1;
      
      // 计算通过的项目数
      if (areaResults.containsKey(area)) {
        var results = areaResults[area]!;
        int itemIndex = areaItems[area]!.indexOf(item);
        if (itemIndex < results.length && results[itemIndex] == true) {
          passedCounts[area] = passedCounts[area]! + 1;
        }
      }
    }
    
    return AgeTestResult(
      age: age,
      totalItems: items.length,
      areaItems: areaItems,
      passedCounts: passedCounts,
      totalCounts: totalCounts,
    );
  }

  // 计算总分
  double _calculateTotalScore(List<int> allTestAges, Map<int, Map<String, List<bool>>> testResults) {
    double totalScore = 0;
    
    for (int age in allTestAges) {
      if (testResults.containsKey(age)) {
        var ageResults = testResults[age]!;
        for (String area in ageResults.keys) {
          var results = ageResults[area]!;
          int passedCount = results.where((passed) => passed).length;
          int totalCount = results.length;
          
          // 如果该能区有通过的项目，计算分数
          if (passedCount > 0) {
            double areaScore = getAreaScoreForAge(area, age);
            totalScore += areaScore;
          }
        }
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
  final Map<String, int>? passedCounts;
  final Map<String, int>? totalCounts;

  AgeTestResult({
    required this.age,
    required this.totalItems,
    required this.areaItems,
    this.passedCounts,
    this.totalCounts,
  });
}

// 动态测评结果
class DynamicAssessmentResult {
  final int mainTestAge;
  final List<int> allTestAges;
  final List<int> forwardAges;
  final List<int> backwardAges;
  final AgeTestResult mainAgeResult;
  final Map<int, AgeTestResult> forwardResults;
  final Map<int, AgeTestResult> backwardResults;
  final double totalScore;

  DynamicAssessmentResult({
    required this.mainTestAge,
    required this.allTestAges,
    required this.forwardAges,
    required this.backwardAges,
    required this.mainAgeResult,
    required this.forwardResults,
    required this.backwardResults,
    required this.totalScore,
  });
} 