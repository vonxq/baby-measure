import 'package:flutter/material.dart';
import '../utils/dq_utils.dart';
import '../utils/area_utils.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../models/test_result.dart';
import '../models/assessment_history.dart';
import '../services/data_service.dart';
import 'score_explanation_page.dart';
import 'answer_record_page.dart';
import '../widgets/area_score_card.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // 自动保存测评历史
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveAssessmentHistory();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 保存测评历史
  Future<void> _saveAssessmentHistory() async {
    final provider = Provider.of<AssessmentProvider>(context, listen: false);
    if (provider.finalResult == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final result = provider.finalResult!;
      final history = AssessmentHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        babyName: provider.userName,
        actualAge: provider.actualAge,
        startTime: provider.testStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        areaScores: result.areaScores.map((key, value) => MapEntry(
          _getTestAreaFromString(key), value
        )),
        areaDQs: result.areaScores.map((key, value) => MapEntry(
          _getTestAreaFromString(key), _calculateAreaDQ(value)
        )),
        overallMentalAge: result.averageScore,
        overallDQ: result.dq,
        overallLevel: result.dqLevel,
      );

      await DataService().saveAssessmentHistory(history);
      // 同步保存答题记录，使用相同的 history id 建立关联
      await DataService().saveTestResult({
        'id': history.id,
        'userName': result.userName,
        'actualAge': result.actualAge,
        'mainTestAge': result.mainTestAge,
        'areaScores': result.areaScores,
        'dq': result.dq,
        'testResults': result.testResults,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存测评历史失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 从字符串获取TestArea枚举
  TestArea _getTestAreaFromString(String areaName) {
    switch (areaName) {
      case 'motor':
        return TestArea.motor;
      case 'fineMotor':
        return TestArea.fineMotor;
      case 'language':
        return TestArea.language;
      case 'adaptive':
        return TestArea.adaptive;
      case 'social':
        return TestArea.social;
      default:
        return TestArea.motor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Consumer<AssessmentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue[600]),
                      const SizedBox(height: 16),
                      const Text('正在生成结果...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }

              if (provider.finalResult == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      const Text('暂无测试结果', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        icon: const Icon(Icons.home),
                        label: const Text('返回首页'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final result = provider.finalResult!;
              
              // 检查结果数据的有效性
              if (result.testResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 64, color: Colors.orange[400]),
                      const SizedBox(height: 16),
                      const Text('测试结果数据不完整', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        icon: const Icon(Icons.home),
                        label: const Text('返回首页'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  // 可滚动的内容区域
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 总体结果卡片
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.assessment,
                                      size: 48,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '测试完成',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '测试时间: ${DateTime.now().toString().substring(0, 19)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildResultItem('总体智龄', '${result.averageScore.toStringAsFixed(1)}个月'),
                                      _buildResultItem('发育商', result.dq.toStringAsFixed(1)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // 发育商评级
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: result.dqLevelColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: result.dqLevelColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      result.dqLevel,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: result.dqLevelColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _getDevelopmentLevelDescription(result.dq),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 各能区结果
                            Text(
                              '各能区详细结果',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 能区分数卡片一行布局
                            Row(
                              children: result.areaScores.entries.map((entry) {
                                final areaDQ = _calculateAreaDQ(entry.value);
                                return Expanded(
                                  child: AreaScoreCard(
                                    title: _getAreaDisplayName(entry.key),
                                    score: entry.value,
                                    dq: areaDQ,
                                    unit: '月',
                                    showDQ: true,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 固定的按钮区域
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 保存状态提示
                        if (_isSaving)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '正在保存测评历史...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // 答题记录按钮
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final provider = Provider.of<AssessmentProvider>(context, listen: false);
                              if (provider.finalResult != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnswerRecordPage(runtimeResult: provider.finalResult),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.list_alt),
                            label: const Text('查看答题记录'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 分数说明按钮
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScoreExplanationPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.help_outline),
                            label: const Text('查看分数说明'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                       
                        // 操作按钮
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                                icon: const Icon(Icons.home),
                                label: const Text('返回首页'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  // 获取发育商评级说明
  String _getDevelopmentLevelDescription(double dq) {
    if (dq > 130) return '您的孩子发育水平优秀，各项能力发展良好。';
    if (dq >= 110) return '您的孩子发育水平良好，各项能力发展正常。';
    if (dq >= 80) return '您的孩子发育水平中等，建议关注发展情况。';
    if (dq >= 70) return '您的孩子发育水平偏低，建议咨询专业医生。';
    return '您的孩子可能存在发育障碍，请及时咨询专业医生进行评估。';
  }



  // // 显示报告
  // void _showReport(BuildContext context, TestResult result) {
  //   final report = ExportService.generateReport(result);
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('测试报告'),
  //         content: SingleChildScrollView(
  //           child: Text(report, style: const TextStyle(fontSize: 12)),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('关闭'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // 显示成功对话框
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('导出成功'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示错误对话框
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('导出失败'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAreaResultCard(String areaName, double score) {
    Color cardColor;
    IconData iconData;
    Color iconColor;
    
    // 根据得分确定颜色和图标
    if (score >= 3.0) {
      cardColor = Colors.green[50]!;
      iconData = Icons.trending_up;
      iconColor = Colors.green[600]!;
    } else if (score >= 1.0) {
      cardColor = Colors.blue[50]!;
      iconData = Icons.check_circle;
      iconColor = Colors.blue[600]!;
    } else {
      cardColor = Colors.orange[50]!;
      iconData = Icons.warning;
      iconColor = Colors.orange[600]!;
    }

    // 计算能区发育商
    final areaDQ = _calculateAreaDQ(score);
    final dqLevel = _getAreaDQLevel(areaDQ);
    final dqColor = _getAreaDQColor(areaDQ);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getAreaDisplayName(areaName),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 发育商评级
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: dqColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dqColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          dqLevel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: dqColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 分数详情
            Row(
              children: [
                Expanded(
                  child: _buildResultItem('智龄', '${score.toStringAsFixed(1)}月'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildResultItem('发育商', '${areaDQ.toStringAsFixed(1)}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 计算能区发育商
  double _calculateAreaDQ(double mentalAge) {
    // 从provider获取实际年龄
    final provider = Provider.of<AssessmentProvider>(context, listen: false);
    double actualAge = provider.actualAge;
    if (actualAge == 0) return 0;
    return (mentalAge / actualAge) * 100;
  }

  // 获取能区发育商评级
  String _getAreaDQLevel(double dq) => DqUtils.labelByDq(dq);

  // 获取能区发育商颜色
  Color _getAreaDQColor(double dq) => DqUtils.colorByDq(dq);


  String _getAreaDisplayName(String areaName) => AreaUtils.displayName(areaName);
} 