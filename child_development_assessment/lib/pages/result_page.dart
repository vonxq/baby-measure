import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../models/test_result.dart';
import 'score_explanation_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                                    '测试时间: ${DateTime.parse(result.date).toString().substring(0, 19)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildResultItem('总体智龄', '${result.allResult.mentalAge.toStringAsFixed(1)}个月'),
                                      _buildResultItem('发育商', result.allResult.developmentQuotient.toStringAsFixed(1)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // 发育商评级
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _getDevelopmentLevelColor(result.allResult.developmentQuotient).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getDevelopmentLevelColor(result.allResult.developmentQuotient),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getDevelopmentLevel(result.allResult.developmentQuotient),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getDevelopmentLevelColor(result.allResult.developmentQuotient),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _getDevelopmentLevelDescription(result.allResult.developmentQuotient),
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

                            ...result.testResults.map((areaResult) => _buildAreaResultCard(areaResult)),
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
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  provider.resetTest();
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('重新测试'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
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

  // 获取发育商评级
  String _getDevelopmentLevel(double dq) {
    if (dq > 130) return '优秀';
    if (dq >= 110) return '良好';
    if (dq >= 80) return '中等';
    if (dq >= 70) return '临界偏低';
    return '智力发育障碍';
  }

  // 获取发育商评级颜色
  Color _getDevelopmentLevelColor(double dq) {
    if (dq > 130) return Colors.green[600]!;
    if (dq >= 110) return Colors.blue[600]!;
    if (dq >= 80) return Colors.orange[600]!;
    if (dq >= 70) return Colors.orange[700]!;
    return Colors.red[600]!;
  }

  // 获取发育商评级说明
  String _getDevelopmentLevelDescription(double dq) {
    if (dq > 130) return '您的孩子发育水平优秀，各项能力发展良好。';
    if (dq >= 110) return '您的孩子发育水平良好，各项能力发展正常。';
    if (dq >= 80) return '您的孩子发育水平中等，建议关注发展情况。';
    if (dq >= 70) return '您的孩子发育水平偏低，建议咨询专业医生。';
    return '您的孩子可能存在发育障碍，请及时咨询专业医生进行评估。';
  }

  Widget _buildAreaResultCard(AreaResult areaResult) {
    Color cardColor;
    IconData iconData;
    Color iconColor;
    
    // 根据发育商确定颜色和图标
    if (areaResult.developmentQuotient >= 110) {
      cardColor = Colors.green[50]!;
      iconData = Icons.trending_up;
      iconColor = Colors.green[600]!;
    } else if (areaResult.developmentQuotient >= 80) {
      cardColor = Colors.blue[50]!;
      iconData = Icons.check_circle;
      iconColor = Colors.blue[600]!;
    } else {
      cardColor = Colors.orange[50]!;
      iconData = Icons.warning;
      iconColor = Colors.orange[600]!;
    }

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
        child: Row(
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
                    areaResult.area,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultItem('智龄', '${areaResult.mentalAge.toStringAsFixed(1)}个月'),
                      ),
                      Expanded(
                        child: _buildResultItem('发育商', areaResult.developmentQuotient.toStringAsFixed(1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 各能区发育商评级
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDevelopmentLevelColor(areaResult.developmentQuotient).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDevelopmentLevelColor(areaResult.developmentQuotient),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getDevelopmentLevel(areaResult.developmentQuotient),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getDevelopmentLevelColor(areaResult.developmentQuotient),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 