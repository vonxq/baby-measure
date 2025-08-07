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
    if (_cardController.status == AnimationStatus.completed || _cardController.status == AnimationStatus.dismissed) {
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

              if (provider.currentStage == TestStage.areaCompleted) {
                return _buildAreaResultPage(provider);
              }

              if (provider.currentStage == TestStage.allCompleted) {
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue[600]),
                      const SizedBox(height: 16),
                      const Text('正在加载题目...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
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
                  
                  // 紧凑的进度区域
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        // 整体能区进度
                        _buildCompactOverallProgress(provider),
                        const SizedBox(height: 8),
                        // 月龄测试进度
                        _buildCompactAgeProgress(provider),
                      ],
                    ),
                  ),
                  
                  // 主要内容 - 题目卡片
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnimatedBuilder(
                        animation: _cardAnimation,
                        builder: (context, child) {
                          if (provider.currentItem == null) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: Colors.blue[600]),
                                  const SizedBox(height: 16),
                                  const Text('正在加载题目...', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            );
                          }
                          
                          double scaleValue = _cardAnimation.value > 0 ? _cardAnimation.value : 1.0;
                          return Transform.scale(
                            scale: scaleValue,
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
                                    // 当前阶段标注
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStageColor(provider.currentStage),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _getStageText(provider.currentStage),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
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
                                              provider.currentItem!.name,
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
                                              '${provider.currentItem!.score.toStringAsFixed(1)}分',
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
                                    if (provider.currentItem!.desc.isNotEmpty) ...[
                                      _buildInfoSection('题目描述', provider.currentItem!.desc, Colors.orange),
                                      const SizedBox(height: 16),
                                    ],
                                    
                                    // 操作方法
                                    _buildInfoSection('操作方法', provider.currentItem!.operation, Colors.purple),
                                    const SizedBox(height: 16),
                                    
                                    // 通过标准
                                    _buildInfoSection('通过标准', provider.currentItem!.passCondition, Colors.teal),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 操作按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
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
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactOverallProgress(AssessmentProvider provider) {
    int completedAreas = provider.areaCompleted.values.where((completed) => completed).length;
    int totalAreas = 5;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '整体进度',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$completedAreas / $totalAreas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 带节点的进度条
          _buildStepperProgress(TestArea.values, provider),
          // 已完成的能区结果
          if (completedAreas > 0) ...[
            const SizedBox(height: 8),
            _buildCompletedAreasInfo(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildStepperProgress(List<TestArea> areas, AssessmentProvider provider) {
    return Row(
      children: areas.asMap().entries.map((entry) {
        int index = entry.key;
        TestArea area = entry.value;
        bool isCompleted = provider.areaCompleted[area] ?? false;
        bool isCurrent = area == provider.currentArea;
        
        return Expanded(
          child: Row(
            children: [
              // 节点
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green[600] : (isCurrent ? Colors.blue[600] : Colors.grey[300]),
                ),
                child: isCompleted 
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
              ),
              // 连接线
              if (index < areas.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Colors.green[600] : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompletedAreasInfo(AssessmentProvider provider) {
    List<Widget> areaInfoWidgets = [];
    
    for (TestArea area in TestArea.values) {
      if (provider.areaCompleted[area] == true) {
        double mentalAge = provider.areaScores[area] ?? 0.0;
        double dq = _calculateDevelopmentQuotient(mentalAge, provider.actualAge);
        
        areaInfoWidgets.add(
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Text(
                  _getAreaShortName(area),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  '智龄: ${mentalAge.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.green[600],
                  ),
                ),
                Text(
                  'DQ: ${dq.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: areaInfoWidgets,
      ),
    );
  }

  double _calculateDevelopmentQuotient(double mentalAge, double actualAge) {
    if (actualAge == 0) return 0;
    return (mentalAge / actualAge) * 100;
  }

  Widget _buildCompactAgeProgress(AssessmentProvider provider) {
    List<int> testedAges = provider.areaTestedAges[provider.currentArea] ?? [];
    testedAges.sort();
    int currentAge = provider.getCurrentAreaAge();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '月龄进度',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '当前: ${currentAge}个月',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 月龄节点进度
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: testedAges.map((age) => _buildAgeNode(age, provider, currentAge)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeNode(int age, AssessmentProvider provider, int currentAge) {
    Color nodeColor = Colors.grey[400]!;
    bool isCurrent = age == currentAge;
    
    // 检查该月龄的测试状态
    bool hasPassed = _hasAgePassed(age, provider);
    bool hasFailed = _hasAgeFailed(age, provider);
    
    if (isCurrent) {
      nodeColor = Colors.grey[600]!; // 当前测试中显示灰色
    } else if (hasPassed && !hasFailed) {
      nodeColor = Colors.green[600]!;
    } else if (hasPassed && hasFailed) {
      nodeColor = Colors.orange[600]!;
    } else if (hasFailed && !hasPassed) {
      nodeColor = Colors.red[600]!;
    }
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$age',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: nodeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              '$title：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStageColor(TestStage stage) {
    switch (stage) {
      case TestStage.current:
        return Colors.blue[600]!;
      case TestStage.forward:
        return Colors.orange[600]!;
      case TestStage.backward:
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStageText(TestStage stage) {
    switch (stage) {
      case TestStage.current:
        return '主测月龄';
      case TestStage.forward:
        return '向前测查';
      case TestStage.backward:
        return '向后测查';
      default:
        return '未知阶段';
    }
  }

  Widget _buildAreaResultPage(AssessmentProvider provider) {
    double mentalAge = provider.getCurrentAreaMentalAge();
    double developmentQuotient = provider.getCurrentAreaDevelopmentQuotient();
    
    return AreaResultPage(
      area: provider.currentArea,
      mentalAge: mentalAge,
      developmentQuotient: developmentQuotient,
      onContinue: () {
        provider.nextItem();
      },
    );
  }

  void _handleAnswer(bool passed, AssessmentProvider provider) {
    if (provider.currentItem == null) {
      return;
    }
    
    provider.recordResult(provider.currentItem!.id, passed);
    
    if (provider.currentStageItemIndex < provider.currentStageItems.length - 1) {
      _cardController.reset();
      provider.nextItem();
      _cardController.forward();
    } else {
      _cardController.reset();
      provider.nextItem();
      
      if (provider.currentStage == TestStage.areaCompleted) {
        setState(() {});
      } else if (provider.currentStage == TestStage.allCompleted) {
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
        _cardController.forward();
      }
    }
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

  String _getAreaShortName(TestArea area) {
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

  String _getAreaString(TestArea area) {
    switch (area) {
      case TestArea.motor:
        return 'motor';
      case TestArea.fineMotor:
        return 'fineMotor';
      case TestArea.language:
        return 'language';
      case TestArea.adaptive:
        return 'adaptive';
      case TestArea.social:
        return 'social';
    }
  }

  bool _hasAgePassed(int age, AssessmentProvider provider) {
    String areaString = _getAreaString(provider.currentArea);
    var items = provider.allData
        .where((data) => data.ageMonth == age && data.area == areaString)
        .expand((data) => data.testItems)
        .toList();
    
    for (var item in items) {
      if (provider.testResults.containsKey(item.id) && provider.testResults[item.id] == true) {
        return true;
      }
    }
    return false;
  }

  bool _hasAgeFailed(int age, AssessmentProvider provider) {
    String areaString = _getAreaString(provider.currentArea);
    var items = provider.allData
        .where((data) => data.ageMonth == age && data.area == areaString)
        .expand((data) => data.testItems)
        .toList();
    
    for (var item in items) {
      if (provider.testResults.containsKey(item.id) && provider.testResults[item.id] == false) {
        return true;
      }
    }
    return false;
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