import 'package:flutter/foundation.dart';
import '../models/assessment_data.dart';
import '../models/assessment_item.dart';
import '../models/test_result.dart';
import '../services/assessment_service.dart';
import '../services/dynamic_assessment_service.dart';
import '../services/data_service.dart';

enum TestStage {
  current,    // 当前月龄
  forward,    // 向前测查
  backward,   // 向后测查
  completed   // 测试完成
}

class AssessmentProvider with ChangeNotifier {
  final AssessmentService _assessmentService = AssessmentService();
  final DynamicAssessmentService _dynamicAssessmentService = DynamicAssessmentService();
  final DataService _dataService = DataService();

  List<AssessmentData> _allData = [];
  List<AssessmentItem> _currentTestItems = [];
  final Map<int, bool> _testResults = {};
  final Map<int, String> _itemAreaMap = {}; // id到area的映射
  int _currentItemIndex = 0;
  bool _isLoading = false;
  String _error = '';
  TestResult? _finalResult;
  String _userName = '';
  double _actualAge = 0.0;
  int _mainTestAge = 0;
  
  // 动态测评相关
  TestStage _currentStage = TestStage.current;
  List<AssessmentItem> _currentStageItems = [];
  int _currentStageItemIndex = 0;
  Map<String, int> _areaItemCounts = {};
  Map<int, Map<String, List<bool>>> _dynamicTestResults = {}; // 月龄 -> 能区 -> 项目通过情况
  
  // 当前测试的月龄跟踪
  int _currentTestAge = 0;
  List<int> _forwardTestAges = [];
  List<int> _backwardTestAges = [];
  int _currentForwardIndex = 0;
  int _currentBackwardIndex = 0;
  
  // 连续通过/不通过跟踪
  Map<String, int> _consecutivePassCount = {}; // 能区 -> 连续通过次数
  Map<String, int> _consecutiveFailCount = {}; // 能区 -> 连续不通过次数

  // Getters
  List<AssessmentData> get allData => _allData;
  List<AssessmentItem> get currentTestItems => _currentTestItems;
  Map<int, bool> get testResults => _testResults;
  int get currentItemIndex => _currentItemIndex;
  bool get isLoading => _isLoading;
  String get error => _error;
  TestResult? get finalResult => _finalResult;
  AssessmentItem? get currentItem => _currentStageItems.isNotEmpty && _currentStageItemIndex < _currentStageItems.length 
      ? _currentStageItems[_currentStageItemIndex] 
      : null;
  double get progress => _getTotalProgress();
  
  // 动态测评相关getters
  TestStage get currentStage => _currentStage;
  List<AssessmentItem> get currentStageItems => _currentStageItems;
  int get currentStageItemIndex => _currentStageItemIndex;
  Map<String, int> get areaItemCounts => _areaItemCounts;
  int get mainTestAge => _mainTestAge;
  Map<int, Map<String, List<bool>>> get dynamicTestResults => _dynamicTestResults;
  
  // 获取item的area
  String getItemArea(int itemId) {
    return _itemAreaMap[itemId] ?? 'unknown';
  }

