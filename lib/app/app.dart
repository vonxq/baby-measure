import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart';

class App {
  static void init() {
    // 初始化应用配置
    _initServices();
    _initRoutes();
  }

  static void _initServices() {
    // 初始化服务
    // TODO: 初始化数据库、本地存储等服务
  }

  static void _initRoutes() {
    // 路由已在routes.dart中配置
  }

  static void showLoading() {
    Get.dialog(
      Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }

  static void showSnackBar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? '错误' : '提示',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
} 