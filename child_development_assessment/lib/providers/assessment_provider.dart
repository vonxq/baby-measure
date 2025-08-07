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

  // Getters
  List<AssessmentData> get allData => _allData;
  Map<int, bool> get testResults => _testResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  TestResult? get finalResult => _finalResult;
  String get userName => _userName;
  double get actualAge => _actualAge;
  int get mainTestAge => _mainTestAge;
  
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
    
    // 使用 assessment_service 获取项目
    _currentStageItems = _assessmentService.getCurrentAgeAreaItems(_allData, testAge, currentAreaString);

    
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
      areaScores[area.toString()] = areaScore;
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