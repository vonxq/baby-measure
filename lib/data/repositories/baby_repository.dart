import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby.dart';

class BabyRepository {
  static const String _storageKey = 'babies';
  
  // 获取所有宝宝
  Future<List<Baby>> getAllBabies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? babiesJson = prefs.getString(_storageKey);
      
      if (babiesJson == null || babiesJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> babiesList = json.decode(babiesJson);
      return babiesList
          .map((json) => Baby.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('获取宝宝列表失败: $e');
    }
  }
  
  // 添加宝宝
  Future<Baby> addBaby(Baby baby) async {
    try {
      final List<Baby> babies = await getAllBabies();
      babies.add(baby);
      await _saveBabies(babies);
      return baby;
    } catch (e) {
      throw Exception('添加宝宝失败: $e');
    }
  }
  
  // 更新宝宝信息
  Future<Baby> updateBaby(Baby baby) async {
    try {
      final List<Baby> babies = await getAllBabies();
      final index = babies.indexWhere((b) => b.id == baby.id);
      
      if (index == -1) {
        throw Exception('宝宝不存在');
      }
      
      babies[index] = baby;
      await _saveBabies(babies);
      return baby;
    } catch (e) {
      throw Exception('更新宝宝信息失败: $e');
    }
  }
  
  // 删除宝宝
  Future<void> deleteBaby(String babyId) async {
    try {
      final List<Baby> babies = await getAllBabies();
      babies.removeWhere((baby) => baby.id == babyId);
      await _saveBabies(babies);
    } catch (e) {
      throw Exception('删除宝宝失败: $e');
    }
  }
  
  // 根据ID获取宝宝
  Future<Baby?> getBabyById(String babyId) async {
    try {
      final List<Baby> babies = await getAllBabies();
      return babies.firstWhere((baby) => baby.id == babyId);
    } catch (e) {
      return null;
    }
  }
  
  // 保存宝宝列表
  Future<void> _saveBabies(List<Baby> babies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String babiesJson = json.encode(
        babies.map((baby) => baby.toJson()).toList(),
      );
      await prefs.setString(_storageKey, babiesJson);
    } catch (e) {
      throw Exception('保存宝宝信息失败: $e');
    }
  }
  
  // 清空所有宝宝数据
  Future<void> clearAllBabies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      throw Exception('清空宝宝数据失败: $e');
    }
  }
} 