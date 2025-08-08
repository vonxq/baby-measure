import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../models/assessment_history.dart' as history;
import 'assessment_guide_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedAge = 6; // 默认选中6月龄
  final TextEditingController _nameController = TextEditingController();
  late TabController _tabController;
  String _name = ''; // 添加姓名状态
  
  // 月龄选项列表
  final List<int> _ageOptions = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 21, 24, 27, 30, 33, 36, 42, 48, 54, 60, 66, 72, 78, 84
  ];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // 添加姓名控制器监听器
    _nameController.addListener(_onNameChanged);
    
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  // 姓名变化监听器
  void _onNameChanged() {
    setState(() {
      _name = _nameController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('儿童发育评估'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.assessment), text: '测评'),
            Tab(icon: Icon(Icons.history), text: '测评历史'),
            Tab(icon: Icon(Icons.info), text: '功能介绍'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAssessmentTab(),
            _buildHistoryTab(),
            _buildInfoTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue[600]),
                const SizedBox(height: 16),
                const Text('正在加载数据...', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(provider.error, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.loadData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 基本信息卡片
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '基本信息',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 姓名输入
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '宝宝姓名',
                          hintText: '请输入宝宝姓名',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.blue[600]),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 月龄选择
                      const Text(
                        '选择月龄',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.blue[600], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '当前选择：${_selectedAge}个月',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _selectedAge,
                              decoration: InputDecoration(
                                labelText: '月龄',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _ageOptions.map((int age) {
                                return DropdownMenuItem<int>(
                                  value: age,
                                  child: Text('${age}个月'),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedAge = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 开始测评按钮
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _name.isNotEmpty ? () => _startAssessment() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _name.isNotEmpty ? Colors.green[600] : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology),
                        const SizedBox(width: 8),
                        Text(
                          '开始测评',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // 提示信息
                if (_name.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[600], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '请输入宝宝姓名',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // 说明卡片
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[600]),
                          const SizedBox(width: 8),
                          Text(
                            '测试说明',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('• 请根据宝宝的实际情况选择月龄'),
                      const SizedBox(height: 4),
                      const Text('• 测试过程中请如实回答每个问题'),
                      const SizedBox(height: 4),
                      const Text('• 测试结果仅供参考，如有疑问请咨询专业医生'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        // 这里应该从provider获取真实的历史数据
        List<history.AssessmentHistory> historyList = [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 页面标题
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '测评历史',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              // 历史记录列表
              if (historyList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无测评记录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '完成一次测评后，记录将显示在这里',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...historyList.map((history) => _buildHistoryCard(history)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(history.AssessmentHistory historyData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头部信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[600],
                  child: Text(
                    historyData.babyName.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        historyData.babyName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        '${historyData.actualAge.toStringAsFixed(1)}个月',
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
                    color: historyData.overallDQColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    historyData.overallLevel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 时间信息 - 只显示开始时间
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    historyData.startTimeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 整体结果展示在上
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: historyData.overallDQColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: historyData.overallDQColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '整体结果',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: historyData.overallDQColor,
                        ),
                      ),
                      Text(
                        '智龄: ${historyData.overallMentalAge.toStringAsFixed(1)}个月 | DQ: ${historyData.overallDQ.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: historyData.overallDQColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 能区结果展示在下
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '各能区结果',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: history.TestArea.values.map((area) {
                    final score = historyData.areaScores[area] ?? 0.0;
                    final dq = historyData.areaDQs[area] ?? 0.0;
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
        ],
      ),
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
  String _getAreaName(history.TestArea area) {
    switch (area) {
      case history.TestArea.motor:
        return '大运动';
      case history.TestArea.fineMotor:
        return '精细动作';
      case history.TestArea.language:
        return '语言';
      case history.TestArea.adaptive:
        return '适应能力';
      case history.TestArea.social:
        return '社会行为';
    }
  }

  // 获取能区颜色
  Color _getAreaColor(history.TestArea area) {
    switch (area) {
      case history.TestArea.motor:
        return Colors.green[600]!;
      case history.TestArea.fineMotor:
        return Colors.blue[600]!;
      case history.TestArea.language:
        return Colors.orange[600]!;
      case history.TestArea.adaptive:
        return Colors.purple[600]!;
      case history.TestArea.social:
        return Colors.red[600]!;
    }
  }

  // 获取分段文本
  String _getLevelText(double dq) {
    if (dq > 130) return '优秀';
    if (dq >= 110) return '良好';
    if (dq >= 80) return '中等';
    if (dq >= 70) return '临界偏低';
    return '智力发育障碍';
  }

  // 获取分段颜色
  Color _getLevelColor(double dq) {
    if (dq > 130) return Colors.green[600]!;
    if (dq >= 110) return Colors.blue[600]!;
    if (dq >= 80) return Colors.orange[600]!;
    if (dq >= 70) return Colors.orange[700]!;
    return Colors.red[600]!;
  }
} 