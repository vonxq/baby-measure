import 'package:flutter/foundation.dart';
import '../../data/models/assessment_item.dart';
import '../../data/models/assessment_result.dart';
import '../../data/repositories/assessment_repository.dart';
import '../../core/services/assessment_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final AssessmentRepository _repository = AssessmentRepository();
  final AssessmentService _service = AssessmentService();
  
  List<AssessmentItem> _items = [];
  List<AssessmentItem> _currentTestItems = [];
  AssessmentResult? _currentResult;
  Map<String, bool> _itemResults = {};
  int _currentItemIndex = 0;
  bool _isLoading = false;
  String? _error;
  String _currentArea = '';

  // Getters
  List<AssessmentItem> get items => _items;
  List<AssessmentItem> get currentTestItems => _currentTestItems;
  AssessmentResult? get currentResult => _currentResult;
  Map<String, bool> get itemResults => _itemResults;
  int get currentItemIndex => _currentItemIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentArea => _currentArea;
  
  AssessmentItem? get currentItem {
    if (_currentItemIndex < _currentTestItems.length) {
      return _currentTestItems[_currentItemIndex];
    }
    return null;
  }

  double get progress {
    if (_currentTestItems.isEmpty) return 0.0;
    return (_currentItemIndex + 1) / _currentTestItems.length;
  }

  bool get isTestCompleted => _currentItemIndex >= _currentTestItems.length;

  // 初始化评估
  Future<void> initializeAssessment(double ageInMonths) async {
    _setLoading(true);
    try {
      _items = await _repository.getAllItems();
      _currentTestItems = _service.getTestItemsForAge(_items, ageInMonths);
      _itemResults.clear();
      _currentItemIndex = 0;
      _currentArea = _currentTestItems.isNotEmpty ? _currentTestItems.first.areaType : '';
      _error = null;
    } catch (e) {
      _error = '初始化评估失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 记录项目结果
  void recordItemResult(String itemId, bool result) {
    _itemResults[itemId] = result;
    notifyListeners();
  }

  // 下一题
  void nextItem() {
    if (_currentItemIndex < _currentTestItems.length - 1) {
      _currentItemIndex++;
      _updateCurrentArea();
      notifyListeners();
    }
  }

  // 上一题
  void previousItem() {
    if (_currentItemIndex > 0) {
      _currentItemIndex--;
      _updateCurrentArea();
      notifyListeners();
    }
  }

  // 跳转到指定题目
  void jumpToItem(int index) {
    if (index >= 0 && index < _currentTestItems.length) {
      _currentItemIndex = index;
      _updateCurrentArea();
      notifyListeners();
    }
  }

  // 完成评估
  Future<AssessmentResult?> completeAssessment(String babyId, double ageInMonths) async {
    _setLoading(true);
    try {
      final result = _service.calculateResult(
        _currentTestItems,
        _itemResults,
        babyId,
        ageInMonths,
      );
      
      _currentResult = await _repository.saveResult(result);
      _error = null;
      return _currentResult;
    } catch (e) {
      _error = '完成评估失败: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 重置评估
  void resetAssessment() {
    _itemResults.clear();
    _currentItemIndex = 0;
    _currentResult = null;
    _error = null;
    if (_currentTestItems.isNotEmpty) {
      _currentArea = _currentTestItems.first.areaType;
    }
    notifyListeners();
  }

  // 获取当前能区的项目
  List<AssessmentItem> getCurrentAreaItems() {
    if (_currentTestItems.isEmpty) return [];
    return _currentTestItems.where((item) => item.areaType == _currentArea).toList();
  }

  // 获取能区进度
  Map<String, double> getAreaProgress() {
    Map<String, List<AssessmentItem>> areaItems = {};
    Map<String, int> areaCompleted = {};
    
    for (var item in _currentTestItems) {
      areaItems.putIfAbsent(item.areaType, () => []).add(item);
      if (_itemResults.containsKey(item.id)) {
        areaCompleted[item.areaType] = (areaCompleted[item.areaType] ?? 0) + 1;
      }
    }
    
    Map<String, double> progress = {};
    areaItems.forEach((area, items) {
      progress[area] = (areaCompleted[area] ?? 0) / items.length;
    });
    
    return progress;
  }

  // 更新当前能区
  void _updateCurrentArea() {
    if (_currentItemIndex < _currentTestItems.length) {
      _currentArea = _currentTestItems[_currentItemIndex].areaType;
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    // 使用Future.microtask来避免在build期间调用notifyListeners
    Future.microtask(() => notifyListeners());
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 设置当前结果（用于历史记录查看）
  void setCurrentResult(AssessmentResult result) {
    _currentResult = result;
    notifyListeners();
  }
} 