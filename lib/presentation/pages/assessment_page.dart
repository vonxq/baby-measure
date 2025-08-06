import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../providers/assessment_provider.dart';
import '../../app/routes.dart';
import '../../data/models/assessment_item.dart';

class AssessmentPage extends StatefulWidget {
  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  @override
  void initState() {
    super.initState();
    _initializeAssessment();
  }

  Future<void> _initializeAssessment() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    
    if (babyProvider.currentBaby != null) {
      await assessmentProvider.initializeAssessment(babyProvider.currentBaby!.ageInMonths);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发育评估'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmDialog(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Consumer2<BabyProvider, AssessmentProvider>(
        builder: (context, babyProvider, assessmentProvider, child) {
          if (assessmentProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (babyProvider.currentBaby == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red),
                  SizedBox(height: 20),
                  Text('请先选择宝宝', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('返回'),
                  ),
                ],
              ),
            );
          }

          if (assessmentProvider.currentTestItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('没有找到适合的评估项目', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('当前月龄: ${babyProvider.currentBaby!.ageInMonths.toStringAsFixed(1)}个月'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 进度条
              _buildProgressBar(assessmentProvider),
              
              // 当前项目
              Expanded(
                child: _buildCurrentItem(assessmentProvider),
              ),
              
              // 操作按钮
              _buildActionButtons(assessmentProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(AssessmentProvider assessmentProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('进度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '${assessmentProvider.currentItemIndex + 1}/${assessmentProvider.currentTestItems.length}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: assessmentProvider.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 8),
          Text(
            '当前能区: ${_getAreaName(assessmentProvider.currentArea)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentItem(AssessmentProvider assessmentProvider) {
    final currentItem = assessmentProvider.currentItem;
    if (currentItem == null) return Container();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目标题
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentItem.areaName,
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${currentItem.score}分',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    currentItem.itemName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // 操作指导
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '操作指导',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currentItem.description.isNotEmpty ? currentItem.description : '请按照标准操作进行测试',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // 通过标准
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '通过标准',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currentItem.passCriteria.isNotEmpty ? currentItem.passCriteria : '按照操作指导完成测试',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          
          // 当前结果
          if (assessmentProvider.itemResults.containsKey(currentItem.id))
            SizedBox(height: 16),
            Card(
              color: assessmentProvider.itemResults[currentItem.id]! ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      assessmentProvider.itemResults[currentItem.id]! ? Icons.check_circle : Icons.cancel,
                      color: assessmentProvider.itemResults[currentItem.id]! ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      assessmentProvider.itemResults[currentItem.id]! ? '已通过' : '未通过',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: assessmentProvider.itemResults[currentItem.id]! ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AssessmentProvider assessmentProvider) {
    final currentItem = assessmentProvider.currentItem;
    if (currentItem == null) return Container();

    final hasResult = assessmentProvider.itemResults.containsKey(currentItem.id);
    final result = hasResult ? assessmentProvider.itemResults[currentItem.id] : null;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 通过/不通过按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _recordResult(assessmentProvider, currentItem.id, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: result == true ? Colors.green : Colors.grey[300],
                    foregroundColor: result == true ? Colors.white : Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check),
                      SizedBox(width: 8),
                      Text('通过', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _recordResult(assessmentProvider, currentItem.id, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: result == false ? Colors.red : Colors.grey[300],
                    foregroundColor: result == false ? Colors.white : Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close),
                      SizedBox(width: 8),
                      Text('不通过', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // 导航按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: assessmentProvider.currentItemIndex > 0
                      ? () => assessmentProvider.previousItem()
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 8),
                      Text('上一题'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: assessmentProvider.currentItemIndex < assessmentProvider.currentTestItems.length - 1
                      ? () => assessmentProvider.nextItem()
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('下一题'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // 完成评估按钮
          if (assessmentProvider.isTestCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _completeAssessment(assessmentProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('完成评估', style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }

  void _recordResult(AssessmentProvider assessmentProvider, String itemId, bool result) {
    assessmentProvider.recordItemResult(itemId, result);
    
    // 自动跳转到下一题
    if (assessmentProvider.currentItemIndex < assessmentProvider.currentTestItems.length - 1) {
      Future.delayed(Duration(milliseconds: 500), () {
        assessmentProvider.nextItem();
      });
    }
  }

  void _completeAssessment(AssessmentProvider assessmentProvider) async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    if (babyProvider.currentBaby == null) return;

    final result = await assessmentProvider.completeAssessment(
      babyProvider.currentBaby!.id,
      babyProvider.currentBaby!.ageInMonths,
    );

    if (result != null) {
      Get.offAllNamed(AppRoutes.result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('完成评估失败，请重试')),
      );
    }
  }

  String _getAreaName(String areaType) {
    switch (areaType) {
      case 'motor':
        return '大运动能区';
      case 'fineMotor':
        return '精细动作能区';
      case 'language':
        return '语言能区';
      case 'adaptive':
        return '适应能力能区';
      case 'social':
        return '社会行为能区';
      default:
        return '未知能区';
    }
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认退出'),
        content: Text('确定要退出评估吗？当前进度将不会保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('退出'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('评估帮助'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. 仔细阅读操作指导和通过标准'),
            SizedBox(height: 8),
            Text('2. 按照指导进行测试'),
            SizedBox(height: 8),
            Text('3. 根据测试结果选择通过或不通过'),
            SizedBox(height: 8),
            Text('4. 完成所有项目后查看评估结果'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('知道了'),
          ),
        ],
      ),
    );
  }
} 