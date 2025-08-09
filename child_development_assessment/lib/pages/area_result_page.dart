import 'package:flutter/material.dart';
import '../providers/assessment_provider.dart';
import 'package:provider/provider.dart';
import 'result_page.dart';
import '../utils/dq_utils.dart';

class AreaResultPage extends StatelessWidget {
  final TestArea area;
  final double mentalAge;
  final double developmentQuotient;
  final VoidCallback? onContinue;
  final bool isLastArea;

  const AreaResultPage({
    super.key,
    required this.area,
    required this.mentalAge,
    required this.developmentQuotient,
    this.onContinue,
    this.isLastArea = false,
  });

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
          child: Column(
            children: [
              // 顶部标题
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
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
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_getAreaName(area)}能区测试完成',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 可滚动的结果区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // 结果卡片
                      Container(
                        width: double.infinity,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 智龄结果
                            _buildResultCard(
                              title: '智龄',
                              value: '${mentalAge.toStringAsFixed(1)}月',
                              icon: Icons.timeline,
                              color: Colors.blue[600]!,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 发育商结果
                            _buildResultCard(
                              title: '发育商',
                              value: developmentQuotient.toStringAsFixed(1),
                              subtitle: _getDqLevel(developmentQuotient),
                              icon: Icons.psychology,
                              color: _getDqLevelColor(developmentQuotient),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 发育商说明
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '发育商说明',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '发育商(DQ) = (智龄 / 实际年龄) × 100\n\n'
                                    '• DQ > 130：优秀\n'
                                    '• DQ 110-130：良好\n'
                                    '• DQ 80-110：中等\n'
                                    '• DQ 70-80：临界偏低\n'
                                    '• DQ < 70：智力发育障碍',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // 底部按钮
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isLastArea) {
                        // 确保在跳转前已生成最终结果
                        try {
                          final provider = Provider.of<AssessmentProvider>(context, listen: false);
                          provider.finalizeResults();
                        } catch (_) {}
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const ResultPage()),
                        );
                      } else {
                        if (onContinue != null) {
                          onContinue!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    icon: Icon(isLastArea ? Icons.assignment_turned_in : Icons.arrow_forward),
                    label: Text(isLastArea ? '查看最终结果' : '继续下一个能区'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAreaName(TestArea area) {
    switch (area) {
      case TestArea.motor:
        return '大运动';
      case TestArea.fineMotor:
        return '精细动作';
      case TestArea.language:
        return '语言';
      case TestArea.adaptive:
        return '适应能力';
      case TestArea.social:
        return '社会行为';
    }
  }

  String _getDqLevel(double dq) => DqUtils.labelByDq(dq);

  Color _getDqLevelColor(double dq) => DqUtils.colorByDq(dq);
} 