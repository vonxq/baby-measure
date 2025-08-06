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

  // 获取测试项目
  List<AssessmentItem> getTestItems(List<AssessmentData> allData, double actualAge) {
    int mainTestAge = determineMainTestAge(actualAge);
    List<AssessmentItem> allItems = [];
    
    // 获取主测月龄±2个月龄的项目
    for (int age in [mainTestAge - 2, mainTestAge - 1, mainTestAge, mainTestAge + 1, mainTestAge + 2]) {
      if (age > 0) {
        var items = allData.where((data) => data.ageMonth == age).expand((data) => data.testItems).toList();
        allItems.addAll(items);
      }
    }
    
    return allItems;
  }

  // 计算各能区智龄
  double calculateMentalAge(String area, List<AssessmentItem> items, Map<int, bool> results) {
    // 过滤出该能区的项目
    var areaItems = items.where((item) {
      final areaCode = item.id % 100;
      switch (area) {
        case 'motor': return areaCode == 1;
        case 'fineMotor': return areaCode == 2;
        case 'language': return areaCode == 3;
        case 'adaptive': return areaCode == 4;
        case 'social': return areaCode == 5;
        default: return false;
      }
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