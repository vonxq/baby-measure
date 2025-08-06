import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import 'result_page.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _progressAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
    _cardController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
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
                      const Text('正在准备测试...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }

              if (provider.currentItem == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text('测试完成！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacement(
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
                        ),
                        icon: const Icon(Icons.assessment),
                        label: const Text('查看结果'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 顶部进度区域
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '测试进度',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                '${provider.currentItemIndex + 1} / ${provider.currentTestItems.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: provider.progress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                                minHeight: 8,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(provider.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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
                                    // 题目编号和分区信息
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _getQuestionLabel(provider),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getAreaColor(provider.currentItem!.id, provider),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getAreaName(provider.currentItem!.id, provider),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // 题目名称
                                    Text(
                                      provider.currentItem!.name,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // 题目描述
                                    _buildInfoSection('描述', provider.currentItem!.desc),
                                    const SizedBox(height: 16),

                                    // 操作说明
                                    _buildInfoSection('操作说明', provider.currentItem!.operation),
                                    const SizedBox(height: 16),

                                    // 通过要求
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
                                              Icon(Icons.check_circle, color: Colors.blue[600], size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                '通过标准',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            provider.currentItem!.passCondition,
                                            style: TextStyle(color: Colors.blue[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 操作按钮
                    Row(
                      children: [
                        // 上一题按钮
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: provider.currentItemIndex > 0 ? () {
                              _cardController.reset();
                              provider.previousItem();
                              _cardController.forward();
                            } : null,
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
                        // 通过按钮
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAnswer(true, provider),
                            icon: const Icon(Icons.check),
                            label: const Text('通过'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 不通过按钮
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAnswer(false, provider),
                            icon: const Icon(Icons.close),
                            label: const Text('不通过'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
      ],
    );
  }

  // 获取题目标签
  String _getQuestionLabel(AssessmentProvider provider) {
    final currentIndex = provider.currentItemIndex + 1;
    final totalCount = provider.currentTestItems.length;
    final itemId = provider.currentItem!.id;
    final monthAge = (itemId / 100).floor();
    return '${monthAge}月龄 $currentIndex/$totalCount';
  }

  // 获取分区名称
  String _getAreaName(int itemId, AssessmentProvider provider) {
    final area = provider.getItemArea(itemId);
    switch (area) {
      case 'motor': return '大运动';
      case 'fineMotor': return '精细动作';
      case 'language': return '语言';
      case 'adaptive': return '适应能力';
      case 'social': return '社会行为';
      default: return '未知';
    }
  }

  // 获取分区颜色
  Color _getAreaColor(int itemId, AssessmentProvider provider) {
    final area = provider.getItemArea(itemId);
    switch (area) {
      case 'motor': return Colors.green[600]!;
      case 'fineMotor': return Colors.blue[600]!;
      case 'language': return Colors.orange[600]!;
      case 'adaptive': return Colors.purple[600]!;
      case 'social': return Colors.red[600]!;
      default: return Colors.grey[600]!;
    }
  }

  void _handleAnswer(bool passed, AssessmentProvider provider) async {
    provider.recordResult(provider.currentItem!.id, passed);
    
    if (provider.currentItemIndex < provider.currentTestItems.length - 1) {
      _cardController.reset();
      provider.nextItem();
      _cardController.forward();
    } else {
      // 测试完成，计算结果
      try {
        await provider.completeTest();
        // 跳转到结果页面
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
      } catch (e) {
        // 显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('计算结果失败: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
} 