import 'package:flutter/material.dart';
import '../utils/dq_utils.dart';

/// 能区分数卡片组件
/// 
/// 用于显示各个能区的分数信息，支持自定义标题、分数等
/// 根据分数范围自动调整卡片颜色
class AreaScoreCard extends StatelessWidget {
  final String title; // 能区名称，如"大运动"、"精细动作"等
  final double? score; // 智龄分数，可以为null
  final double? dq; // 发育商，可以为null
  final String? unit; // 分数单位，如"月"、"分"等
  final bool showDQ; // 是否显示发育商
  final double? width; // 卡片宽度，为null时自动适应
  final EdgeInsets? margin; // 外边距
  final VoidCallback? onTap; // 点击回调

  const AreaScoreCard({
    super.key,
    required this.title,
    this.score,
    this.dq,
    this.unit,
    this.showDQ = true,
    this.width,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();
    final textColor = _getTextColor();
    final hasScore = score != null;

    Widget cardContent = Container(
      width: width,
      margin: margin ?? const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 能区名称
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          if (hasScore) ...[
            // 智龄分数
            Text(
              '智龄: ${score!.toStringAsFixed(1)}${unit ?? ''}',
              style: TextStyle(
                fontSize: 8,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (showDQ && dq != null) ...[
              const SizedBox(height: 1),
              // 发育商
              Text(
                'DQ: ${dq!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 2),
              
              // 等级标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                   color: _getLevelColor(dq!).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getLevelColor(dq!).withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _getLevelText(dq!),
                  style: TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(dq!),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ] else ...[
            // 没有分数时的占位内容
            Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// 获取卡片主色调
  Color _getCardColor() {
    if (score == null && dq == null) {
      return Colors.grey[400]!; // 无数据时显示灰色
    }

    // 如果有DQ，使用DQ的颜色；否则使用固定颜色
    if (dq != null) {
      return _getLevelColor(dq!);
    }

    // 根据能区名称返回默认颜色
    return _getAreaDefaultColor();
  }

  /// 获取文字颜色
  Color _getTextColor() {
    final cardColor = _getCardColor();
    return cardColor.withOpacity(0.8);
  }

  /// 根据DQ获取等级颜色
  Color _getLevelColor(double dq) => DqUtils.colorByDq(dq);

  /// 根据DQ获取等级文本
  String _getLevelText(double dq) => DqUtils.labelByDq(dq);

  /// 根据能区名称获取默认颜色
  Color _getAreaDefaultColor() {
    switch (title) {
      case '大运动':
        return Colors.green[600]!;
      case '精细动作':
        return Colors.blue[600]!;
      case '语言':
        return Colors.orange[600]!;
      case '适应能力':
        return Colors.purple[600]!;
      case '社会行为':
        return Colors.red[600]!;
      default:
        return Colors.blue[600]!;
    }
  }
}

/// 扩展的能区分数卡片，专门用于历史记录等场景
class AreaScoreCardExpanded extends StatelessWidget {
  final String title;
  final double? score;
  final double? dq;
  final VoidCallback? onTap;

  const AreaScoreCardExpanded({
    super.key,
    required this.title,
    this.score,
    this.dq,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AreaScoreCard(
        title: title,
        score: score,
        dq: dq,
        unit: '',
        showDQ: true,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        onTap: onTap,
      ),
    );
  }
}