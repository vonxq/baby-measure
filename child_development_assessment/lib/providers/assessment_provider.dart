import 'package:flutter/foundation.dart';
import '../models/assessment_data.dart';
import '../models/assessment_item.dart';
import '../models/test_result.dart';
import '../services/assessment_service.dart';
import '../services/data_service.dart';

class AssessmentProvider with ChangeNotifier {
  final AssessmentService _assessmentService = AssessmentService();
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

  // Getters
  List<AssessmentData> get allData => _allData;
  List<AssessmentItem> get currentTestItems => _currentTestItems;
  Map<int, bool> get testResults => _testResults;
  int get currentItemIndex => _currentItemIndex;
  bool get isLoading => _isLoading;
  String get error => _error;
  TestResult? get finalResult => _finalResult;
  AssessmentItem? get currentItem => _currentTestItems.isNotEmpty && _currentItemIndex < _currentTestItems.length 
      ? _currentTestItems[_currentItemIndex] 
      : null;
  double get progress => _currentTestItems.isNotEmpty ? (_currentItemIndex + 1) / _currentTestItems.length : 0.0;
  
  // 获取item的area
  String getItemArea(int itemId) {
    return _itemAreaMap[itemId] ?? 'unknown';
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

  // 开始测试
  Future<void> startTest(String userName, double actualAge) async {
    _setLoading(true);
    try {
      _userName = userName;
      _actualAge = actualAge;
      _currentTestItems = _assessmentService.getTestItems(_allData, actualAge);
      _testResults.clear();
      _currentItemIndex = 0;
      _finalResult = null;
      _error = '';
    } catch (e) {
      _error = '开始测试失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 记录测试结果
  void recordResult(int itemId, bool passed) {
    _testResults[itemId] = passed;
    notifyListeners();
  }

  // 下一题
  void nextItem() {
    if (_currentItemIndex < _currentTestItems.length - 1) {
      _currentItemIndex++;
      notifyListeners();
    }
  }

  // 上一题
  void previousItem() {
    if (_currentItemIndex > 0) {
      _currentItemIndex--;
      notifyListeners();
    }
  }

  // 完成测试
  Future<void> completeTest() async {
    _setLoading(true);
    try {
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