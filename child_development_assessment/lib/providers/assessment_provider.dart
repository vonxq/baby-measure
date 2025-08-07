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

enum TestArea {
  motor,      // 大运动
  fineMotor,  // 精细动作
  language,   // 语言
  adaptive,   // 适应能力
  social      // 社会行为
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
  
  // 动态测评相关 - 按能区测试
  TestStage _currentStage = TestStage.current;
  TestArea _currentArea = TestArea.motor; // 当前测试的能区
  List<AssessmentItem> _currentStageItems = [];
  int _currentStageItemIndex = 0;
  

  
  // 能区测试状态跟踪
  Map<TestArea, bool> _areaCompleted = {}; // 能区是否完成测试
  Map<TestArea, int> _areaCurrentAge = {}; // 每个能区当前测试的月龄
  Map<TestArea, List<int>> _areaTestedAges = {}; // 每个能区已测试的月龄

  // Getters
  List<AssessmentData> get allData => _allData;
  List<AssessmentItem> get currentTestItems => _currentTestItems;
  Map<int, bool> get testResults => _testResults;
  int get currentItemIndex => _currentItemIndex;
  bool get isLoading => _isLoading;
  String get error => _error;
  TestResult? get finalResult => _finalResult;
  String get userName => _userName;
  double get actualAge => _actualAge;
  int get mainTestAge => _mainTestAge;
  
  // 动态测评相关 getters
  TestStage get currentStage => _currentStage;
  TestArea get currentArea => _currentArea;
  List<AssessmentItem> get currentStageItems => _currentStageItems;
  int get currentStageItemIndex => _currentStageItemIndex;
  AssessmentItem? get currentItem => _currentStageItems.isNotEmpty && _currentStageItemIndex < _currentStageItems.length 
      ? _currentStageItems[_currentStageItemIndex] 
      : null;
  
  // 能区测试状态 getters
  Map<TestArea, bool> get areaCompleted => _areaCompleted;
  Map<TestArea, int> get areaCurrentAge => _areaCurrentAge;
  Map<TestArea, List<int>> get areaTestedAges => _areaTestedAges;

  // 初始化
  AssessmentProvider() {
    _initializeAreaMaps();
  }

  void _initializeAreaMaps() {
    for (TestArea area in TestArea.values) {
      _areaCompleted[area] = false;
      _areaCurrentAge[area] = 0;
      _areaTestedAges[area] = [];
    }
  }

  // 加载数据
  Future<void> loadData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allData = await _dataService.loadAssessmentData();
      _buildItemAreaMap();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载数据失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 构建项目到能区的映射
  void _buildItemAreaMap() {
    for (var data in _allData) {
      for (var item in data.testItems) {
        _itemAreaMap[item.id] = data.area;
      }
    }
  }

  // 获取项目所属能区
  String getItemArea(int itemId) {
    return _itemAreaMap[itemId] ?? '';
  }

  // 获取项目所属月龄
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

  // 开始动态测评
  void startDynamicAssessment(String userName, double actualAge) {
    _userName = userName;
    _actualAge = actualAge;
    _mainTestAge = _assessmentService.determineMainTestAge(actualAge);
    _currentStage = TestStage.current;
    _currentArea = TestArea.motor; // 从大运动开始
    _currentStageItemIndex = 0;
    _testResults.clear();
    
    // 初始化能区测试状态
    _initializeAreaMaps();
    for (TestArea area in TestArea.values) {
      _areaCurrentAge[area] = _mainTestAge;
      _areaTestedAges[area] = [_mainTestAge];
    }
    
    _loadCurrentAreaItems();
    notifyListeners();
  }

  // 加载当前能区的测试项目
  void _loadCurrentAreaItems() {
    _currentStageItems.clear();
    _currentStageItemIndex = 0;
    
    // 根据当前测试阶段和能区加载项目
    int testAge = _areaCurrentAge[_currentArea] ?? _mainTestAge;
    String currentAreaString = _getAreaString(_currentArea);
    
    print('加载当前能区项目: $_currentArea ($currentAreaString), 月龄: $testAge');
    print('数据总数: ${_allData.length}');
    
    for (var data in _allData) {
      print('检查数据: 月龄=${data.ageMonth}, 能区=${data.area}');
      if (data.ageMonth == testAge && data.area == currentAreaString) {
        print('找到匹配数据，添加 ${data.testItems.length} 个项目');
        _currentStageItems.addAll(data.testItems);
      }
    }
    
    print('最终加载项目数: ${_currentStageItems.length}');
    notifyListeners();
  }

