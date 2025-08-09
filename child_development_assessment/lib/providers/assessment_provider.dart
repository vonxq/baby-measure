import 'package:flutter/foundation.dart';
import '../models/assessment_data.dart';
import '../models/assessment_item.dart';
import '../models/test_result.dart';
import '../services/assessment_service.dart';
import '../services/data_service.dart';

enum TestStage {
  current,    // 当前月龄
  forward,    // 向前测查
  backward,   // 向后测查
  areaCompleted, // 能区测试完成
  allCompleted   // 所有能区测试完成
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
  final DataService _dataService = DataService();

  List<AssessmentData> _allData = [];
  final Map<int, bool> _testResults = {};
  final Map<int, String> _itemAreaMap = {}; // id到area的映射
  bool _isLoading = false;
  String _error = '';
  TestResult? _finalResult;
  String _userName = '';
  double _actualAge = 0.0;
  int _mainTestAge = 0;
  DateTime? _testStartTime;
  
  // 当前测试状态
  TestStage _currentStage = TestStage.current;
  TestArea _currentArea = TestArea.motor; // 当前测试的能区
  List<AssessmentItem> _currentStageItems = [];
  int _currentStageItemIndex = 0;
  
  // 能区测试状态跟踪
  Map<TestArea, bool> _areaCompleted = {}; // 能区是否完成测试
  Map<TestArea, int> _areaCurrentAge = {}; // 每个能区当前测试的月龄
  Map<TestArea, List<int>> _areaTestedAges = {}; // 每个能区已测试的月龄
  Map<TestArea, double> _areaScores = {}; // 每个能区的智龄
  
  // 答题堆栈 - 每个能区维护自己的答题历史
  Map<TestArea, List<AssessmentItem>> _areaAnswerStack = {};

  // Getters
  List<AssessmentData> get allData => _allData;
  Map<int, bool> get testResults => _testResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  TestResult? get finalResult => _finalResult;
  String get userName => _userName;
  double get actualAge => _actualAge;
  int get mainTestAge => _mainTestAge;
  DateTime? get testStartTime => _testStartTime;
  
  // 当前测试状态 getters
  TestStage get currentStage => _currentStage;
  TestArea get currentArea => _currentArea;
  List<AssessmentItem> get currentStageItems => _currentStageItems;
  int get currentStageItemIndex => _currentStageItemIndex;
  AssessmentItem? get currentItem {
    bool hasItems = _currentStageItems.isNotEmpty;
    bool validIndex = _currentStageItemIndex < _currentStageItems.length;
    
    if (hasItems && validIndex) {
      return _currentStageItems[_currentStageItemIndex];
    } else {
      return null;
    }
  }
  
  // 能区测试状态 getters
  Map<TestArea, bool> get areaCompleted => _areaCompleted;
  Map<TestArea, int> get areaCurrentAge => _areaCurrentAge;
  Map<TestArea, List<int>> get areaTestedAges => _areaTestedAges;
  Map<TestArea, double> get areaScores => _areaScores;

  // 初始化
  AssessmentProvider() {
    _initializeAreaMaps();
  }

