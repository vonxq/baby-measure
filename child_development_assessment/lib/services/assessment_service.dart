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
      return -1;
    }
    return _ageGroups[currentIndex + 1];
  }

  List<int> getNextAges(int currentAge, int count) {
    List<int> ages = [];
    for (int i = 0; i < count; i++) {
      int nextAge = getNextAge(currentAge);
      if (nextAge < 0) {
        break;
      }
      ages.add(nextAge);
      currentAge = nextAge;
    }
    return ages;
  }

  // 获取指定月龄的上一个标准月龄
  int getPreviousAge(int currentAge) {
    int currentIndex = _ageGroups.indexOf(currentAge);
    if (currentIndex == -1 || currentIndex <= 0) {
      return -1; // 如果找不到，返回-1
    }
    return _ageGroups[currentIndex - 1];
  }

  List<int> getPreviousAges(int currentAge, int count) {
    List<int> ages = [];
    for (int i = 0; i < count; i++) {
      int prevAge = getPreviousAge(currentAge);
      if (prevAge < 0) {
        break;
      }
      ages.add(prevAge);
      currentAge = prevAge;
    }
    return ages;
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
    List<int> testedAges = _getTestedAges(mainAge, testResults, allData);
    List<int> forwardAges = getForwardTestAgesForArea(mainAge, testedAges, area, testResults, allData);
    for (int age in forwardAges) {
      var items = getCurrentAgeAreaItems(allData, age, area);
      for (var item in items) {
        if (testResults.containsKey(item.id)) {
          areaTestResults[item.id] = testResults[item.id]!;
        }
      }
    }

    // 3. 向后测试
    List<int> backwardAges = getBackwardTestAgesForArea(mainAge, testedAges, area, testResults, allData);
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
  bool _isAllPassed(int age, String area, Map<int, bool> testResults, List<AssessmentData> allData) {
    var items = getCurrentAgeAreaItems(allData, age, area);
    for (var item in items) {
      if (!testResults.containsKey(item.id)) {
        return false;
      }
      if (!testResults[item.id]!) {
        return false;
      }
    }
    return true;
  }

  bool _hasPassed(int age, String area, Map<int, bool> testResults, List<AssessmentData> allData) {
    var items = getCurrentAgeAreaItems(allData, age, area);
    for (var item in items) {
      if (testResults.containsKey(item.id)) {
        if (testResults[item.id] == true) {
          return true;
        }
      }
    }
    return false;
  }
  // 向前测试逻辑 - 按能区
  List<int> getForwardTestAgesForArea(int mainAge, List<int> testedAges, String area, Map<int, bool> testResults, List<AssessmentData> allData) {
    List<int> forwardAges = [];
    // 向前测查该能区的连续 2 个月龄的项目均通过，则该能区的向前测查结束；若该能区向前连续 2 个月龄的项目有任何一项未通过，需继续往前测查，直到该能区向前的连续 2 个月龄的项目均通过为止。
    // testedAges从小到大排序，取小于mainAge的所有List并从小到达排序
    List<int> testedForwardAges = testedAges.where((age) => age < mainAge).toList();
    // sort从小到大排序
    testedForwardAges.sort((a, b) => a.compareTo(b));
    // len = 0 没向前查过
    if (testedForwardAges.length == 0) {
      return getPreviousAges(mainAge, 2);
    }
    // len = 1 向前测过1个月龄
    if (testedForwardAges.length == 1) {
      // 没通过，还得向前测两个月龄
      if (!_isAllPassed(testedForwardAges.first, area, testResults, allData)) {
        return getPreviousAges(testedForwardAges.first, 2);
      }
      // 通过，还得向前测1个月龄
      return getPreviousAges(testedForwardAges.first, 1);
    }
    // 最小月龄没通过，还得向前测两个月龄
    if (!_isAllPassed(testedForwardAges.first, area, testResults, allData)) {
      return getPreviousAges(testedForwardAges.first, 2);
    }
    // 最小月龄通过，上一月龄没通过，还得向前测1个月龄
    if (!_isAllPassed(testedForwardAges[1], area, testResults, allData)) {
      return getPreviousAges(testedForwardAges.first, 1);
    }
    // 最小月龄通过，上一月龄通过，结束测查
    return forwardAges;
  }

  // 向后测试逻辑 - 按能区
  List<int> getBackwardTestAgesForArea(int mainAge, List<int> testedAges, String area, Map<int, bool> testResults, List<AssessmentData> allData) {
    List<int> backwardAges = [];
    //  然后从主测月龄向后测连续 2 个月龄的项目
    //  若向后测查的该能区的连续 2 个月龄的项目均不能通过
    //  则该能区的向后测查结束；若该能区向后连续 2 个月龄的项目有任何一项通过
    //  需继续往后测查，直到该能区向后的连续两个月龄的项目均不通过为止。
    // testedAges从小到大排序，取大于mainAge的所有List并从小到达排序
    List<int> testedBackwardAges = testedAges.where((age) => age > mainAge).toList();
     // sort从小到大排序
    testedBackwardAges.sort((a, b) => a.compareTo(b));
    // 第一次向后测查，没有测试过，还得向后测两个月龄
    if (testedBackwardAges.length == 0) {
      return getNextAges(mainAge, 2);
    }
    if (testedBackwardAges.length == 1) {
      // 有通过的，还得向后测两个月龄
      if (_hasPassed(testedBackwardAges.last, area, testResults, allData)) {
        return getNextAges(testedBackwardAges.last, 2);
      }
      // 没通过，还得向后测1个月龄
      return getNextAges(testedBackwardAges.last, 1);
    }
    // 最大月龄有通过的，还得向后测两个月龄
    if (_hasPassed(testedBackwardAges.last, area, testResults, allData)) {
      return getNextAges(testedBackwardAges.last, 2);
    }
    // 最大月龄没通过，上一月龄testedBackwardAges[len - 2]有通过的，还得向后测1个月龄
    if (_hasPassed(testedBackwardAges[testedBackwardAges.length - 2], area, testResults, allData)) {
      return getNextAges(testedBackwardAges.last, 1);
    }
    // 最大月龄没通过，上一月龄testedBackwardAges[len - 1]没通过，结束测查
    return backwardAges;
  }
  List<int> getAllAreaItemIds(String area, List<AssessmentData> allData) {
    return allData.where((data) => data.area == area).expand((data) => data.testItems.map((item) => item.id)).toList();
  }
  // 计算能区智龄
  double calculateAreaMentalAge(String area, Map<int, bool> areaTestResults, List<AssessmentData> allData) {
    // 把连续通过的测查项目读至最高分（连续两个月龄通过则不再往前继续测，默认前面的全部通过），不通过的项目不计算，通过的项目（含默认通过的项目）分数逐项加上，为该能区的智龄。
    // 连续通过的测查项目读至最高分
    List<int> itemIds = getAllAreaItemIds(area, allData);
    // 从小到大排序
    itemIds.sort((a, b) => a.compareTo(b));
    double score = 0;
    double accumulatedScore = 0;
    for (int i = 0; i < itemIds.length; i++) {
      if (!areaTestResults.containsKey(itemIds[i])) {
        if (score == 0) { // 如果score为0，则加上分
          accumulatedScore += getItemScoreById(itemIds[i], allData);
        }
        continue;
      }
      if (areaTestResults[itemIds[i]]!) {
        if (score == 0) { // 如果score为0，则加上分
          score = accumulatedScore;
        }
        score += getItemScoreById(itemIds[i], allData);
      }
    }
    return score;
  }

  // 获取已测试的月龄列表
  List<int> _getTestedAges(int mainAge, Map<int, bool> testResults, List<AssessmentData> allData) {
    Set<int> testedAges = {};
    for (var entry in testResults.entries) {
      int itemAge = getItemAge(entry.key, allData);
      testedAges.add(itemAge);
    }
    return testedAges.toList();
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

  // 计算单个项目的分值
  double getItemScore(int age, int itemCount) {
    double totalScore = getAreaScoreForAge('', age); // area参数在这里不重要
    if (itemCount == 0) return 0.0;
    return totalScore / itemCount;
  }

  double getItemScoreById(int itemId, List<AssessmentData> allData) {
    for (var data in allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return getItemScore(data.ageMonth, data.testItems.length);
        }
      }
    }
    return 0;
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
      
      List<int> testedAges = _getTestedAges(mainAge, testResults, allData);
      var forwardAges = getForwardTestAgesForArea(mainAge, testedAges, area, testResults, allData);
      for (int age in forwardAges) {
        var items = getCurrentAgeAreaItems(allData, age, area);
        totalItems += items.length;
      }
      
      var backwardAges = getBackwardTestAgesForArea(mainAge, testedAges, area, testResults, allData);
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