  // 获取能区字符串
  String _getAreaString(TestArea area) {
    switch (area) {
      case TestArea.motor:
        return 'motor';
      case TestArea.fineMotor:
        return 'fineMotor';
      case TestArea.language:
        return 'language';
      case TestArea.adaptive:
        return 'adaptive';
      case TestArea.social:
        return 'social';
    }
  }

  // 记录测试结果
  void recordResult(int itemId, bool passed) {
    _testResults[itemId] = passed;
    notifyListeners();
  }

  // 下一题
  void nextItem() {
    if (_currentStageItemIndex < _currentStageItems.length - 1) {
      _currentStageItemIndex++;
      notifyListeners();
    } else {
      // 当前能区当前月龄测试完成，检查是否需要进入下一阶段
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
        // 主测月龄测试完成，检查是否所有能区都已完成主测月龄测试
        if (_isAllAreasCompletedForMainAge()) {
          // 所有能区主测月龄测试完成，开始向前测试
          _currentStage = TestStage.forward;
          _startForwardTest();
        } else {
          // 移动到下一个能区继续主测月龄测试
          _moveToNextAreaForMainAge();
        }
        break;
      case TestStage.forward:
        // 向前测试完成，检查是否需要继续向前或开始向后
        if (_shouldContinueForwardTest()) {
          // 继续向前测试
          _continueForwardTest();
        } else {
          // 向前测试完成，开始向后测试
          _currentStage = TestStage.backward;
          _startBackwardTest();
        }
        break;
      case TestStage.backward:
        // 向后测试完成，检查是否需要继续向后或完成该能区
        if (_shouldContinueBackwardTest()) {
          // 继续向后测试
          _continueBackwardTest();
        } else {
          // 向后测试完成，该能区测试完成
          _completeCurrentArea();
        }
        break;
      case TestStage.completed:
        // 所有能区测试完成
        _generateFinalResult();
        break;
    }
    
    notifyListeners();
  }

  // 检查是否所有能区都已完成主测月龄测试
  bool _isAllAreasCompletedForMainAge() {
    for (TestArea area in TestArea.values) {
      if (!_hasCompletedMainAgeForArea(area)) {
        return false;
      }
    }
    return true;
  }

  // 检查指定能区是否已完成主测月龄测试
  bool _hasCompletedMainAgeForArea(TestArea area) {
    String areaString = _getAreaString(area);
    bool hasTestedItems = false;
    
    for (var data in _allData) {
      if (data.ageMonth == _mainTestAge && data.area == areaString) {
        for (var item in data.testItems) {
          if (_testResults.containsKey(item.id)) {
            hasTestedItems = true;
          }
        }
      }
    }
    
    return hasTestedItems;
  }

  // 移动到下一个能区继续主测月龄测试
  void _moveToNextAreaForMainAge() {
    // 按顺序移动到下一个能区
    switch (_currentArea) {
      case TestArea.motor:
        _currentArea = TestArea.fineMotor;
        break;
      case TestArea.fineMotor:
        _currentArea = TestArea.language;
        break;
      case TestArea.language:
        _currentArea = TestArea.adaptive;
        break;
      case TestArea.adaptive:
        _currentArea = TestArea.social;
        break;
      case TestArea.social:
        // 所有能区主测月龄测试完成，开始向前测试
        _currentStage = TestStage.forward;
        _currentArea = TestArea.motor; // 重新从大运动开始
        _startForwardTest();
        return;
    }
    
    // 重置该能区的测试状态，确保从主测月龄开始
    _areaCurrentAge[_currentArea] = _mainTestAge;
    _areaTestedAges[_currentArea] = [_mainTestAge];
    
    _loadCurrentAreaItems();
  }

  // 开始向前测试
  void _startForwardTest() {
    // 获取向前测试月龄（从主测月龄向前2个月龄）
    int forwardAge = _getPreviousAge(_mainTestAge);
    if (forwardAge >= 1) {
      _areaCurrentAge[_currentArea] = forwardAge;
      _areaTestedAges[_currentArea]!.add(forwardAge);
      _loadCurrentAreaItems();
    } else {
      // 无法向前，直接开始向后测试
      _currentStage = TestStage.backward;
      _startBackwardTest();
    }
  }

