import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/assessment_provider.dart';
import '../providers/baby_provider.dart';
import '../../app/routes.dart';
import '../../data/models/assessment_result.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评估结果'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: 分享功能
            },
          ),
        ],
      ),
      body: Consumer2<AssessmentProvider, BabyProvider>(
        builder: (context, assessmentProvider, babyProvider, child) {
          final result = assessmentProvider.currentResult;
          final baby = babyProvider.currentBaby;
          
          if (result == null || baby == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red),
                  SizedBox(height: 20),
                  Text('没有评估结果', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: Text('返回首页'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总体结果卡片
                _buildOverallResultCard(result, baby),
                SizedBox(height: 16),
                
                // 各能区结果
                _buildAreaResultsCard(result),
                SizedBox(height: 16),
                
                // 发育水平说明
                _buildLevelDescriptionCard(result),
                SizedBox(height: 16),
                
                // 建议
                _buildSuggestionsCard(result),
                SizedBox(height: 16),
                
                // 操作按钮
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallResultCard(AssessmentResult result, Baby baby) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.child_care, size: 30, color: Colors.blue[600]),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baby.name,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${baby.ageInMonths.toStringAsFixed(1)}个月 · ${result.testDate.year}-${result.testDate.month.toString().padLeft(2, '0')}-${result.testDate.day.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // 发育商
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(result.levelColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(result.levelColor)),
              ),
              child: Column(
                children: [
                  Text(
                    '发育商 (DQ)',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    result.developmentQuotient.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(result.levelColor),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(result.levelColor),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      result.levelDescription,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaResultsCard(AssessmentResult result) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '各能区得分',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // 雷达图
            Container(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: result.areaResults['motor']?.mentalAge ?? 0),
                        RadarEntry(value: result.areaResults['fineMotor']?.mentalAge ?? 0),
                        RadarEntry(value: result.areaResults['language']?.mentalAge ?? 0),
                        RadarEntry(value: result.areaResults['adaptive']?.mentalAge ?? 0),
                        RadarEntry(value: result.areaResults['social']?.mentalAge ?? 0),
                      ],
                      fillColor: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      entryRadius: 3,
                    ),
                  ],
                  titleTextStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  getTitle: (index, angle, radius) {
                    final titles = ['大运动', '精细动作', '语言', '适应能力', '社会行为'];
                    return RadarChartTitle(
                      text: titles[index],
                      angle: angle,
                      radius: radius,
                    );
                  },
                  borderData: FlBorderData(show: true),
                  gridBorderData: FlBorderData(show: true),
                  radarBorderData: FlBorderData(show: true),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // 详细数据
            ...result.areaResults.entries.map((entry) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(_getAreaName(entry.key)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${entry.value.mentalAge.toStringAsFixed(1)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${entry.value.score.toStringAsFixed(1)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelDescriptionCard(AssessmentResult result) {
    String description = '';
    String suggestion = '';
    
    switch (result.level) {
      case 'excellent':
        description = '您的宝宝发育水平优秀，各项能力发展良好。';
        suggestion = '继续保持良好的养育环境，适当增加一些挑战性的活动。';
        break;
      case 'good':
        description = '您的宝宝发育水平良好，各项能力发展正常。';
        suggestion = '继续保持当前的养育方式，可以适当增加一些促进发育的活动。';
        break;
      case 'average':
        description = '您的宝宝发育水平中等，各项能力发展基本正常。';
        suggestion = '建议增加一些针对性的训练活动，促进各项能力的发展。';
        break;
      case 'low':
        description = '您的宝宝发育水平偏低，需要关注和干预。';
        suggestion = '建议咨询专业医生，制定针对性的训练计划。';
        break;
      case 'disability':
        description = '您的宝宝可能存在发育障碍，需要及时就医。';
        suggestion = '建议立即咨询专业医生，进行全面的发育评估。';
        break;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '发育水平说明',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              '建议：',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              suggestion,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard(AssessmentResult result) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '注意事项',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '• 本评估结果仅供参考，不能替代专业医疗诊断\n'
              '• 如有疑问，请咨询专业医生\n'
              '• 建议定期进行发育评估，跟踪宝宝的发展\n'
              '• 保持良好的养育环境，促进宝宝全面发展',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('返回首页', style: TextStyle(fontSize: 16)),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.toNamed(AppRoutes.history),
                child: Text('查看历史'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: 重新评估
                },
                child: Text('重新评估'),
              ),
            ),
          ],
        ),
      ],
    );
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
} 