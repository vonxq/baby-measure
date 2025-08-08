import 'package:flutter/material.dart';
// import '../providers/assessment_provider.dart';
import '../models/assessment_history.dart';
import '../services/data_service.dart';
import 'assessment_guide_page.dart';
import 'tabs/start_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/info_tab.dart';

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
    _tabController.addListener(_onTabChanged);
    _loadHistories();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) { // 历史 Tab
      _loadHistories();
    }
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

  Future<void> _deleteHistory(String historyId) async {
    try {
      await DataService().deleteAssessmentHistory(historyId);
      // 重新加载历史记录
      await _loadHistories();
      
      // 显示删除成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('测评记录已删除'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('删除失败，请重试'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
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

              // 标签栏 - iOS风格分段控制样式
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.symmetric(vertical: 10),
                    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    labelColor: Colors.blue[700],
                    unselectedLabelColor: Colors.grey[700],
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                  ),
                  tabs: const [
                    Tab(
                        iconMargin: EdgeInsets.only(bottom: 4),
                        icon: Icon(Icons.play_circle_outline, size: 18),
                      text: '开始测试',
                    ),
                    Tab(
                        iconMargin: EdgeInsets.only(bottom: 4),
                        icon: Icon(Icons.history, size: 18),
                      text: '测评历史',
                    ),
                    Tab(
                        iconMargin: EdgeInsets.only(bottom: 4),
                        icon: Icon(Icons.info_outline, size: 18),
                      text: '功能介绍',
                    ),
                  ],
                  ),
                ),
              ),

              // 标签页内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(), // 禁用滑动切换tab
                  children: [
                    StartTab(
                      nameController: _nameController,
                      name: _name,
                      selectedAge: _selectedAge,
                      onNameChanged: (value) => setState(() => _name = value),
                      onAgeChanged: (value) => setState(() => _selectedAge = value),
                      onStart: _startAssessment,
                    ),
                    HistoryTab(
                      isLoading: _isLoading,
                      histories: _histories,
                      onDeleteHistory: _deleteHistory,
                    ),
                    const InfoTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
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

} 