  // 继续向前测试
  void _continueForwardTest() {
    int currentAge = _areaCurrentAge[_currentArea] ?? _mainTestAge;
    int nextAge = _getPreviousAge(currentAge);
    if (nextAge >= 1) {
      _areaCurrentAge[_currentArea] = nextAge;
      _areaTestedAges[_currentArea]!.add(nextAge);
      _loadCurrentAreaItems();
    } else {
      // 无法继续向前，开始向后测试
      _currentStage = TestStage.backward;
      _startBackwardTest();
    }
  }

  // 开始向后测试
  void _startBackwardTest() {
    // 获取向后测试月龄（从主测月龄向后2个月龄）
    int backwardAge = _getNextAge(_mainTestAge);
    if (backwardAge <= 84) {
      _areaCurrentAge[_currentArea] = backwardAge;
      _areaTestedAges[_currentArea]!.add(backwardAge);
      _loadCurrentAreaItems();
    } else {
      // 无法向后，完成该能区
      _completeCurrentArea();
    }
  }

  // 继续向后测试
  void _continueBackwardTest() {
    int currentAge = _areaCurrentAge[_currentArea] ?? _mainTestAge;
    int nextAge = _getNextAge(currentAge);
    if (nextAge <= 84) {
      _areaCurrentAge[_currentArea] = nextAge;
      _areaTestedAges[_currentArea]!.add(nextAge);
      _loadCurrentAreaItems();
    } else {
      // 无法继续向后，完成该能区
      _completeCurrentArea();
    }
  }

  // 完成当前能区测试
  void _completeCurrentArea() {
    _areaCompleted[_currentArea] = true;
    
    // 检查是否所有能区都已完成
    bool allAreasCompleted = true;
    for (TestArea area in TestArea.values) {
      if (!(_areaCompleted[area] ?? false)) {
        allAreasCompleted = false;
        break;
      }
    }
    
    if (allAreasCompleted) {
      // 所有能区测试完成
      _currentStage = TestStage.completed;
      _generateFinalResult();
    } else {
      // 移动到下一个能区
      _moveToNextArea();
    }
  }

  // 移动到下一个能区
  void _moveToNextArea() {
    // 按顺序移动到下一个能区
    switch (_currentArea) {
      case TestArea.motor:
        _currentArea = TestArea.fineMotor;
        break;
      case TestArea.fineMotor:
        _currentArea = TestArea.language;
        break;
      case TestArea.language:
        _currentArea = TestArea.adaptive;
        break;
      case TestArea.adaptive:
        _currentArea = TestArea.social;
        break;
      case TestArea.social:
        // 所有能区测试完成
        _currentStage = TestStage.completed;
        _generateFinalResult();
        return;
    }
    
    // 重置该能区的测试状态
    _currentStage = TestStage.current;
    _areaCurrentAge[_currentArea] = _mainTestAge;
    _areaTestedAges[_currentArea] = [_mainTestAge];
    
    _loadCurrentAreaItems();
  }

  // 检查是否应该继续向前测试
  bool _shouldContinueForwardTest() {
    TestArea area = _currentArea;
    
    // 检查该能区是否已经连续通过2个月龄
    return !_hasConsecutivePassForArea(area, 2);
  }

  // 检查是否应该继续向后测试
  bool _shouldContinueBackwardTest() {
    TestArea area = _currentArea;
    
    // 检查该能区是否已经连续不通过2个月龄
    return !_hasConsecutiveFailForArea(area, 2);
  }

  // 检查指定能区是否连续通过指定月龄数
  bool _hasConsecutivePassForArea(TestArea area, int consecutiveCount) {
    List<int> testedAges = _areaTestedAges[area] ?? [];
    if (testedAges.length < consecutiveCount) {
      return false; // 测试的月龄数不足
    }
    
    // 按时间顺序排序月龄（从大到小，因为向前测试是从大月龄到小月龄）
    testedAges.sort((a, b) => b.compareTo(a));
    
    // 检查是否有连续的consecutiveCount个月龄都通过
    for (int i = 0; i <= testedAges.length - consecutiveCount; i++) {
      bool consecutivePassed = true;
      
      // 检查连续的consecutiveCount个月龄
      for (int j = 0; j < consecutiveCount; j++) {
        int age = testedAges[i + j];
        if (!_hasAllItemsPassedForAgeAndArea(age, area)) {
          consecutivePassed = false;
          break;
        }
      }
      
      if (consecutivePassed) {
        return true;
      }
    }
    
    return false;
  }

