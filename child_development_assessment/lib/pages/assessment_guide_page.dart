import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import 'dynamic_test_page.dart';

class AssessmentGuidePage extends StatelessWidget {
  final String babyName;
  final int selectedAge;

  const AssessmentGuidePage({
    super.key,
    required this.babyName,
    required this.selectedAge,
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
              // 可滚动的内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 时间预估卡片
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
                                Icon(Icons.access_time, color: Colors.orange[600], size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  '预计时间',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.timer, color: Colors.orange[600], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '约3-10分钟',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '根据宝宝配合程度，测评时间可能有所变化',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 注意事项卡片
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
                                Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  '注意事项',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildNoticeItem(
                              icon: Icons.child_care,
                              title: '环境要求',
                              content: '请确保测评环境安静、光线明亮，避免干扰',
                              color: Colors.green[600]!,
                            ),
                            const SizedBox(height: 12),
                            _buildNoticeItem(
                              icon: Icons.family_restroom,
                              title: '家长陪伴',
                              content: '如在医院，4岁以下儿童允许一位家长陪伴，4岁及以上如有需要也可陪伴',
                              color: Colors.blue[600]!,
                            ),
                            const SizedBox(height: 12),
                            _buildNoticeItem(
                              icon: Icons.psychology,
                              title: '如实回答',
                              content: '请根据宝宝的实际表现如实回答每个问题，不要猜测或夸大',
                              color: Colors.orange[600]!,
                            ),
                            // const SizedBox(height: 12),
                            // _buildSpecialNoteItem(
                            //   icon: Icons.psychology,
                            //   title: '特殊标注',
                            //   line1: '注 1：标注 R 的测查项目表示该项目的表现可以通过询问家长获得。',
                            //   line2: '注 2：标注 * 的测查项目表示该项目如果未通过需要引起注意。',
                            //   color: Colors.purple[600]!,
                            // ),
                             const SizedBox(height: 12),
                             // 量表说明（注1-注5）
                             Container(
                               decoration: BoxDecoration(
                                 color: Colors.purple[50],
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.purple[100]!),
                               ),
                               child: Theme(
                                 data: Theme.of(context).copyWith(
                                   dividerColor: Colors.transparent,
                                   splashColor: Colors.transparent,
                                   highlightColor: Colors.transparent,
                                 ),
                                 child: ExpansionTile(
                                   tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                   childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                   leading: Icon(Icons.menu_book, color: Colors.purple[600], size: 20),
                                   title: Text(
                                     '量表说明（注）',
                                     style: TextStyle(
                                       fontSize: 14,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.purple[700],
                                     ),
                                   ),
                                   children: [
                                     _buildBulletLine('注 1：标注 R 的测查项目表示该项目的表现可以通过询问家长获得。'),
                                     _buildBulletLine('注 2：标注 * 的测查项目表示该项目如果未通过需要引起注意。'),
                                     _buildBulletLine('注 3：测查床规格：长 140cm，宽 77cm，高 143cm，栏高 63cm。'),
                                     _buildBulletLine('注 4：测查用桌子规格：长 120cm，宽 60cm，高 75cm，桌面颜色深绿。'),
                                     _buildBulletLine('注 5：测查用楼梯规格：上平台长 50×宽 60×高 50cm，底座全梯长 150cm（单梯 75cm），每级台阶 60×25×高 17cm，共 3 级；单侧扶栏长 90cm，直径 2.5cm，从梯面计算扶栏高 40cm。'),
                                   ],
                                 ),
                               ),
                             ),
                            const SizedBox(height: 12),
                            _buildNoticeItem(
                              icon: Icons.medical_services,
                              title: '结果参考',
                              content: '测评结果仅供参考，如有疑问请咨询专业医生',
                              color: Colors.red[600]!,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // 固定在底部的按钮区域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // 开始测评按钮
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _startAssessment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(
                              '开始测评',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 返回按钮
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('返回修改'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialNoteItem({
    required IconData icon,
    required String title,
    required String line1,
    required String line2,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  line1,
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
                const SizedBox(height: 4),
                Text(
                  line2,
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 6),
            child: Icon(Icons.circle, size: 5, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _startAssessment(BuildContext context) async {
    // 设置用户信息并开始测评
    await context.read<AssessmentProvider>().startDynamicAssessment(babyName, selectedAge.toDouble());
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DynamicTestPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
} 