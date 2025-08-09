import 'package:flutter/material.dart';
import '../../models/assessment_history.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/area_score_card.dart';
import '../answer_record_page.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.isLoading,
    required this.histories,
    this.onDeleteHistory,
  });

  final bool isLoading;
  final List<AssessmentHistory> histories;
  final Function(String historyId)? onDeleteHistory;

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
        return Dismissible(
          key: Key(history.id),
          direction: DismissDirection.endToStart,
          dismissThresholds: const {DismissDirection.endToStart: 0.4}, // 需要滑动40%才触发删除
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '删除',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('确认删除'),
                  content: Text('确认删除${history.babyName}的${history.actualAge.round()}月龄测评记录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('删除'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            if (onDeleteHistory != null) {
              onDeleteHistory!(history.id);
            }
          },
          child: Container(
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
                            '${history.actualAge.round()}月龄 | ${history.startTimeText}',
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
                Row(
                  children: TestArea.values.map((area) {
                    final score = history.areaScores[area] ?? 0.0;
                    final dq = history.areaDQs[area] ?? 0.0;

                    return AreaScoreCardExpanded(
                      title: _getAreaName(area),
                      score: score,
                      dq: dq,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnswerRecordPage(historyId: history.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('查看测评记录'),
                  ),
                ),
              ],
            ),
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
}

