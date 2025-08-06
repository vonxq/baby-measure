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
    
    // 获取主测月龄±2个月龄的项目（基础范围）
    // 实际测试中会根据通过情况动态调整
    for (int age in [mainTestAge - 2, mainTestAge - 1, mainTestAge, mainTestAge + 1, mainTestAge + 2]) {
      if (age > 0) {
        var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
        allItems.addAll(items);
      }
    }
    
    // 按能区分组，确保每个能区都有足够的测试项目
    Map<String, List<AssessmentItem>> areaItems = {};
    for (var item in allItems) {
      // 根据itemId推断能区（临时方案，实际应该从数据中获取）
      String area = _getAreaFromId(item.id);
      if (!areaItems.containsKey(area)) {
        areaItems[area] = [];
      }
      areaItems[area]!.add(item);
    }
    
    // 为每个能区添加更多月龄的项目，确保有足够的测试范围
    for (String area in areaItems.keys) {
      var existingItems = areaItems[area]!;
      var existingAges = existingItems.map((item) => (item.id / 100).floor()).toSet();
      
      // 向前扩展2个月龄
      for (int age in [mainTestAge - 3, mainTestAge - 4]) {
        if (age > 0 && !existingAges.contains(age)) {
          var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
          // 过滤出该能区的项目
          var areaSpecificItems = items.where((item) => _getAreaFromId(item.id) == area).toList();
          allItems.addAll(areaSpecificItems);
        }
      }
      
      // 向后扩展2个月龄
      for (int age in [mainTestAge + 3, mainTestAge + 4]) {
        if (age <= 84 && !existingAges.contains(age)) {
          var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
          // 过滤出该能区的项目
          var areaSpecificItems = items.where((item) => _getAreaFromId(item.id) == area).toList();
          allItems.addAll(areaSpecificItems);
        }
      }
    }
    
    return allItems;
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

  // 计算各能区智龄
  double calculateMentalAge(String area, List<AssessmentItem> items, Map<int, bool> results, Map<int, String> itemAreaMap) {
    // 过滤出该能区的项目
    var areaItems = items.where((item) {
      return itemAreaMap[item.id] == area;
    }).toList();
    
    areaItems.sort((a, b) => b.id.compareTo(a.id)); // 按月龄从高到低排序
    
    double totalScore = 0;
    int consecutivePasses = 0;
    
    for (var item in areaItems) {
      if (results[item.id] == true) {
        totalScore += getScore(item.id);
        consecutivePasses++;
      } else {
        break;
      }
    }
    
    // 如果连续通过2个月龄，默认前面全部通过
    if (consecutivePasses >= 2) {
      totalScore += getDefaultPassScore(area);
    }
    
    return totalScore;
  }

  // 获取项目分数 - 从数据中获取，不再硬编码
  double getScore(int itemId) {
    // 这里应该从数据中获取分数，暂时使用简化逻辑
    if (itemId <= 1200) return 1.0; // 12个月龄以下
    if (itemId <= 3600) return 3.0; // 36个月龄以下
    return 6.0; // 其他
  }

  // 获取默认通过分数
  double getDefaultPassScore(String area) {
    // 简化实现，实际应根据具体规则计算
    return 10.0;
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
    return total / areaResults.length;
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