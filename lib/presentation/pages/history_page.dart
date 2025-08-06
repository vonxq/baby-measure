import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/baby_provider.dart';
import '../providers/assessment_provider.dart';
import '../../app/routes.dart';
import '../../data/models/assessment_result.dart';
import '../../data/models/baby.dart';
import '../../data/repositories/assessment_repository.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AssessmentRepository _repository = AssessmentRepository();
  List<AssessmentResult> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      if (babyProvider.currentBaby != null) {
        _results = await _repository.getResultsByBabyId(babyProvider.currentBaby!.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载历史记录失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评估历史'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: _exportData,
              tooltip: '导出数据',
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, child) {
          if (_isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (babyProvider.currentBaby == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red),
                  SizedBox(height: 20),
                  Text('请先选择宝宝', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('返回'),
                  ),
                ],
              ),
            );
          }

          if (_results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('还没有评估记录', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.assessment),
                    child: Text('开始评估'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 宝宝信息
              _buildBabyInfo(babyProvider.currentBaby!),
              
              // 导出提示
              if (_results.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '点击右上角导出按钮可导出评估数据',
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // 历史记录列表
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return _buildHistoryItem(result, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBabyInfo(Baby baby) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue[100],
            child: Icon(Icons.child_care, size: 25, color: Colors.blue[600]),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baby.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${baby.ageInMonths.toStringAsFixed(1)}个月 · ${_results.length}次评估',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(AssessmentResult result, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showResultDetail(result),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '第${_results.length - index}次评估',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${result.testDate.year}-${result.testDate.month.toString().padLeft(2, '0')}-${result.testDate.day.toString().padLeft(2, '0')} · ${result.ageInMonths.toStringAsFixed(1)}个月',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(result.levelColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(result.levelColor)),
                    ),
                    child: Text(
                      result.levelDescription,
                      style: TextStyle(
                        color: Color(result.levelColor),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // 发育商
              Row(
                children: [
                  Text(
                    '发育商: ',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    result.developmentQuotient.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(result.levelColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // 各能区得分
              Row(
                children: [
                  Expanded(
                    child: _buildAreaScore('大运动', result.areaResults['motor']?.mentalAge ?? 0),
                  ),
                  Expanded(
                    child: _buildAreaScore('精细动作', result.areaResults['fineMotor']?.mentalAge ?? 0),
                  ),
                  Expanded(
                    child: _buildAreaScore('语言', result.areaResults['language']?.mentalAge ?? 0),
                  ),
                  Expanded(
                    child: _buildAreaScore('适应能力', result.areaResults['adaptive']?.mentalAge ?? 0),
                  ),
                  Expanded(
                    child: _buildAreaScore('社会行为', result.areaResults['social']?.mentalAge ?? 0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaScore(String areaName, double score) {
    return Column(
      children: [
        Text(
          areaName,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showResultDetail(AssessmentResult result) {
    // 设置当前结果到Provider
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    // 通过公共方法设置结果
    assessmentProvider.setCurrentResult(result);
    
    Get.toNamed(AppRoutes.result);
  }

  // 趋势分析
  Widget _buildTrendAnalysis() {
    if (_results.length < 2) return Container();

    // 计算趋势
    final latest = _results.first;
    final previous = _results[1];
    final trend = latest.developmentQuotient - previous.developmentQuotient;
    
    String trendText = '';
    Color trendColor = Colors.grey;
    
    if (trend > 5) {
      trendText = '上升';
      trendColor = Colors.green;
    } else if (trend < -5) {
      trendText = '下降';
      trendColor = Colors.red;
    } else {
      trendText = '稳定';
      trendColor = Colors.blue;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '发展趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  trend > 0 ? Icons.trending_up : trend < 0 ? Icons.trending_down : Icons.trending_flat,
                  color: trendColor,
                ),
                SizedBox(width: 8),
                Text(
                  '发育商${trendText} ${trend.abs().toStringAsFixed(1)}分',
                  style: TextStyle(color: trendColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() async {
    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final baby = babyProvider.currentBaby;
      
      if (baby == null || _results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('没有可导出的数据')),
        );
        return;
      }

      // 显示导出选项
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '选择导出格式',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.description, color: Colors.blue),
                title: Text('JSON格式'),
                subtitle: Text('包含完整评估数据'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsJson(baby);
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('CSV格式'),
                subtitle: Text('便于Excel打开'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsCsv(baby);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('PDF报告'),
                subtitle: Text('生成详细报告'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsPdf(baby);
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  void _exportAsJson(Baby baby) async {
    try {
      final exportData = {
        'baby': {
          'id': baby.id,
          'name': baby.name,
          'birthDate': baby.birthDate.toIso8601String(),
          'gender': baby.gender,
          'ageInMonths': baby.ageInMonths,
        },
        'exportDate': DateTime.now().toIso8601String(),
        'totalAssessments': _results.length,
        'assessments': _results.map((result) => {
          'id': result.id,
          'testDate': result.testDate.toIso8601String(),
          'ageInMonths': result.ageInMonths,
          'developmentQuotient': result.developmentQuotient,
          'levelDescription': result.levelDescription,
          'levelColor': result.levelColor,
          'areaResults': result.areaResults.map((key, value) => MapEntry(key, {
            'mentalAge': value.mentalAge,
            'score': value.score,
            'maxScore': value.maxScore,
            'percentage': value.percentage,
          })),
          'totalScore': result.totalScore,
          'maxTotalScore': result.maxTotalScore,
        }).toList(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      final fileName = '${baby.name}_评估数据_${DateTime.now().millisecondsSinceEpoch}.json';
      
      await _saveAndShareFile(jsonString, fileName, 'application/json');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('JSON数据导出成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  void _exportAsCsv(Baby baby) async {
    try {
      final csvData = StringBuffer();
      
      // 添加宝宝信息
      csvData.writeln('宝宝信息');
      csvData.writeln('姓名,${baby.name}');
      csvData.writeln('出生日期,${baby.birthDate.toIso8601String().split('T')[0]}');
      csvData.writeln('性别,${baby.gender == 'male' ? '男' : '女'}');
      csvData.writeln('当前月龄,${baby.ageInMonths.toStringAsFixed(1)}');
      csvData.writeln('');
      
      // 添加评估记录
      csvData.writeln('评估记录');
      csvData.writeln('序号,评估日期,月龄,发育商,发育水平,大运动,精细动作,语言,适应能力,社会行为,总分,满分');
      
      for (int i = 0; i < _results.length; i++) {
        final result = _results[i];
        csvData.writeln([
          i + 1,
          result.testDate.toIso8601String().split('T')[0],
          result.ageInMonths.toStringAsFixed(1),
          result.developmentQuotient.toStringAsFixed(1),
          result.levelDescription,
          result.areaResults['motor']?.mentalAge.toStringAsFixed(1) ?? '0',
          result.areaResults['fineMotor']?.mentalAge.toStringAsFixed(1) ?? '0',
          result.areaResults['language']?.mentalAge.toStringAsFixed(1) ?? '0',
          result.areaResults['adaptive']?.mentalAge.toStringAsFixed(1) ?? '0',
          result.areaResults['social']?.mentalAge.toStringAsFixed(1) ?? '0',
          result.totalScore.toStringAsFixed(1),
          result.maxTotalScore.toStringAsFixed(1),
        ].join(','));
      }
      
      final fileName = '${baby.name}_评估数据_${DateTime.now().millisecondsSinceEpoch}.csv';
      await _saveAndShareFile(csvData.toString(), fileName, 'text/csv');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV数据导出成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  void _exportAsPdf(Baby baby) async {
    try {
      // 生成简单的文本报告
      final reportData = StringBuffer();
      reportData.writeln('儿童发育行为评估报告');
      reportData.writeln('=' * 50);
      reportData.writeln('');
      reportData.writeln('宝宝信息:');
      reportData.writeln('姓名: ${baby.name}');
      reportData.writeln('出生日期: ${baby.birthDate.toIso8601String().split('T')[0]}');
      reportData.writeln('性别: ${baby.gender == 'male' ? '男' : '女'}');
      reportData.writeln('当前月龄: ${baby.ageInMonths.toStringAsFixed(1)}个月');
      reportData.writeln('');
      reportData.writeln('评估记录:');
      reportData.writeln('-' * 30);
      
      for (int i = 0; i < _results.length; i++) {
        final result = _results[i];
        reportData.writeln('第${_results.length - i}次评估 (${result.testDate.toIso8601String().split('T')[0]})');
        reportData.writeln('月龄: ${result.ageInMonths.toStringAsFixed(1)}个月');
        reportData.writeln('发育商: ${result.developmentQuotient.toStringAsFixed(1)}');
        reportData.writeln('发育水平: ${result.levelDescription}');
        reportData.writeln('各能区得分:');
        reportData.writeln('  大运动: ${result.areaResults['motor']?.mentalAge.toStringAsFixed(1) ?? '0'}');
        reportData.writeln('  精细动作: ${result.areaResults['fineMotor']?.mentalAge.toStringAsFixed(1) ?? '0'}');
        reportData.writeln('  语言: ${result.areaResults['language']?.mentalAge.toStringAsFixed(1) ?? '0'}');
        reportData.writeln('  适应能力: ${result.areaResults['adaptive']?.mentalAge.toStringAsFixed(1) ?? '0'}');
        reportData.writeln('  社会行为: ${result.areaResults['social']?.mentalAge.toStringAsFixed(1) ?? '0'}');
        reportData.writeln('');
      }
      
      final fileName = '${baby.name}_评估报告_${DateTime.now().millisecondsSinceEpoch}.txt';
      await _saveAndShareFile(reportData.toString(), fileName, 'text/plain');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评估报告导出成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  Future<void> _saveAndShareFile(String content, String fileName, String mimeType) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${fileName.split('_')[0]}的评估数据',
      );
    } catch (e) {
      throw Exception('保存文件失败: $e');
    }
  }
} 