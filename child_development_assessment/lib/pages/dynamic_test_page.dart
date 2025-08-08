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
                      const Text('正在准备动态测评...', style: TextStyle(fontSize: 14)),
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
                      const Text('动态测评完成！', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('正在生成结果...', style: TextStyle(fontSize: 14)),
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
                      const Text('正在加载题目...', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // 顶部退出按钮
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _showExitDialog(context),
                          icon: const Icon(Icons.close, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  
                  // 紧凑的进度区域
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                  const Text('正在加载题目...', style: TextStyle(fontSize: 14)),
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
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 测试项目标识
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.blue[300]!, width: 1.5),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.check_box_outline_blank,
                                                size: 16,
                                                color: Colors.blue[600],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '测试项目 ${provider.currentItem!.id}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getAreaColor(provider.currentItem!.area).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getAreaColor(provider.currentItem!.area).withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Text(
                                              _getAreaName(provider.currentItem!.area),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getAreaColor(provider.currentItem!.area),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // 题目标题
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.blue[200]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              provider.currentItem!.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.orange[300]!),
                                            ),
                                            child: Text(
                                              '${provider.currentItem!.score.toStringAsFixed(1)}分',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // 题目描述
                                    // if (provider.currentItem!.desc.isNotEmpty) ...[
                                    //   _buildInfoSection('题目描述', provider.currentItem!.desc, Colors.orange),
                                    //   const SizedBox(height: 12),
                                    // ],
                                    
                                    // 操作方法
                                    _buildInfoSection('操作方法', provider.currentItem!.operation, Colors.purple),
                                    const SizedBox(height: 12),
                                    
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
                  
                  const SizedBox(height: 16),
                  
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
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('上一题', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAnswer(true, provider),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('通过', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAnswer(false, provider),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('不通过', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$completedAreas / $totalAreas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 带节点的进度条
          _buildStepperProgress(TestArea.values, provider),
        ],
      ),
    );
  }

  Widget _buildStepperProgress(List<TestArea> areas, AssessmentProvider provider) {
    return Row(
      children: areas.map((area) {
        bool isCompleted = provider.areaCompleted[area] ?? false;
        bool isCurrent = area == provider.currentArea;
        double mentalAge = provider.areaScores[area] ?? 0.0;
        double dq = _calculateDevelopmentQuotient(mentalAge, provider.actualAge);
        
        // 确定卡片颜色
        Color cardColor = Colors.grey[200]!;
        Color textColor = Colors.grey[600]!;
        
        if (isCurrent) {
          cardColor = Colors.blue[100]!;
          textColor = Colors.blue[700]!;
        } else if (isCompleted) {
          if (dq >= 80) {
            cardColor = Colors.green[100]!;
            textColor = Colors.green[700]!;
          } else {
            cardColor = Colors.orange[100]!;
            textColor = Colors.orange[700]!;
          }
        }
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 60, // 固定高度确保一致性
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent ? Colors.blue[300]! : Colors.grey[300]!,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 能区名称
                Text(
                  _getAreaShortName(area),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                // 智龄信息（始终显示，未完成时显示占位符）
                Text(
                  isCompleted ? '智龄: ${mentalAge.toStringAsFixed(1)}' : '智龄: --',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    color: textColor,
                  ),
                ),
                // 发育商信息（始终显示，未完成时显示占位符）
                Text(
                  isCompleted ? 'DQ: ${dq.toStringAsFixed(0)}' : 'DQ: --',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }



  Widget _buildCompactAgeProgress(AssessmentProvider provider) {
    List<int> testedAges = provider.areaTestedAges[provider.currentArea] ?? [];
    testedAges.sort();
    int currentAge = provider.getCurrentAreaAge();
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              // 阶段信息移到右上角
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStageColor(provider.currentStage),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStageText(provider.currentStage),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 月龄节点进度
          _buildAgeStepperProgress(testedAges, provider, currentAge),
        ],
      ),
    );
  }

  Widget _buildAgeStepperProgress(List<int> ages, AssessmentProvider provider, int currentAge) {
    if (ages.isEmpty) return const SizedBox.shrink();
    
    // 按月龄排序
    ages.sort();
    
    // 计算每行8个圆点
    const int maxPerRow = 8;
    List<List<int>> rows = [];
    for (int i = 0; i < ages.length; i += maxPerRow) {
      rows.add(ages.sublist(i, (i + maxPerRow > ages.length) ? ages.length : i + maxPerRow));
    }
    
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: row.map((age) {
              bool isCurrent = age == currentAge;
              bool hasPassed = _hasAgePassed(age, provider);
              bool hasFailed = _hasAgeFailed(age, provider);
              
              Color nodeColor = Colors.grey[300]!;
              
              if (isCurrent) {
                nodeColor = Colors.blue[600]!; // 进行中是蓝色
              } else if (hasPassed && !hasFailed) {
                nodeColor = Colors.green[600]!; // 全过是绿色
              } else if (hasPassed && hasFailed) {
                nodeColor = Colors.orange[600]!; // 部分过是橙色
              }
              
              return Expanded(
                child: Container(
                  height: 24, // 固定高度
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: nodeColor,
                      ),
                      child: Center(
                        child: Text(
                          '$age',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  double _calculateDevelopmentQuotient(double mentalAge, double actualAge) {
    if (actualAge == 0) return 0;
    return (mentalAge / actualAge) * 100;
  }

  Widget _buildInfoSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              '$title：',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 12,
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

  // 根据能区字符串获取颜色
  Color _getAreaColor(String area) {
    switch (area) {
      case 'motor':
        return Colors.purple;
      case 'fineMotor':
        return Colors.orange;
      case 'language':
        return Colors.green;
      case 'adaptive':
        return Colors.blue;
      case 'social':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 根据能区字符串获取名称
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
} 