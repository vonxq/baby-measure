import 'package:flutter/foundation.dart';
import '../../data/models/baby.dart';
import '../../data/repositories/baby_repository.dart';

class BabyProvider extends ChangeNotifier {
  final BabyRepository _repository = BabyRepository();
  
  List<Baby> _babies = [];
  Baby? _currentBaby;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Baby> get babies => _babies;
  Baby? get currentBaby => _currentBaby;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 初始化
  Future<void> initialize() async {
    await loadBabies();
  }

  // 加载宝宝列表
  Future<void> loadBabies() async {
    _setLoading(true);
    try {
      _babies = await _repository.getAllBabies();
      if (_babies.isNotEmpty && _currentBaby == null) {
        _currentBaby = _babies.first;
      }
      _error = null;
    } catch (e) {
      _error = '加载宝宝信息失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 添加宝宝
  Future<bool> addBaby(Baby baby) async {
    _setLoading(true);
    try {
      final newBaby = await _repository.addBaby(baby);
      _babies.add(newBaby);
      if (_currentBaby == null) {
        _currentBaby = newBaby;
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '添加宝宝失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新宝宝信息
  Future<bool> updateBaby(Baby baby) async {
    _setLoading(true);
    try {
      final updatedBaby = await _repository.updateBaby(baby);
      final index = _babies.indexWhere((b) => b.id == baby.id);
      if (index != -1) {
        _babies[index] = updatedBaby;
      }
      if (_currentBaby?.id == baby.id) {
        _currentBaby = updatedBaby;
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '更新宝宝信息失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除宝宝
  Future<bool> deleteBaby(String babyId) async {
    _setLoading(true);
    try {
      await _repository.deleteBaby(babyId);
      _babies.removeWhere((baby) => baby.id == babyId);
      if (_currentBaby?.id == babyId) {
        _currentBaby = _babies.isNotEmpty ? _babies.first : null;
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '删除宝宝失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 设置当前宝宝
  void setCurrentBaby(Baby baby) {
    _currentBaby = baby;
    notifyListeners();
  }

  // 获取宝宝数量
  int get babyCount => _babies.length;

  // 检查是否有宝宝
  bool get hasBabies => _babies.isNotEmpty;

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 清除所有宝宝数据
  Future<bool> clearAllBabies() async {
    _setLoading(true);
    try {
      await _repository.clearAllBabies();
      _babies.clear();
      _currentBaby = null;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '清除所有宝宝数据失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
} 