  // 检查指定能区是否连续不通过指定月龄数
  bool _hasConsecutiveFailForArea(TestArea area, int consecutiveCount) {
    List<int> testedAges = _areaTestedAges[area] ?? [];
    if (testedAges.length < consecutiveCount) {
      return false; // 测试的月龄数不足
    }
    
    // 按时间顺序排序月龄（从小到大，因为向后测试是从小月龄到大月龄）
    testedAges.sort((a, b) => a.compareTo(b));
    
    // 检查是否有连续的consecutiveCount个月龄都不通过
    for (int i = 0; i <= testedAges.length - consecutiveCount; i++) {
      bool consecutiveFailed = true;
      
      // 检查连续的consecutiveCount个月龄
      for (int j = 0; j < consecutiveCount; j++) {
        int age = testedAges[i + j];
        if (_hasAnyItemPassedForAgeAndArea(age, area)) {
          consecutiveFailed = false;
          break;
        }
      }
      
      if (consecutiveFailed) {
        return true;
      }
    }
    
    return false;
  }

  // 检查指定月龄和能区的所有项目是否都通过
  bool _hasAllItemsPassedForAgeAndArea(int age, TestArea area) {
    String areaString = _getAreaString(area);
    bool hasTestedItems = false;
    bool allPassed = true;
    
    for (var data in _allData) {
      if (data.ageMonth == age && data.area == areaString) {
        for (var item in data.testItems) {
          if (_testResults.containsKey(item.id)) {
            hasTestedItems = true;
            if (!_testResults[item.id]!) {
              allPassed = false;
              break;
            }
          }
        }
      }
    }
    
    return hasTestedItems && allPassed;
  }

  // 检查指定月龄和能区是否有任何项目通过
  bool _hasAnyItemPassedForAgeAndArea(int age, TestArea area) {
    String areaString = _getAreaString(area);
    
    for (var data in _allData) {
      if (data.ageMonth == age && data.area == areaString) {
        for (var item in data.testItems) {
          if (_testResults.containsKey(item.id) && _testResults[item.id]!) {
            return true;
          }
        }
      }
    }
    
    return false;
  }