  // 获取item的月龄
  int getItemMonthAge(int itemId) {
    for (var data in _allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return data.ageMonth;
        }
      }
    }
    return 0;
  }

  // 从数据中获取月龄
  int getMonthAgeFromData(int itemId) {
    for (var data in _allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return data.ageMonth;
        }
      }
    }
    return 0;
  }

  // 初始化数据
  Future<void> initializeData() async {
    _setLoading(true);
    try {
      _allData = await _dataService.loadAssessmentData();
      _buildItemAreaMap(); // 建立id到area的映射
      _error = '';
    } catch (e) {
      _error = '加载数据失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 建立id到area的映射关系
  void _buildItemAreaMap() {
    _itemAreaMap.clear();
    for (var data in _allData) {
      for (var item in data.testItems) {
        _itemAreaMap[item.id] = data.area;
      }
    }
  }

  // 开始动态测评
  void startDynamicAssessment(String userName, double actualAge) {
    _userName = userName;
    _actualAge = actualAge;
    _mainTestAge = _assessmentService.determineMainTestAge(actualAge);
    _currentStage = TestStage.current;
    _currentStageItemIndex = 0;
    _testResults.clear();
    _dynamicTestResults.clear();
    
    // 初始化月龄跟踪
    _currentTestAge = _mainTestAge;
    _initializeTestAges();
    _resetConsecutiveCounts();
    
    _loadCurrentStageItems();
    notifyListeners();
  }

  // 初始化测试月龄
  void _initializeTestAges() {
    // 获取向前测试月龄（主测月龄前2个月龄）
    _forwardTestAges = _getForwardTestAges(_mainTestAge);
    // 获取向后测试月龄（主测月龄后2个月龄）
    _backwardTestAges = _getBackwardTestAges(_mainTestAge);
    
    _currentForwardIndex = 0;
    _currentBackwardIndex = 0;
  }

  // 重置连续计数
  void _resetConsecutiveCounts() {
    _consecutivePassCount.clear();
    _consecutiveFailCount.clear();
    for (String area in ['motor', 'fineMotor', 'language', 'adaptive', 'social']) {
      _consecutivePassCount[area] = 0;
      _consecutiveFailCount[area] = 0;
    }
  }

  // 获取向前测试月龄
  List<int> _getForwardTestAges(int mainAge) {
    List<int> forwardAges = [];
    int currentAge = mainAge;
    
    // 从主测月龄向前测查2个月龄
    for (int i = 0; i < 2; i++) {
      int prevAge = _getPreviousAge(currentAge);
      if (prevAge >= 1) {
        forwardAges.add(prevAge);
        currentAge = prevAge;
      } else {
        break;
      }
    }
    
    return forwardAges;
  }

  // 获取向后测试月龄
  List<int> _getBackwardTestAges(int mainAge) {
    List<int> backwardAges = [];
    int currentAge = mainAge;
    
    // 从主测月龄向后测查2个月龄
    for (int i = 0; i < 2; i++) {
      int nextAge = _getNextAge(currentAge);
      if (nextAge <= 84) {
        backwardAges.add(nextAge);
        currentAge = nextAge;
      } else {
        break;
      }
    }
    
    return backwardAges;
  }

  // 获取上一个标准月龄
  int _getPreviousAge(int currentAge) {
    List<int> ageGroups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84];
    int currentIndex = ageGroups.indexOf(currentAge);
    if (currentIndex == -1 || currentIndex <= 0) {
      return currentAge - 1;
    }
    return ageGroups[currentIndex - 1];
  }

  // 获取下一个标准月龄
  int _getNextAge(int currentAge) {
    List<int> ageGroups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84];
    int currentIndex = ageGroups.indexOf(currentAge);
    if (currentIndex == -1 || currentIndex >= ageGroups.length - 1) {
      return currentAge + 1;
    }
    return ageGroups[currentIndex + 1];
  }

  // 开始测试
  Future<void> startTest(String userName, double actualAge) async {
    _setLoading(true);
    try {
      _userName = userName;
      _actualAge = actualAge;
      _mainTestAge = _assessmentService.determineMainTestAge(actualAge);
      _testResults.clear();
      _currentItemIndex = 0;
      _finalResult = null;
      _error = '';
      
      // 初始化动态测评
      _currentStage = TestStage.current;
      _loadCurrentStageItems();
      
    } catch (e) {
      _error = '开始测试失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 加载当前阶段的测试项目
  void _loadCurrentStageItems() {
    switch (_currentStage) {
      case TestStage.current:
        _currentStageItems = _assessmentService.getCurrentAgeItems(_allData, _mainTestAge);
        break;
      case TestStage.forward:
        // 获取当前向前测试的月龄
        if (_currentForwardIndex < _forwardTestAges.length) {
          _currentTestAge = _forwardTestAges[_currentForwardIndex];
          _currentStageItems = _assessmentService.getCurrentAgeItems(_allData, _currentTestAge);
        } else {
          _currentStageItems = [];
        }
        break;
      case TestStage.backward:
        // 获取当前向后测试的月龄
        if (_currentBackwardIndex < _backwardTestAges.length) {
          _currentTestAge = _backwardTestAges[_currentBackwardIndex];
          _currentStageItems = _assessmentService.getCurrentAgeItems(_allData, _currentTestAge);
        } else {
          _currentStageItems = [];
        }
        break;
      case TestStage.completed:
        _currentStageItems = [];
        break;
    }
    
    _currentStageItemIndex = 0;
    _updateAreaItemCounts();
  }

  // 更新各能区项目数量
  void _updateAreaItemCounts() {
    _areaItemCounts = _assessmentService.getAreaItemCounts(_currentStageItems);
  }

  // 获取各能区项目数量（使用实际数据）
  Map<String, int> getAreaItemCountsWithData() {
    Map<String, int> counts = {
      'motor': 0,
      'fineMotor': 0,
      'language': 0,
      'adaptive': 0,
      'social': 0,
    };
    
    for (var item in _currentStageItems) {
      String area = _assessmentService.getAreaFromData(_allData, item.id);
      counts[area] = (counts[area] ?? 0) + 1;
    }
    
    return counts;
  }

  // 记录测试结果
  void recordResult(int itemId, bool passed) {
    _testResults[itemId] = passed;
    
    // 更新动态测试结果
    _updateDynamicTestResults(itemId, passed);
    
    notifyListeners();
  }

  // 更新动态测试结果
  void _updateDynamicTestResults(int itemId, bool passed) {
    String area = getItemArea(itemId);
    int monthAge = getItemMonthAge(itemId);
    
    if (!_dynamicTestResults.containsKey(monthAge)) {
      _dynamicTestResults[monthAge] = {};
    }
    
    if (!_dynamicTestResults[monthAge]!.containsKey(area)) {
      _dynamicTestResults[monthAge]![area] = [];
    }
    
    // 添加测试结果
    _dynamicTestResults[monthAge]![area]!.add(passed);
    
    // 更新连续计数
    _updateConsecutiveCounts(area, passed);
  }

  // 更新连续计数
  void _updateConsecutiveCounts(String area, bool passed) {
    if (passed) {
      _consecutivePassCount[area] = (_consecutivePassCount[area] ?? 0) + 1;
      _consecutiveFailCount[area] = 0;
    } else {
      _consecutiveFailCount[area] = (_consecutiveFailCount[area] ?? 0) + 1;
      _consecutivePassCount[area] = 0;
    }
  }

  // 下一题
  void nextItem() {
    if (_currentStageItemIndex < _currentStageItems.length - 1) {
      _currentStageItemIndex++;
      notifyListeners();
    } else {
      // 当前阶段完成，检查是否需要进入下一阶段
      _checkAndMoveToNextStage();
    }
  }

  // 上一题
  void previousItem() {
    if (_currentStageItemIndex > 0) {
      _currentStageItemIndex--;
      notifyListeners();
    }
  }

  // 检查并移动到下一阶段
  void _checkAndMoveToNextStage() {
    switch (_currentStage) {
      case TestStage.current:
        // 当前月龄测试完成，检查是否需要向前测试
        if (_forwardTestAges.isNotEmpty) {
          _currentStage = TestStage.forward;
          _currentForwardIndex = 0;
          _loadCurrentStageItems();
        } else if (_backwardTestAges.isNotEmpty) {
          _currentStage = TestStage.backward;
          _currentBackwardIndex = 0;
          _loadCurrentStageItems();
        } else {
          _currentStage = TestStage.completed;
          _generateFinalResult();
        }
        break;
      case TestStage.forward:
        // 当前向前月龄测试完成，检查是否需要继续向前测试
        _currentForwardIndex++;
        
        // 检查当前能区是否已经连续通过2个月龄
        if (_shouldContinueForwardTest()) {
          // 需要继续向前测试，获取下一个向前月龄
          int nextAge = _getNextForwardAge();
          if (nextAge > 0) {
            _currentTestAge = nextAge;
            _loadCurrentStageItems();
          } else {
            // 无法继续向前，检查是否需要向后测试
            _moveToBackwardStage();
          }
        } else {
          // 当前能区向前测试完成，检查是否需要向后测试
          _moveToBackwardStage();
        }
        break;
      case TestStage.backward:
        // 当前向后月龄测试完成，检查是否需要继续向后测试
        _currentBackwardIndex++;
        
        // 检查当前能区是否已经连续不通过2个月龄
        if (_shouldContinueBackwardTest()) {
          // 需要继续向后测试，获取下一个向后月龄
          int nextAge = _getNextBackwardAge();
          if (nextAge > 0) {
            _currentTestAge = nextAge;
            _loadCurrentStageItems();
          } else {
            // 无法继续向后，测试结束
            _currentStage = TestStage.completed;
            _generateFinalResult();
          }
        } else {
          // 当前能区向后测试完成，测试结束
          _currentStage = TestStage.completed;
          _generateFinalResult();
        }
        break;
      case TestStage.completed:
        // 测试已完成，生成结果
        _generateFinalResult();
        break;
    }
    
    notifyListeners();
  }

  // 检查是否应该继续向前测试
  bool _shouldContinueForwardTest() {
    // 检查每个能区是否已经连续通过2个月龄
    final areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];
    
    for (String area in areas) {
      if (!_hasConsecutivePassForArea(area, 2)) {
        return true; // 如果有任何能区未连续通过2个月龄，继续向前测试
      }
    }
    
    return false; // 所有能区都已连续通过2个月龄，停止向前测试
  }

  // 检查指定能区是否连续通过指定月龄数
  bool _hasConsecutivePassForArea(String area, int consecutiveCount) {
    List<int> forwardAges = _getForwardTestAges(_mainTestAge);
    int consecutivePassCount = 0;
    
    for (int age in forwardAges) {
      bool allPassed = true;
      
      // 检查该月龄下该能区的所有项目是否都通过
      for (var data in _allData) {
        if (data.ageMonth == age && data.area == area) {
          for (var item in data.testItems) {
            if (_testResults.containsKey(item.id) && !_testResults[item.id]!) {
              allPassed = false;
              break;
            }
          }
        }
      }
      
      if (allPassed) {
        consecutivePassCount++;
        if (consecutivePassCount >= consecutiveCount) {
          return true;
        }
      } else {
        consecutivePassCount = 0; // 重置连续计数
      }
    }
    
    return false;
  }

  // 获取下一个向前测试月龄
  int _getNextForwardAge() {
    List<int> ageGroups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84];
    
    // 找到当前测试月龄在列表中的位置
    int currentIndex = ageGroups.indexOf(_currentTestAge);
    if (currentIndex <= 0) {
      return 0; // 无法继续向前
    }
    
    return ageGroups[currentIndex - 1];
  }

  // 移动到向后测试阶段
  void _moveToBackwardStage() {
    if (_backwardTestAges.isNotEmpty) {
      _currentStage = TestStage.backward;
      _currentBackwardIndex = 0;
      _loadCurrentStageItems();
    } else {
      _currentStage = TestStage.completed;
      _generateFinalResult();
    }
  }

  // 检查是否应该继续向后测试
  bool _shouldContinueBackwardTest() {
    // 检查每个能区是否已经连续不通过2个月龄
    final areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];
    
    for (String area in areas) {
      if (!_hasConsecutiveFailForArea(area, 2)) {
        return true; // 如果有任何能区未连续不通过2个月龄，继续向后测试
      }
    }
    
    return false; // 所有能区都已连续不通过2个月龄，停止向后测试
  }

  // 检查指定能区是否连续不通过指定月龄数
  bool _hasConsecutiveFailForArea(String area, int consecutiveCount) {
    List<int> backwardAges = _getBackwardTestAges(_mainTestAge);
    int consecutiveFailCount = 0;
    
    for (int age in backwardAges) {
      bool allFailed = true;
      
      // 检查该月龄下该能区的所有项目是否都不通过
      for (var data in _allData) {
        if (data.ageMonth == age && data.area == area) {
          for (var item in data.testItems) {
            if (_testResults.containsKey(item.id) && _testResults[item.id]!) {
              allFailed = false;
              break;
            }
          }
        }
      }
      
      if (allFailed) {
        consecutiveFailCount++;
        if (consecutiveFailCount >= consecutiveCount) {
          return true;
        }
      } else {
        consecutiveFailCount = 0; // 重置连续计数
      }
    }
    
    return false;
  }

  // 获取下一个向后测试月龄
  int _getNextBackwardAge() {
    List<int> ageGroups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84];
    
    // 找到当前测试月龄在列表中的位置
    int currentIndex = ageGroups.indexOf(_currentTestAge);
    if (currentIndex >= ageGroups.length - 1) {
      return 0; // 无法继续向后
    }
    
    return ageGroups[currentIndex + 1];
  }

  // 获取总进度
  double _getTotalProgress() {
    if (_currentStage == TestStage.completed) return 1.0;
    
    int totalCompleted = 0;
    int totalItems = 0;
    
    // 计算已完成的题目数
    totalCompleted = _testResults.length;
    
    // 计算总题目数
    var stageInfo = _assessmentService.getTestStageInfo(_allData, _mainTestAge, _testResults);
    totalItems = stageInfo.totalItems;
    
    if (totalItems == 0) return 0.0;
    return totalCompleted / totalItems;
  }

  // 获取当前阶段进度
  double getCurrentStageProgress() {
    if (_currentStageItems.isEmpty) return 0.0;
    return (_currentStageItemIndex + 1) / _currentStageItems.length;
  }

  // 获取当前阶段名称
  String getCurrentStageName() {
    switch (_currentStage) {
      case TestStage.current:
        return '当前月龄测试';
      case TestStage.forward:
        return '向前测查';
      case TestStage.backward:
        return '向后测查';
      case TestStage.completed:
        return '测试完成';
    }
  }

  // 获取当前阶段描述
  String getCurrentStageDescription() {
    switch (_currentStage) {
      case TestStage.current:
        return '正在测试${_mainTestAge}月龄的项目';
      case TestStage.forward:
        return '正在测试${_mainTestAge}月龄之前的项目';
      case TestStage.backward:
        return '正在测试${_mainTestAge}月龄之后的项目';
      case TestStage.completed:
        return '所有测试项目已完成';
    }
  }

  // 完成测试
  Future<void> completeTest() async {
    _setLoading(true);
    try {
      // 使用动态测评服务计算结果
      _dynamicAssessmentService.executeDynamicAssessment(
        _allData,
        _mainTestAge,
        _dynamicTestResults,
      );
      
      // 计算各能区结果
      final areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];
      final areaResults = <AreaResult>[];
      
      for (String area in areas) {
        final mentalAge = _assessmentService.calculateMentalAge(area, _currentTestItems, _testResults, _itemAreaMap);
        final developmentQuotient = _assessmentService.calculateDevelopmentQuotient(mentalAge, _actualAge);
        
        areaResults.add(AreaResult(
          area: _assessmentService.getAreaName(area),
          mentalAge: mentalAge,
          developmentQuotient: developmentQuotient,
        ));
      }

      // 计算总体结果
      final totalMentalAge = _assessmentService.calculateTotalMentalAge(
        Map.fromEntries(areaResults.map((r) => MapEntry(r.area, r.mentalAge)))
      );
      final totalDevelopmentQuotient = _assessmentService.calculateDevelopmentQuotient(totalMentalAge, _actualAge);

      _finalResult = TestResult(
        userName: _userName,
        date: DateTime.now().toIso8601String(),
        birthDate: DateTime.now().subtract(Duration(days: (_actualAge * 30).round())).toIso8601String(),
        month: _actualAge,
        testResults: areaResults,
        allResult: AreaResult(
          area: '总体',
          mentalAge: totalMentalAge,
          developmentQuotient: totalDevelopmentQuotient,
        ),
      );

      // 保存结果
      await _dataService.saveTestResult(_finalResult!.toJson());
      _error = '';
    } catch (e) {
      _error = '完成测试失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 重置测试
  void resetTest() {
    _currentTestItems.clear();
    _testResults.clear();
    _currentItemIndex = 0;
    _finalResult = null;
    _error = '';
    _currentStage = TestStage.current;
    _currentStageItems.clear();
    _currentStageItemIndex = 0;
    _areaItemCounts.clear();
    _dynamicTestResults.clear();
    _resetConsecutiveCounts();
    notifyListeners();
  }

  // 生成最终结果
  void _generateFinalResult() async {
    _setLoading(true);
    try {
      // 计算各能区结果
      final areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];
      final areaResults = <AreaResult>[];
      
      for (String area in areas) {
        // 计算该能区的智龄和发育商
        double mentalAge = 0.0;
        double developmentQuotient = 0.0;
        
        // 根据测试结果计算智龄
        for (var entry in _testResults.entries) {
          int itemId = entry.key;
          bool passed = entry.value;
          
          // 获取项目的能区
          String itemArea = _itemAreaMap[itemId] ?? 'unknown';
          if (itemArea == area && passed) {
            // 获取项目的月龄
            int itemAge = _getItemAgeFromData(itemId);
            mentalAge += _assessmentService.getAreaScoreForAge(area, itemAge);
          }
        }
        
        developmentQuotient = _assessmentService.calculateDevelopmentQuotient(mentalAge, _actualAge);
        
        areaResults.add(AreaResult(
          area: _assessmentService.getAreaName(area),
          mentalAge: mentalAge,
          developmentQuotient: developmentQuotient,
        ));
      }

      // 计算总体结果
      double totalMentalAge = 0.0;
      for (var result in areaResults) {
        totalMentalAge += result.mentalAge;
      }
      totalMentalAge = totalMentalAge / areaResults.length;
      
      final totalDevelopmentQuotient = _assessmentService.calculateDevelopmentQuotient(totalMentalAge, _actualAge);

      _finalResult = TestResult(
        userName: _userName,
        date: DateTime.now().toIso8601String(),
        birthDate: DateTime.now().subtract(Duration(days: (_actualAge * 30).round())).toIso8601String(),
        month: _actualAge,
        testResults: areaResults,
        allResult: AreaResult(
          area: '总体',
          mentalAge: totalMentalAge,
          developmentQuotient: totalDevelopmentQuotient,
        ),
      );

      // 保存结果
      await _dataService.saveTestResult(_finalResult!.toJson());
      _error = '';
    } catch (e) {
      _error = '生成结果失败: $e';
      print('生成结果失败: $e'); // 添加调试信息
    } finally {
      _setLoading(false);
    }
  }

  // 从数据中获取项目的月龄
  int _getItemAgeFromData(int itemId) {
    for (var data in _allData) {
      for (var item in data.testItems) {
        if (item.id == itemId) {
          return data.ageMonth;
        }
      }
    }
    return 1; // 默认值
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = '';
    notifyListeners();
  }
} 