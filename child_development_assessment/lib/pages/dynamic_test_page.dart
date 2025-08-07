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
                  
                  // 主要内容
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 整体能区进度条
                          _buildOverallAreaProgress(provider),
                          const SizedBox(height: 16),
                          
                          // 当前能区进度条
                          _buildCurrentAreaProgress(provider),
                          const SizedBox(height: 16),
                          
                          // 月龄测试进度条
                          _buildAgeProgress(provider),
                          const SizedBox(height: 16),

                          // 题目卡片
                          Expanded(
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

  Widget _buildOverallAreaProgress(AssessmentProvider provider) {
    int completedAreas = provider.areaCompleted.values.where((completed) => completed).length;
    int totalAreas = 5;
    
    return Container(
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
              Text(
                '整体能区进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$completedAreas / $totalAreas',
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
            value: completedAreas / totalAreas,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: TestArea.values.map((area) => _buildAreaChip(area, provider.areaCompleted[area] ?? false)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChip(TestArea area, bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: completed ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: completed ? Colors.green[300]! : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: completed ? Colors.green[600] : Colors.grey[400],
          ),
          const SizedBox(width: 4),
          Text(
            _getAreaShortName(area),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: completed ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAreaProgress(AssessmentProvider provider) {
    int testedCount = provider.getCurrentAreaTestedCount();
    int totalCount = provider.getCurrentAreaTotalCount();
    int currentAge = provider.getCurrentAreaAge();

    return Container(
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
                    '${_getCurrentAreaName(provider.currentArea)}进度',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '当前月龄：$currentAge个月',
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
    );
  }

  Widget _buildAgeProgress(AssessmentProvider provider) {
    List<int> testedAges = provider.areaTestedAges[provider.currentArea] ?? [];
    testedAges.sort();
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '月龄测试进度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: testedAges.map((age) => _buildAgeChip(age, provider)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeChip(int age, AssessmentProvider provider) {
    Color chipColor = Colors.grey[400]!;
    String status = '未测试';
    
    // 检查该月龄的测试状态
    bool hasPassed = _hasAgePassed(age, provider);
    bool hasFailed = _hasAgeFailed(age, provider);
    
    if (hasPassed && !hasFailed) {
      chipColor = Colors.green[600]!;
      status = '全通过';
    } else if (hasPassed && hasFailed) {
      chipColor = Colors.orange[600]!;
      status = '部分通过';
    } else if (hasFailed && !hasPassed) {
      chipColor = Colors.red[600]!;
      status = '全失败';
    }
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor),
      ),
      child: Column(
        children: [
          Text(
            '$age个月',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: chipColor,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
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