  // 获取前一个月龄
  int _getPreviousAge(int currentAge) {
    List<int> ageGroups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84];
    int currentIndex = ageGroups.indexOf(currentAge);
    if (currentIndex <= 0) {
      return 0; // 无法继续向前
    }
    return ageGroups[currentIndex - 1];
  }

  // 获取后一个月龄
  int _getNextAge(int currentAge) {
    List<int> ageGroups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84];
    int currentIndex = ageGroups.indexOf(currentAge);
    if (currentIndex >= ageGroups.length - 1) {
      return 0; // 无法继续向后
    }
    return ageGroups[currentIndex + 1];
  }

  // 生成最终结果
  void _generateFinalResult() {
    // 计算各能区的智龄和总分
    Map<String, double> areaScores = {};
    double totalScore = 0.0;
    
    for (TestArea area in TestArea.values) {
      double areaScore = _calculateAreaScore(area);
      areaScores[area.toString()] = areaScore;
      totalScore += areaScore;
    }
    
    // 将五个能区所得分数相加，再除以5就是总的智龄
    double mentalAge = totalScore / 5.0; // 5个能区
    double dq = (mentalAge / _actualAge) * 100;
    
    _finalResult = TestResult(
      userName: _userName,
      actualAge: _actualAge,
      mainTestAge: _mainTestAge,
      areaScores: areaScores,
      totalScore: totalScore,
      averageScore: mentalAge, // 平均分就是智龄
      dq: dq,
      testResults: Map.from(_testResults),
    );
    
    notifyListeners();
  }

  // 计算指定能区的得分
  double _calculateAreaScore(TestArea area) {
    List<int> testedAges = _areaTestedAges[area] ?? [];
    if (testedAges.isEmpty) return 0.0;
    
    // 按时间顺序排序月龄（从大到小）
    testedAges.sort((a, b) => b.compareTo(a));
    
    double score = 0.0;
    String areaString = _getAreaString(area);
    
    // 找到连续通过的最高月龄
    int highestConsecutivePassAge = 0;
    int consecutivePassCount = 0;
    
    for (int age in testedAges) {
      if (_hasAllItemsPassedForAgeAndArea(age, area)) {
        consecutivePassCount++;
        if (consecutivePassCount >= 2) {
          // 连续2个月龄都通过，找到最高月龄
          highestConsecutivePassAge = age;
          break;
        }
      } else {
        consecutivePassCount = 0;
      }
    }
    
    // 如果找到了连续通过的最高月龄，计算该能区的智龄
    if (highestConsecutivePassAge > 0) {
      // 计算从1月龄到最高通过月龄的所有月龄的分数
      List<int> allAgeGroups = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84];
      
      for (int age in allAgeGroups) {
        if (age <= highestConsecutivePassAge) {
          // 计算该月龄该能区的总分
          double ageAreaScore = 0.0;
          if (age >= 1 && age <= 12) {
            ageAreaScore = 1.0; // 1月龄～12月龄每个能区1.0分
          } else if (age >= 15 && age <= 36) {
            ageAreaScore = 3.0; // 15月龄～36月龄每个能区3.0分
          } else if (age >= 42 && age <= 84) {
            ageAreaScore = 6.0; // 42月龄～84月龄每个能区6.0分
          }
          
          // 计算该月龄该能区通过的项目数量
          int passedItems = 0;
          int totalItems = 0;
          for (var data in _allData) {
            if (data.ageMonth == age && data.area == areaString) {
              totalItems += data.testItems.length;
              for (var item in data.testItems) {
                if (_testResults.containsKey(item.id) && _testResults[item.id]!) {
                  passedItems++;
                }
              }
            }
          }
          
          // 如果该月龄该能区有测试项目，计算得分
          if (totalItems > 0) {
            // 每个通过的项目得分 = 该月龄该能区总分 / 该月龄该能区项目总数
            double itemScore = ageAreaScore / totalItems;
            score += itemScore * passedItems;
          }
        }
      }
    }
    
    return score;
  }

  // 获取总进度
  double _getTotalProgress() {
    if (_currentStage == TestStage.completed) return 1.0;
    
    int totalCompleted = 0;
    int totalItems = 0;
    
    for (TestArea area in TestArea.values) {
      List<int> testedAges = _areaTestedAges[area] ?? [];
      for (int age in testedAges) {
        for (var data in _allData) {
          if (data.ageMonth == age && data.area == area.toString()) {
            totalItems += data.testItems.length;
            for (var item in data.testItems) {
              if (_testResults.containsKey(item.id)) {
                totalCompleted++;
              }
            }
          }
        }
      }
    }
    
    return totalItems > 0 ? totalCompleted / totalItems : 0.0;
  }

  // 获取当前进度
  double get progress => _getTotalProgress();

  // 获取当前测试阶段描述
  String get currentStageDescription {
    switch (_currentStage) {
      case TestStage.current:
        return '测试${_getAreaName(_currentArea)}能区 - 主测月龄';
      case TestStage.forward:
        return '测试${_getAreaName(_currentArea)}能区 - 向前测查';
      case TestStage.backward:
        return '测试${_getAreaName(_currentArea)}能区 - 向后测查';
      case TestStage.completed:
        return '测试完成';
    }
  }

  // 获取能区名称
  String _getAreaName(TestArea area) {
    switch (area) {
      case TestArea.motor:
        return '大运动';
      case TestArea.fineMotor:
        return '精细动作';
      case TestArea.language:
        return '语言';
      case TestArea.adaptive:
        return '适应能力';
      case TestArea.social:
        return '社会行为';
    }
  }

  // 重置
  void reset() {
    _currentTestItems.clear();
    _testResults.clear();
    _currentItemIndex = 0;
    _isLoading = false;
    _error = '';
    _finalResult = null;
    _userName = '';
    _actualAge = 0.0;
    _mainTestAge = 0;
    
    // 重置动态测评相关
    _currentStage = TestStage.current;
    _currentArea = TestArea.motor;
    _currentStageItems.clear();
    _currentStageItemIndex = 0;
    
    // 重置能区测试状态
    _initializeAreaMaps();
    
    notifyListeners();
  }
} 