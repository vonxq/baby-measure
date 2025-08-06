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
  Map<int, bool> _testResults = {};
  int _currentItemIndex = 0;
  bool _isLoading = false;
  String _error = '';
  TestResult? _finalResult;

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

  // 初始化数据
  Future<void> initializeData() async {
    _setLoading(true);
    try {
      _allData = await _dataService.loadAssessmentData();
      _error = '';
    } catch (e) {
      _error = '加载数据失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 开始测试
  Future<void> startTest(double actualAge) async {
    _setLoading(true);
    try {
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
  Future<void> completeTest(String userName, double actualAge) async {
    _setLoading(true);
    try {
      // 计算各能区结果
      final areas = ['motor', 'fineMotor', 'language', 'adaptive', 'social'];
      final areaResults = <AreaResult>[];
      
      for (String area in areas) {
        final mentalAge = _assessmentService.calculateMentalAge(area, _currentTestItems, _testResults);
        final developmentQuotient = _assessmentService.calculateDevelopmentQuotient(mentalAge, actualAge);
        
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
      final totalDevelopmentQuotient = _assessmentService.calculateDevelopmentQuotient(totalMentalAge, actualAge);

      _finalResult = TestResult(
        userName: userName,
        date: DateTime.now().toIso8601String(),
        birthDate: DateTime.now().subtract(Duration(days: (actualAge * 30).round())).toIso8601String(),
        month: actualAge,
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