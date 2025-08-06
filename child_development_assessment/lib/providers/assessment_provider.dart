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
    _loadCurrentStageItems();
    notifyListeners();
  }

  // 记录当前月龄的测试结果
  void recordCurrentAgeResults(Map<String, List<bool>> areaResults) {
    _dynamicTestResults[_mainTestAge] = areaResults;
    _checkAndMoveToNextStage();
  }

  // 记录向前测试结果
  void recordForwardAgeResults(int age, Map<String, List<bool>> areaResults) {
    _dynamicTestResults[age] = areaResults;
    _checkAndMoveToNextStage();
  }

  // 记录向后测试结果
  void recordBackwardAgeResults(int age, Map<String, List<bool>> areaResults) {
    _dynamicTestResults[age] = areaResults;
    _checkAndMoveToNextStage();
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
        // 获取向前测试的月龄
        var forwardAges = _dynamicAssessmentService.getForwardTestAges(_mainTestAge, _dynamicTestResults);
        if (forwardAges.isNotEmpty) {
          int nextAge = forwardAges.first;
          _currentStageItems = _assessmentService.getCurrentAgeItems(_allData, nextAge);
        } else {
          _currentStageItems = [];
        }
        break;
      case TestStage.backward:
        // 获取向后测试的月龄
        var backwardAges = _dynamicAssessmentService.getBackwardTestAges(_mainTestAge, _dynamicTestResults);
        if (backwardAges.isNotEmpty) {
          int nextAge = backwardAges.first;
          _currentStageItems = _assessmentService.getCurrentAgeItems(_allData, nextAge);
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
    notifyListeners();
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
        // 当前月龄测试完成，使用动态测评服务决定下一步
        var forwardAges = _dynamicAssessmentService.getForwardTestAges(_mainTestAge, _dynamicTestResults);
        var backwardAges = _dynamicAssessmentService.getBackwardTestAges(_mainTestAge, _dynamicTestResults);
        
        if (forwardAges.isNotEmpty) {
          _currentStage = TestStage.forward;
          _loadCurrentStageItems();
        } else if (backwardAges.isNotEmpty) {
          _currentStage = TestStage.backward;
          _loadCurrentStageItems();
        } else {
          _currentStage = TestStage.completed;
          _loadCurrentStageItems();
        }
        break;
      case TestStage.forward:
        // 向前测查完成，检查是否需要向后测查
        var backwardAges = _dynamicAssessmentService.getBackwardTestAges(_mainTestAge, _dynamicTestResults);
        if (backwardAges.isNotEmpty) {
          _currentStage = TestStage.backward;
          _loadCurrentStageItems();
        } else {
          _currentStage = TestStage.completed;
          _loadCurrentStageItems();
        }
        break;
      case TestStage.backward:
        // 向后测查完成，测试结束
        _currentStage = TestStage.completed;
        _loadCurrentStageItems();
        break;
      case TestStage.completed:
        // 测试已完成
        break;
    }
    notifyListeners();
  }

  // 检查是否需要进入向前测查阶段
  bool _shouldMoveToForwardStage() {
    // 检查是否有向前测查的项目
    var forwardItems = _assessmentService.getForwardItems(_allData, _mainTestAge, _testResults);
    return forwardItems.isNotEmpty;
  }

  // 检查是否需要进入向后测查阶段
  bool _shouldMoveToBackwardStage() {
    // 检查是否有向后测查的项目
    var backwardItems = _assessmentService.getBackwardItems(_allData, _mainTestAge, _testResults);
    return backwardItems.isNotEmpty;
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
      var dynamicResult = _dynamicAssessmentService.executeDynamicAssessment(
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
    notifyListeners();
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