  void _initializeAreaMaps() {
    for (TestArea area in TestArea.values) {
      _areaCompleted[area] = false;
      _areaCurrentAge[area] = 0;
      _areaTestedAges[area] = [];
      _areaScores[area] = 0.0;
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

  // 开始动态测评
  Future<void> startDynamicAssessment(String userName, double actualAge) async {
    _userName = userName;
    _actualAge = actualAge;
    _mainTestAge = _assessmentService.determineMainTestAge(actualAge);
    _testStartTime = DateTime.now(); // 记录测试开始时间
    _currentStage = TestStage.current;
    _currentArea = TestArea.motor; // 从大运动开始
    _currentStageItemIndex = 0;
    _testResults.clear();
    
    // 初始化能区测试状态
    _initializeAreaMaps();
    for (TestArea area in TestArea.values) {
      _areaCurrentAge[area] = _mainTestAge;
      _areaTestedAges[area] = [_mainTestAge];
      _areaAnswerStack[area] = []; // 初始化答题堆栈
    }
    
    // 确保数据已加载
    if (_allData.isEmpty) {
      await loadData();
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
    
    // 调试信息
    print('Debug: _allData.length = ${_allData.length}');
    print('Debug: testAge = $testAge');
    print('Debug: currentAreaString = $currentAreaString');
    
    // 使用 assessment_service 获取项目
    _currentStageItems = _assessmentService.getCurrentAgeAreaItems(_allData, testAge, currentAreaString);
    
    print('Debug: _currentStageItems.length = ${_currentStageItems.length}');
    
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

  // 记录测试结果 - 推入答题堆栈
  void recordResult(int itemId, bool passed) {
    _testResults[itemId] = passed;
    
    // 将当前项目推入答题堆栈
    if (currentItem != null) {
      _areaAnswerStack[_currentArea]!.add(currentItem!);
      print('Debug recordResult: pushed item ${currentItem!.id} to stack, stack length = ${_areaAnswerStack[_currentArea]!.length}');
    }
    
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

  // 增强的上一题功能：基于堆栈的回退
  void previousItemEnhanced() {
    List<AssessmentItem> stack = _areaAnswerStack[_currentArea]!;
    
    if (stack.isEmpty) return; // 堆栈为空，无法回退
    
    // 从堆栈弹出最后一个项目
    AssessmentItem poppedItem = stack.removeLast();
    print('Debug previousItemEnhanced: popped item ${poppedItem.id}, stack length now = ${stack.length}');
    
    // 清除被弹出项目的答案
    _testResults.remove(poppedItem.id);
    
    AssessmentItem targetItem = poppedItem;
    print('Debug previousItemEnhanced: navigating to stack top item ${targetItem.id}');
    _navigateToItemByStack(targetItem);
    
    notifyListeners();
  }

  // 获取当前能区的所有测试项目（按测试顺序）
  List<AssessmentItem> _getAllAreaItems() {
    List<AssessmentItem> allItems = [];
    String areaString = _getAreaString(_currentArea);
    
    // 获取已测试的月龄列表，加上当前测试月龄
    Set<int> allAges = Set.from(_areaTestedAges[_currentArea] ?? []);
    
    // 添加当前测试月龄（如果还没有包含的话）
    int currentAge = _areaCurrentAge[_currentArea] ?? _mainTestAge;
    allAges.add(currentAge);
    
    // 转换为排序列表
    List<int> sortedAges = allAges.toList()..sort();
    
    // 按月龄顺序收集所有测试项目
    for (int age in sortedAges) {
      var ageItems = _allData
          .where((data) => data.ageMonth == age && data.area == areaString)
          .expand((data) => data.testItems)
          .toList();
      allItems.addAll(ageItems);
    }
    
    return allItems;
  }



  // 基于堆栈导航到指定项目
  void _navigateToItemByStack(AssessmentItem targetItem) {
    String areaString = _getAreaString(_currentArea);
    
    // 找到目标项目所在的月龄
    int targetAge = -1;
    for (var data in _allData) {
      if (data.area == areaString) {
        for (var item in data.testItems) {
          if (item.id == targetItem.id) {
            targetAge = data.ageMonth;
            break;
          }
        }
      }
      if (targetAge != -1) break;
    }
    
    if (targetAge == -1) return;
    
    // 重新构建已测试月龄列表（基于堆栈中的项目）
    _rebuildAreaTestedAgesFromStack();
    
    // 确定应该在哪个stage
    if (targetAge == _mainTestAge) {
      _currentStage = TestStage.current;
    } else if (targetAge > _mainTestAge) {
      _currentStage = TestStage.forward;
    } else {
      _currentStage = TestStage.backward;
    }
    
    // 更新当前测试月龄
    _areaCurrentAge[_currentArea] = targetAge;
    
    // 重新加载该月龄的项目
    _loadCurrentStageItems(targetAge);
    
    // 找到目标项目在当前stage items中的索引
    for (int i = 0; i < _currentStageItems.length; i++) {
      if (_currentStageItems[i].id == targetItem.id) {
        _currentStageItemIndex = i;
        break;
      }
    }
  }

  // 重置到能区开始状态
  void _resetToAreaStart() {
    _currentStage = TestStage.current;
    _areaCurrentAge[_currentArea] = _mainTestAge;
    _areaTestedAges[_currentArea] = [_mainTestAge];
    _loadCurrentAreaItems();
  }

  // 基于答题堆栈重新构建已测试月龄列表
  void _rebuildAreaTestedAgesFromStack() {
    String areaString = _getAreaString(_currentArea);
    Set<int> validAges = <int>{};
    
    // 基于堆栈中的项目重建月龄列表
    List<AssessmentItem> stack = _areaAnswerStack[_currentArea] ?? [];
    for (AssessmentItem item in stack) {
      // 找到该项目所属的月龄
      for (var data in _allData) {
        if (data.area == areaString) {
          for (var dataItem in data.testItems) {
            if (dataItem.id == item.id) {
              validAges.add(data.ageMonth);
              break;
            }
          }
        }
      }
    }
    
    // 确保主测月龄在列表中
    validAges.add(_mainTestAge);
    
    // 更新已测试月龄列表
    _areaTestedAges[_currentArea] = validAges.toList()..sort();
  }

  // 加载指定月龄的stage items
  void _loadCurrentStageItems(int age) {
    String areaString = _getAreaString(_currentArea);
    _currentStageItems = _assessmentService.getCurrentAgeAreaItems(_allData, age, areaString);
  }

  // 检查是否可以回退到上一题 - 基于堆栈
  bool canGoToPreviousItem() {
    List<AssessmentItem> stack = _areaAnswerStack[_currentArea] ?? [];
    
    // 调试信息
    print('Debug canGoToPreviousItem: stack.length = ${stack.length}');
    if (stack.isNotEmpty) {
      print('Debug canGoToPreviousItem: stack top item = ${stack.last.id}');
      print('Debug canGoToPreviousItem: stack IDs = ${stack.map((e) => e.id).toList()}');
    }
    
    // 堆栈不为空就可以回退
    bool canGoPrevious = stack.isNotEmpty;
    print('Debug canGoToPreviousItem: result = $canGoPrevious');
    
    return canGoPrevious;
  }

  // 检查并移动到下一阶段
  void _checkAndMoveToNextStage() {
    switch (_currentStage) {
      case TestStage.current:
        // 主测月龄测试完成，开始向前测试
        _currentStage = TestStage.forward;
        _continueForwardTest();
        break;
      case TestStage.forward:
         _continueForwardTest();
        break;
      case TestStage.backward:
         _continueBackwardTest();
        break;
      case TestStage.areaCompleted:
        // 能区测试完成，移动到下一个能区
        _moveToNextArea();
        break;
      case TestStage.allCompleted:
        // 所有能区测试完成
        _generateFinalResult();
        break;
    }
    
    notifyListeners();
  }

  // 继续向前测试
  void _continueForwardTest() {
    List<int> testedAges = _getTestedAges();
    List<int> forwardAges = _assessmentService.getForwardTestAgesForArea(_mainTestAge, testedAges, _getAreaString(_currentArea), _testResults, _allData);
    if (forwardAges.length > 0) {
      // forwardAges从大到小排序取第一个
      forwardAges.sort((a, b) => b.compareTo(a));
      _areaCurrentAge[_currentArea] = forwardAges.first;
      _areaTestedAges[_currentArea]!.add(forwardAges.first);
      _loadCurrentAreaItems();
    }  else {
      // 无法继续向前，开始向后测试
      _currentStage = TestStage.backward;
      _continueBackwardTest();
    }
  }

  // 开始向后测试
  void _continueBackwardTest() {
    // 获取向后测试月龄（从主测月龄向后2个月龄）
    List<int> testedAges = _getTestedAges();
    List<int> backwardAges = _assessmentService.getBackwardTestAgesForArea(_mainTestAge, testedAges, _getAreaString(_currentArea), _testResults, _allData);
    // backwardAges从小到大排序取第一个
    backwardAges.sort((a, b) => a.compareTo(b));
    if (backwardAges.length > 0) {
      _areaCurrentAge[_currentArea] = backwardAges.first;
      _areaTestedAges[_currentArea]!.add(backwardAges.first);
      _loadCurrentAreaItems();
    }  else {
      // 无法向后，完成该能区
      _completeCurrentArea();
    }
  }

  // 完成当前能区测试
  void _completeCurrentArea() {
    _areaCompleted[_currentArea] = true;
    
    // 计算当前能区的智龄
    String areaString = _getAreaString(_currentArea);
    double areaScore = _assessmentService.calculateAreaMentalAge(areaString, _testResults, _allData);
    _areaScores[_currentArea] = areaScore;
    
    // 标记为能区完成状态
    _currentStage = TestStage.areaCompleted;
    
    notifyListeners();
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
        _currentStage = TestStage.allCompleted;
        _generateFinalResult();
        return;
    }
    
    // 重置该能区的测试状态
    _currentStageItemIndex = 0;
    _currentStage = TestStage.current;
    _areaCurrentAge[_currentArea] = _mainTestAge;
    _areaTestedAges[_currentArea] = [_mainTestAge];
    _areaAnswerStack[_currentArea] = []; // 清空新能区的答题堆栈
     
    
    _loadCurrentAreaItems();
  }



  List<int> _getTestedAges() {
    return _areaTestedAges[_currentArea] ?? [];
  }

  // 获取当前能区的智龄
  double getCurrentAreaMentalAge() {
    return _areaScores[_currentArea] ?? 0.0;
  }

  // 获取当前能区的发育商
  double getCurrentAreaDevelopmentQuotient() {
    double mentalAge = getCurrentAreaMentalAge();
    return _assessmentService.calculateDevelopmentQuotient(mentalAge, _actualAge);
  }

  // 获取当前能区已测试的项目数
  int getCurrentAreaTestedCount() {
    int count = 0;
    for (var item in _currentStageItems) {
      if (_testResults.containsKey(item.id)) {
        count++;
      }
    }
    return count;
  }

  // 获取当前能区总项目数
  int getCurrentAreaTotalCount() {
    return _currentStageItems.length;
  }

  // 获取当前能区正在测试的月龄
  int getCurrentAreaAge() {
    return _areaCurrentAge[_currentArea] ?? _mainTestAge;
  }

  // 生成最终结果
  void _generateFinalResult() {
    // 计算各能区的智龄和总分
    Map<String, double> areaScores = {};
    double totalScore = 0.0;
    
    for (TestArea area in TestArea.values) {
      double areaScore = _areaScores[area] ?? 0.0;
      areaScores[_getAreaString(area)] = areaScore;
      totalScore += areaScore;
    }
    
    // 将五个能区所得分数相加，再除以5就是总的智龄
    double mentalAge = totalScore / 5.0; // 5个能区
    double dq = _assessmentService.calculateDevelopmentQuotient(mentalAge, _actualAge);
    
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

  // 对外暴露的结果生成接口，供界面在跳转前主动生成最终结果
  void finalizeResults() {
    _generateFinalResult();
  }

  // 获取总进度
  double _getTotalProgress() {
    if (_currentStage == TestStage.allCompleted) return 1.0;
    
    int totalCompleted = 0;
    int totalItems = 0;
    
    for (TestArea area in TestArea.values) {
      List<int> testedAges = _areaTestedAges[area] ?? [];
      for (int age in testedAges) {
        String areaString = _getAreaString(area);
        var items = _assessmentService.getCurrentAgeAreaItems(_allData, age, areaString);
        totalItems += items.length;
        for (var item in items) {
          if (_testResults.containsKey(item.id)) {
            totalCompleted++;
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
      case TestStage.areaCompleted:
        return '${_getAreaName(_currentArea)}能区测试完成';
      case TestStage.allCompleted:
        return '所有能区测试完成';
    }
  }

  // 获取能区名称
  String _getAreaName(TestArea area) {
    String areaString = _getAreaString(area);
    return _assessmentService.getAreaName(areaString);
  }

  // 重置
  void reset() {
    _testResults.clear();
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