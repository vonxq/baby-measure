import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/test_result.dart';

class ExportService {
  // 导出测试结果为JSON文件
  static Future<String> exportToJson(TestResult result) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'assessment_result_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      final jsonData = result.toJson();
      await file.writeAsString(jsonEncode(jsonData));
      
      return file.path;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  // 导出测试结果为CSV文件
  static Future<String> exportToCsv(TestResult result) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'assessment_result_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      
      final csvContent = _generateCsvContent(result);
      await file.writeAsString(csvContent);
      
      return file.path;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  // 生成CSV内容
  static String _generateCsvContent(TestResult result) {
    final buffer = StringBuffer();
    
    // 标题行
    buffer.writeln('姓名,测试日期,月龄,总体智龄,总体发育商,评级');
    
    // 总体结果
    final overallLevel = _getDevelopmentLevel(result.allResult.developmentQuotient);
    buffer.writeln('${result.userName},${result.date},${result.month},${result.allResult.mentalAge},${result.allResult.developmentQuotient},$overallLevel');
    
    // 空行
    buffer.writeln();
    
    // 各能区结果标题
    buffer.writeln('能区,智龄,发育商,评级');
    
    // 各能区结果
    for (var areaResult in result.testResults) {
      final level = _getDevelopmentLevel(areaResult.developmentQuotient);
      buffer.writeln('${areaResult.area},${areaResult.mentalAge},${areaResult.developmentQuotient},$level');
    }
    
    return buffer.toString();
  }

  // 获取发育商评级
  static String _getDevelopmentLevel(double dq) {
    if (dq > 130) return '优秀';
    if (dq >= 110) return '良好';
    if (dq >= 80) return '中等';
    if (dq >= 70) return '临界偏低';
    return '智力发育障碍';
  }

  // 生成测试报告
  static String generateReport(TestResult result) {
    final buffer = StringBuffer();
    
    buffer.writeln('儿童发育评估报告');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    // 基本信息
    buffer.writeln('基本信息:');
    buffer.writeln('姓名: ${result.userName}');
    buffer.writeln('测试日期: ${DateTime.parse(result.date).toString().substring(0, 19)}');
    buffer.writeln('月龄: ${result.month}个月');
    buffer.writeln();
    
    // 总体结果
    buffer.writeln('总体评估结果:');
    buffer.writeln('总体智龄: ${result.allResult.mentalAge.toStringAsFixed(1)}个月');
    buffer.writeln('总体发育商: ${result.allResult.developmentQuotient.toStringAsFixed(1)}');
    buffer.writeln('评级: ${_getDevelopmentLevel(result.allResult.developmentQuotient)}');
    buffer.writeln();
    
    // 各能区结果
    buffer.writeln('各能区详细结果:');
    buffer.writeln('-' * 30);
    
    for (var areaResult in result.testResults) {
      final level = _getDevelopmentLevel(areaResult.developmentQuotient);
      buffer.writeln('${areaResult.area}:');
      buffer.writeln('  智龄: ${areaResult.mentalAge.toStringAsFixed(1)}个月');
      buffer.writeln('  发育商: ${areaResult.developmentQuotient.toStringAsFixed(1)}');
      buffer.writeln('  评级: $level');
      buffer.writeln();
    }
    
    // 说明
    buffer.writeln('说明:');
    buffer.writeln('• 发育商 > 130: 优秀');
    buffer.writeln('• 发育商 110-129: 良好');
    buffer.writeln('• 发育商 80-109: 中等');
    buffer.writeln('• 发育商 70-79: 临界偏低');
    buffer.writeln('• 发育商 < 70: 智力发育障碍');
    buffer.writeln();
    buffer.writeln('注意: 本报告仅供参考，如有疑问请咨询专业医生。');
    
    return buffer.toString();
  }
} 