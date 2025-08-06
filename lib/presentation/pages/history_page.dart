import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/assessment_provider.dart';
import '../../app/routes.dart';
import '../../data/models/assessment_result.dart';
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
} 