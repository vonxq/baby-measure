import 'package:flutter/material.dart';
import '../../utils/dq_utils.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 应用介绍卡片
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.apps, color: Colors.blue[600], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '应用功能',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '本应用基于《0-6岁儿童发育行为评估量表》（儿心量表-Ⅱ），为家长提供专业的儿童发育评估工具。通过科学的测评方法，帮助了解儿童在五大能区的发展情况。',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 智龄说明卡片
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timeline, color: Colors.green[600], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '什么是智龄？',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '智龄（Mental Age）是指儿童在某个特定年龄阶段应该达到的认知发展水平。它反映了儿童在各项能力上的发展程度，是衡量儿童发育水平的重要指标。',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '智龄通过标准化测试得出，表示儿童当前的认知能力相当于正常儿童几岁时的水平。例如，一个2岁儿童的智龄为2.5岁，说明其认知发展水平高于同龄儿童。',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 发育商说明卡片
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.blue[600], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '什么是发育商？',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '发育商（DQ）是用来衡量儿童心智发展水平的核心指标，反映儿童在大运动、精细动作、语言、适应能力和社会行为等方面的发展情况。',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '计算公式：',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '发育商 = (智龄 ÷ 实际年龄) × 100',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '例如：2岁儿童智龄为2.5岁，发育商 = (2.5 ÷ 2) × 100 = 125',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('发育商评级标准：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                _buildRatingItem('优秀', '≥130', DqUtils.colorExcellent),
                _buildRatingItem('良好', '110～129', DqUtils.colorGood),
                _buildRatingItem('中等', '80～109', DqUtils.colorMedium),
                _buildRatingItem('临界偏低', '70～79', DqUtils.colorBorderlineLow),
                _buildRatingItem('智力发育障碍', '＜70', DqUtils.colorImpaired),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 各能区说明卡片
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _AreaItem(title: '大运动', color: Colors.green, description: '身体的姿势、头的平衡，以及坐、爬、立、走、跑、跳的能力'),
                _AreaItem(title: '精细动作', color: Colors.blue, description: '使用手指的能力'),
                _AreaItem(title: '语言', color: Colors.orange, description: '理解语言和语言的表达能力'),
                _AreaItem(title: '适应能力', color: Colors.purple, description: '儿童对其周围自然环境和社会需要作出反应和适应的能力'),
                _AreaItem(title: '社会行为', color: Colors.red, description: '对周围人们的交往能力和生活自理能力'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 版权声明卡片
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[600], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '版权声明',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '本应用基于中华人民共和国国家卫生行业标准WS/T 580—2017《0岁～6岁儿童发育行为评估量表》。该量表由首都儿科研究所等单位起草，经国家卫生和计划生育委员会发布。',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRatingItem(String level, String range, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            level,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            range,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaItem extends StatelessWidget {
  const _AreaItem({
    required this.title,
    required this.color,
    required this.description,
  });

  final String title;
  final Color color;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

