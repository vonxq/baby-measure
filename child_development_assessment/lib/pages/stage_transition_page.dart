import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import 'dynamic_test_page.dart';

class StageTransitionPage extends StatefulWidget {
  const StageTransitionPage({super.key});

  @override
  State<StageTransitionPage> createState() => _StageTransitionPageState();
}

class _StageTransitionPageState extends State<StageTransitionPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
    
            // 3秒后自动跳转到测试页面
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
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
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 阶段图标
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _getStageColor(provider.currentStage),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getStageColor(provider.currentStage).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getStageIcon(provider.currentStage),
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // 阶段标题
                          Text(
                            provider.currentStageDescription,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _getStageColor(provider.currentStage),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // 阶段描述
                          Text(
                            provider.currentStageDescription,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          

                          const SizedBox(height: 32),
                          
                          // 进度指示器
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: provider.currentStage == TestStage.current 
                                      ? _getStageColor(TestStage.current)
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 2,
                                color: provider.currentStage.index > TestStage.current.index 
                                    ? _getStageColor(TestStage.current)
                                    : Colors.grey[300],
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: provider.currentStage == TestStage.forward 
                                      ? _getStageColor(TestStage.forward)
                                      : (provider.currentStage.index > TestStage.forward.index 
                                          ? _getStageColor(TestStage.forward)
                                          : Colors.grey[300]),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 2,
                                color: provider.currentStage.index > TestStage.forward.index 
                                    ? _getStageColor(TestStage.forward)
                                    : Colors.grey[300],
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: provider.currentStage == TestStage.backward 
                                      ? _getStageColor(TestStage.backward)
                                      : (provider.currentStage.index > TestStage.backward.index 
                                          ? _getStageColor(TestStage.backward)
                                          : Colors.grey[300]),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // 提示文字
                          Text(
                            '即将开始测试...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getStageIcon(TestStage stage) {
    switch (stage) {
      case TestStage.current:
        return Icons.assessment;
      case TestStage.forward:
        return Icons.arrow_back;
      case TestStage.backward:
        return Icons.arrow_forward;
      case TestStage.areaCompleted:
        return Icons.check_circle;
      case TestStage.allCompleted:
        return Icons.check_circle;
    }
  }

  Color _getStageColor(TestStage stage) {
    switch (stage) {
      case TestStage.current:
        return Colors.blue[600]!;
      case TestStage.forward:
        return Colors.orange[600]!;
      case TestStage.backward:
        return Colors.purple[600]!;
      case TestStage.areaCompleted:
        return Colors.green[600]!;
      case TestStage.allCompleted:
        return Colors.green[600]!;
    }
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
} 