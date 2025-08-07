import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../widgets/test_progress_indicator.dart';
import 'result_page.dart';
import 'stage_transition_page.dart';

class DynamicTestPage extends StatefulWidget {
  const DynamicTestPage({super.key});

  @override
  State<DynamicTestPage> createState() => _DynamicTestPageState();
}

class _DynamicTestPageState extends State<DynamicTestPage> with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
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
          child: Consumer<AssessmentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue[600]),
                      const SizedBox(height: 16),
                      const Text('正在准备动态测评...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }

              // 检查是否需要显示过渡页
              if (provider.currentStage == TestStage.completed) {
                // 直接跳转到结果页
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ResultPage(),
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
                });
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text('动态测评完成！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('正在生成结果...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }

              if (provider.currentItem == null) {
                // 当前阶段完成，显示过渡页
                return const StageTransitionPage();
              }

              return Column(
                children: [
                  // 顶部导航栏
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _showExitDialog(context),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '动态发育评估',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.currentStageDescription,
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
                  
                  // 主要内容
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 动态测评进度指示器
                          TestProgressIndicator(
                            currentIndex: provider.currentStageItemIndex + 1,
                            totalItems: provider.currentStageItems.length,
                            currentItem: provider.currentItem,
                            areaProgress: provider.areaCompleted,
                            provider: provider,
                          ),
                          const SizedBox(height: 16),

                          // 题目卡片
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _cardAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _cardAnimation.value,
                                  child: Container(
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
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 题目标题
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.blue[200]!),
                                            ),
                                            child: Text(
                                              provider.currentItem!.name,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // 题目描述
                                          if (provider.currentItem!.desc.isNotEmpty) ...[
                                            Row(
                                              children: [
                                                Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '描述：',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.orange[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[50],
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.orange[200]!),
                                              ),
                                              child: Text(
                                                provider.currentItem!.desc,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.orange[800],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                          
                                          // 操作方法
                                          Row(
                                            children: [
                                              Icon(Icons.play_circle_outline, color: Colors.purple[600], size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                '操作方法：',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.purple[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.purple[50],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.purple[200]!),
                                            ),
                                            child: Text(
                                              provider.currentItem!.operation,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.purple[800],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // 通过标准
                                          Row(
                                            children: [
                                              Icon(Icons.flag, color: Colors.teal[600], size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                '通过标准：',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.teal[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.teal[50],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.teal[200]!),
                                            ),
                                            child: Text(
                                              provider.currentItem!.passCondition,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.teal[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 操作按钮
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: provider.currentStageItemIndex > 0
                                      ? () {
                                          provider.previousItem();
                                          _cardController.reset();
                                          _cardController.forward();
                                        }
                                      : null,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('上一题'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    provider.recordResult(provider.currentItem!.id, true);
                                    provider.nextItem();
                                    _cardController.reset();
                                    _cardController.forward();
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('通过'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    provider.recordResult(provider.currentItem!.id, false);
                                    provider.nextItem();
                                    _cardController.reset();
                                    _cardController.forward();
                                  },
                                  icon: const Icon(Icons.close),
                                  label: const Text('不通过'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('确定要退出测试吗？当前进度将不会保存。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('退出'),
            ),
          ],
        );
      },
    );
  }
} 