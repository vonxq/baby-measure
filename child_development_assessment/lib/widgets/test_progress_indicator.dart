import 'package:flutter/material.dart';
import '../models/assessment_item.dart';
import '../providers/assessment_provider.dart';

class TestProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  final AssessmentItem? currentItem;
  final Map<String, int> areaProgress;
  final TestStage? currentStage;

  const TestProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalItems,
    this.currentItem,
    required this.areaProgress,
    this.currentStage,
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
                      '当前测试：${_getAreaName(_getAreaFromId(currentItem!.id))} - ${(currentItem!.id / 100).floor()}月龄',
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
          
          // 各能区项目数量
          Text(
            '本阶段各能区项目',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          
          // 能区项目数量
          ...areaProgress.entries.map((entry) => _buildAreaItemCount(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildAreaItemCount(String area, int count) {
    if (count == 0) return const SizedBox.shrink();
    
    Color areaColor = _getAreaColor(area);
    String areaName = _getAreaName(area);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: areaColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: areaColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: areaColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              areaName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: areaColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count题',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
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

  String _getAreaFromId(int itemId) {
    int monthAge = (itemId / 100).floor();
    int itemIndex = itemId % 100;
    
    if (monthAge <= 12) {
      if (itemIndex <= 2) return 'motor';
      if (itemIndex <= 4) return 'fineMotor';
      if (itemIndex <= 6) return 'adaptive';
      if (itemIndex <= 8) return 'language';
      return 'social';
    } else {
      if (itemIndex <= 1) return 'motor';
      if (itemIndex <= 2) return 'fineMotor';
      if (itemIndex <= 3) return 'adaptive';
      if (itemIndex <= 4) return 'language';
      return 'social';
    }
  }
} 
} 