import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorHandler {
  static void showError(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      '警告',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  static bool isValidAge(double ageInMonths) {
    return ageInMonths >= 0 && ageInMonths <= 84;
  }

  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length <= 20;
  }

  static bool isValidBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    final minDate = now.subtract(Duration(days: 365 * 6)); // 6年前
    final maxDate = now;
    
    return birthDate.isAfter(minDate) && birthDate.isBefore(maxDate);
  }
} 