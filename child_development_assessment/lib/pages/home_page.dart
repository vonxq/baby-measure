import 'package:flutter/material.dart';
import '../providers/assessment_provider.dart';
import '../models/assessment_history.dart';
import '../services/data_service.dart';
import 'assessment_guide_page.dart';
import 'score_explanation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  String _name = '';
  int _selectedAge = 12;
  List<AssessmentHistory> _histories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadHistories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final histories = await DataService().loadAssessmentHistories();
      setState(() {
        _histories = histories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
          child: Column(
            children: [
              // 顶部标题栏
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.child_care,
                        size: 32,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '儿童发育评估',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          Text(
                            '基于儿心量表-Ⅱ的专业评估工具',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 标签栏
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue[600],
                  unselectedLabelColor: Colors.grey[600],
                  indicator: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.play_circle_outline),
                      text: '开始测试',
                    ),
                    Tab(
                      icon: Icon(Icons.history),
                      text: '测评历史',
                    ),
                    Tab(
                      icon: Icon(Icons.info_outline),
                      text: '功能介绍',
                    ),
                  ],
                ),
              ),

              // 标签页内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStartTab(),
                    _buildHistoryTab(),
                    _buildInfoTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 欢迎卡片
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
                    Icons.child_care,
                    size: 48,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '欢迎使用儿童发育评估',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请输入宝宝信息开始测评',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 宝宝姓名输入
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
                    Icon(Icons.person, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '宝宝姓名',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '请输入宝宝姓名',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 月龄选择
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
                    Icon(Icons.cake, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '宝宝月龄',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedAge,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(73, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('${index}个月'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedAge = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 开始测试按钮
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _startAssessment,
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                '开始测评',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无测评历史',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '完成测评后，历史记录将显示在这里',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _histories.length,
      itemBuilder: (context, index) {
        final history = _histories[index];
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: history.overallDQColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: history.overallDQColor.withValues(alpha: 0.3),
                        ),
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
                    Expanded(
                      child: _buildHistoryItem('智龄', '${history.overallMentalAge.toStringAsFixed(1)}月'),
                    ),
                    Expanded(
                      child: _buildHistoryItem('发育商', history.overallDQ.toStringAsFixed(1)),
                    ),
                    Expanded(
                      child: _buildHistoryItem('用时', history.durationText),
                    ),
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
                            style: TextStyle(
                              fontSize: 8,
                              color: _getAreaColor(area),
                            ),
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

  Widget _buildInfoTab() {
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
                  '本应用基于0-6岁儿童发育行为评估量表（儿心量表-Ⅱ），为家长提供专业的儿童发育评估工具。通过科学的测评方法，帮助了解儿童在五大能区的发展情况。',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '计算公式：发育商 = (智龄 ÷ 实际年龄) × 100',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
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
              children: [
                Row(
                  children: [
                    Icon(Icons.assessment, color: Colors.blue[600], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '五大能区',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAreaItem('大运动', Colors.green[600]!, '身体的姿势、头的平衡，以及坐、爬、立、走、跑、跳的能力'),
                _buildAreaItem('精细动作', Colors.blue[600]!, '使用手指的能力'),
                _buildAreaItem('语言', Colors.orange[600]!, '理解语言和语言的表达能力'),
                _buildAreaItem('适应能力', Colors.purple[600]!, '儿童对其周围自然环境和社会需要作出反应和适应的能力'),
                _buildAreaItem('社会行为', Colors.red[600]!, '对周围人们的交往能力和生活自理能力'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaItem(String title, Color color, String description) {
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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

  void _startAssessment() {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('请输入宝宝姓名'),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AssessmentGuidePage(
          babyName: _name,
          selectedAge: _selectedAge,
        ),
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

  // 获取能区名称
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

  // 获取能区颜色
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

  // 获取分段文本
  String _getLevelText(double dq) {
    if (dq > 130) return '优秀';
    if (dq >= 110) return '良好';
    if (dq >= 80) return '中等';
    if (dq >= 70) return '偏低';
    return '障碍';
  }

  // 获取分段颜色
  Color _getLevelColor(double dq) {
    if (dq > 130) return Colors.green[600]!;
    if (dq >= 110) return Colors.blue[600]!;
    if (dq >= 80) return Colors.orange[600]!;
    if (dq >= 70) return Colors.orange[700]!;
    return Colors.red[600]!;
  }

  Widget _buildHistoryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }
} 