import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import 'result_page.dart';
import 'area_result_page.dart';

class DynamicTestPage extends StatefulWidget {
  const DynamicTestPage({super.key});

  @override
  State<DynamicTestPage> createState() => _DynamicTestPageState();
}

class _DynamicTestPageState extends State<DynamicTestPage> with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  String? _progressChangeMessage;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 确保动画控制器在依赖变化时重新启动
    if (_cardController.status == AnimationStatus.completed) {
      _cardController.reset();
      _cardController.forward();
    }
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

              // 检查是否需要显示能区结果页
              if (provider.currentStage == TestStage.areaCompleted) {
                return _buildAreaResultPage(provider);
              }

              // 检查是否需要显示最终结果页
              if (provider.currentStage == TestStage.allCompleted) {
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
                // 添加调试信息
                print('UI: currentItem is null');
                print('UI: currentStageItems.length = ${provider.currentStageItems.length}');
                print('UI: currentStageItemIndex = ${provider.currentStageItemIndex}');
                print('UI: currentStage = ${provider.currentStage}');
                print('UI: currentArea = ${provider.currentArea}');
                
                // 当前阶段完成，显示能区结果页
                return _buildAreaResultPage(provider);
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
                                _getCurrentAreaName(provider.currentArea),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showExitDialog(context),
                          icon: const Icon(Icons.exit_to_app),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                          // 进度条和提示信息
                          _buildProgressSection(provider),
                          const SizedBox(height: 16),

                          // 题目卡片
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _cardAnimation,
                              builder: (context, child) {
                                // 添加调试信息
                                print('UI Builder: currentItem = ${provider.currentItem?.name}');
                                print('UI Builder: currentItem is null = ${provider.currentItem == null}');
                                
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
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    provider.currentItem?.name ?? '题目加载中...',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: Colors.orange[300]!),
                                                  ),
                                                  child: Text(
                                                    '${(provider.currentItem?.score ?? 0.0).toStringAsFixed(1)}分',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.orange[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // 题目描述
                                          if (provider.currentItem?.desc.isNotEmpty == true) ...[
                                            Row(
                                              children: [
                                                Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '题目描述：',
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
                                                provider.currentItem?.desc ?? '',
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
                                              provider.currentItem?.operation ?? '',
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
                                              provider.currentItem?.passCondition ?? '',
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
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
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

  Widget _buildProgressSection(AssessmentProvider provider) {
    int testedCount = provider.getCurrentAreaTestedCount();
    int totalCount = provider.getCurrentAreaTotalCount();
    int currentAge = provider.getCurrentAreaAge();

    return Column(
      children: [
        // 进度条
        Container(
          padding: const EdgeInsets.all(16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getCurrentAreaName(provider.currentArea)}测试进度',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '当前测试月龄：$currentAge个月',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$testedCount / $totalCount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalCount > 0 ? testedCount / totalCount : 0.0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                minHeight: 8,
              ),
            ],
          ),
        ),
        
        // 进度变化提示
        if (_progressChangeMessage != null) ...[
          const SizedBox(height: 8),
          Container(
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
                    _progressChangeMessage!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAreaResultPage(AssessmentProvider provider) {
    // 获取当前能区的智龄和发育商
    double mentalAge = provider.getCurrentAreaMentalAge();
    double developmentQuotient = provider.getCurrentAreaDevelopmentQuotient();
    
    return AreaResultPage(
      area: provider.currentArea,
      mentalAge: mentalAge,
      developmentQuotient: developmentQuotient,
      onContinue: () {
        // 继续下一个能区
        provider.nextItem();
      },
    );
  }

  void _handleAnswer(bool passed, AssessmentProvider provider) {
    if (provider.currentItem == null) {
      print('警告：_handleAnswer中currentItem为null');
      return;
    }
    
    provider.recordResult(provider.currentItem!.id, passed);
    
    if (provider.currentStageItemIndex < provider.currentStageItems.length - 1) {
      _cardController.reset();
      provider.nextItem();
      _cardController.forward();
    } else {
      // 当前阶段完成，检查是否需要进入下一阶段
      _cardController.reset();
      provider.nextItem(); // 这会触发阶段切换
      
      // 如果阶段已经切换到能区完成状态，显示能区结果页
      if (provider.currentStage == TestStage.areaCompleted) {
        // 显示能区结果页
        setState(() {});
      } else if (provider.currentStage == TestStage.allCompleted) {
        // 跳转到最终结果页面
        try {
          if (mounted) {
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
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('计算结果失败: $e'),
                backgroundColor: Colors.red[600],
              ),
            );
          }
        }
      } else {
        // 如果切换到新阶段，显示过渡页
        _cardController.forward();
        
        // 显示进度变化提示
        _showProgressChangeMessage(provider);
      }
    }
  }

  void _showProgressChangeMessage(AssessmentProvider provider) {
    String message = '';
    
    switch (provider.currentStage) {
      case TestStage.forward:
        message = '由于需要向前测查，增加了测试项目数量';
        break;
      case TestStage.backward:
        message = '由于需要向后测查，增加了测试项目数量';
        break;
      default:
        return;
    }
    
    setState(() {
      _progressChangeMessage = message;
    });
    
    // 3秒后清除提示
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _progressChangeMessage = null;
        });
      }
    });
  }

  String _getCurrentAreaName(TestArea area) {
    switch (area) {
      case TestArea.motor:
        return '大运动能区';
      case TestArea.fineMotor:
        return '精细动作能区';
      case TestArea.language:
        return '语言能区';
      case TestArea.adaptive:
        return '适应能力能区';
      case TestArea.social:
        return '社会行为能区';
    }
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('确认退出'),
            ),
          ],
        );
      },
    );
  }
} 