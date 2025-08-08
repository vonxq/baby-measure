import 'package:flutter/material.dart';
import '../../models/assessment_history.dart';
import '../../providers/assessment_provider.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.isLoading,
    required this.histories,
  });

  final bool isLoading;
  final List<AssessmentHistory> histories;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无测评历史',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '完成测评后，历史记录将显示在这里',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: history.overallDQColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assessment,
                        color: history.overallDQColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history.babyName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${history.actualAge.toStringAsFixed(1)}个月 | ${history.startTimeText}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: history.overallDQColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: history.overallDQColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        history.overallLevel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: history.overallDQColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildHistoryItem('智龄', '${history.overallMentalAge.toStringAsFixed(1)}月')),
                    Expanded(child: _buildHistoryItem('发育商', history.overallDQ.toStringAsFixed(1))),
                    Expanded(child: _buildHistoryItem('用时', history.durationText)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TestArea.values.map((area) {
                    final score = history.areaScores[area] ?? 0.0;
                    final dq = history.areaDQs[area] ?? 0.0;
                    final levelText = _getLevelText(dq);
                    final levelColor = _getLevelColor(dq);

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAreaColor(area).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getAreaColor(area).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getAreaName(area),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getAreaColor(area),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '智龄: ${score.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 8, color: _getAreaColor(area)),
                          ),
                          Text(
                            'DQ: ${dq.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: _getAreaColor(area),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: levelColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: levelColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              levelText,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: levelColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
        ),
      ],
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

  Color _getAreaColor(TestArea area) {
    switch (area) {
      case TestArea.motor:
        return Colors.green[600]!;
      case TestArea.fineMotor:
        return Colors.blue[600]!;
      case TestArea.language:
        return Colors.orange[600]!;
      case TestArea.adaptive:
        return Colors.purple[600]!;
      case TestArea.social:
        return Colors.red[600]!;
    }
  }

  String _getLevelText(double dq) {
    if (dq > 130) return '优秀';
    if (dq >= 110) return '良好';
    if (dq >= 80) return '中等';
    if (dq >= 70) return '偏低';
    return '障碍';
  }

  Color _getLevelColor(double dq) {
    if (dq > 130) return Colors.green[600]!;
    if (dq >= 110) return Colors.blue[600]!;
    if (dq >= 80) return Colors.orange[600]!;
    if (dq >= 70) return Colors.orange[700]!;
    return Colors.red[600]!;
  }
}

