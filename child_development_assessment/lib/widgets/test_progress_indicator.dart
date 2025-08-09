import 'package:flutter/material.dart';
import '../models/assessment_item.dart';
import '../providers/assessment_provider.dart';
import '../utils/dq_utils.dart';

class TestProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  final AssessmentItem? currentItem;
  final Map<TestArea, bool> areaProgress;
  final TestStage? currentStage;
  final AssessmentProvider? provider;

  const TestProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalItems,
    this.currentItem,
    required this.areaProgress,
    this.currentStage,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总体进度
          Row(
            children: [
              Icon(Icons.assessment, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                '测试进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              Text(
                '$currentIndex / $totalItems',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 进度条
          LinearProgressIndicator(
            value: totalItems > 0 ? currentIndex / totalItems : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          
          // 当前测试项目信息
          if (currentItem != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz, color: Colors.blue[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '当前测试：${provider?.currentStageDescription ?? "未知"}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // 各能区完成状态
          Text(
            '各能区测试状态',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          
          // 能区完成状态 - 一行显示
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: areaProgress.entries
                .map((entry) => _buildAreaStatusChip(entry.key, entry.value))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaStatusChip(TestArea area, bool completed) {
    Color areaColor = _getAreaColor(area.toString());
    String areaName = _getAreaName(area.toString());
    
    // 获取能区的分数（智龄）并换算DQ用于配色
    double? areaScore = provider?.areaScores[area];
    double? dq;
    if (areaScore != null) {
      final actualAge = provider?.actualAge ?? 0;
      if (actualAge > 0) {
        dq = (areaScore / actualAge) * 100;
      }
    }
    String levelText = _getLevelText(dq);
    Color levelColor = _getLevelColor(dq);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (dq != null)
            ? levelColor.withValues(alpha: 0.12)
            : (completed ? Colors.green[50] : Colors.orange[50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (dq != null)
              ? levelColor.withValues(alpha: 0.4)
              : (completed ? Colors.green[300]! : Colors.orange[300]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.pending,
                size: 16,
                color: (dq != null)
                    ? levelColor
                    : (completed ? Colors.green[600] : Colors.orange[600]),
              ),
              const SizedBox(width: 6),
              Text(
                areaName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: (dq != null)
                      ? levelColor
                      : (completed ? Colors.green[700] : Colors.orange[700]),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (dq != null)
                      ? levelColor
                      : (completed ? Colors.green[600] : Colors.orange[600]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  completed ? '完成' : '进行中',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // 添加分数分段信息（直接显示紧凑等级与DQ数值）
          if (dq != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              ),
              child: Text(
                '${DqUtils.compactLabelByDq(dq!)}·${dq!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getAreaName(String area) {
    switch (area) {
      case 'motor':
        return '大运动';
      case 'fineMotor':
        return '精细动作';
      case 'language':
        return '语言';
      case 'adaptive':
        return '适应能力';
      case 'social':
        return '社会行为';
      default:
        return '未知';
    }
  }

  Color _getAreaColor(String area) {
    switch (area) {
      case 'motor':
        return Colors.green[600]!;
      case 'fineMotor':
        return Colors.blue[600]!;
      case 'language':
        return Colors.orange[600]!;
      case 'adaptive':
        return Colors.purple[600]!;
      case 'social':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  // 获取分段文本
  String _getLevelText(double? score) {
    if (score == null) return '';
    return DqUtils.labelByDq(score);
  }

  // 获取分段颜色
  Color _getLevelColor(double? score) {
    if (score == null) return Colors.grey[600]!;
    return DqUtils.colorByDq(score);
  }
}