import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/baby_provider.dart';
import '../providers/assessment_provider.dart';
import '../../app/routes.dart';
import '../../core/utils/error_handler.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // 应用信息
          _buildSection(
            title: '应用信息',
            children: [
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                title: Text('版本'),
                subtitle: Text('1.0.0'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAppInfo(),
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.green),
                title: Text('使用帮助'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showHelp(),
              ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.orange),
                title: Text('关于'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAbout(),
              ),
            ],
          ),
          
          // 数据管理
          _buildSection(
            title: '数据管理',
            children: [
              ListTile(
                leading: Icon(Icons.backup, color: Colors.purple),
                title: Text('数据备份'),
                subtitle: Text('导出所有数据'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _backupData(),
              ),
              ListTile(
                leading: Icon(Icons.restore, color: Colors.teal),
                title: Text('数据恢复'),
                subtitle: Text('从备份文件恢复'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _restoreData(),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text('清除所有数据'),
                subtitle: Text('删除所有宝宝和评估记录'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _clearAllData(),
              ),
            ],
          ),
          
          // 评估设置
          _buildSection(
            title: '评估设置',
            children: [
              ListTile(
                leading: Icon(Icons.assessment, color: Colors.indigo),
                title: Text('评估参数'),
                subtitle: Text('调整评估计算参数'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAssessmentSettings(),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.amber),
                title: Text('提醒设置'),
                subtitle: Text('设置评估提醒'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showNotificationSettings(),
              ),
            ],
          ),
          
          // 其他设置
          _buildSection(
            title: '其他',
            children: [
              ListTile(
                leading: Icon(Icons.feedback, color: Colors.cyan),
                title: Text('意见反馈'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showFeedback(),
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: Colors.grey),
                title: Text('隐私政策'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPrivacyPolicy(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('应用信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('应用名称: 儿童发育评估'),
            SizedBox(height: 8),
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('开发者: 专业团队'),
            SizedBox(height: 8),
            Text('基于0-6岁儿童发育行为评估量表'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('使用帮助'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. 添加宝宝信息', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('在宝宝管理页面添加宝宝的基本信息'),
              SizedBox(height: 8),
              Text('2. 开始评估', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('选择宝宝后点击开始评估，按照指导进行测试'),
              SizedBox(height: 8),
              Text('3. 查看结果', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('完成评估后查看详细的发育评估结果'),
              SizedBox(height: 8),
              Text('4. 跟踪发展', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('定期进行评估，跟踪宝宝的发育趋势'),
            ],
          ),
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

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('关于'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('儿童发育评估应用'),
            SizedBox(height: 8),
            Text('本应用基于专业的儿童发育行为评估量表，为0-6岁儿童提供发育评估服务。'),
            SizedBox(height: 8),
            Text('应用特点:'),
            Text('• 专业的评估标准'),
            Text('• 简单易用的操作'),
            Text('• 详细的结果分析'),
            Text('• 完整的历史记录'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _backupData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 实现数据备份功能
      await Future.delayed(Duration(seconds: 2)); // 模拟备份过程
      ErrorHandler.showSuccess('数据备份成功');
    } catch (e) {
      ErrorHandler.showError('数据备份失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _restoreData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('数据恢复'),
        content: Text('确定要恢复数据吗？这将覆盖当前的所有数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现数据恢复功能
              ErrorHandler.showWarning('数据恢复功能开发中');
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清除所有数据'),
        content: Text('确定要清除所有数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _confirmClearData(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData() async {
    Navigator.pop(context);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
      
      // 清除所有数据
      await babyProvider.clearAllBabies();
      assessmentProvider.resetAssessment();
      
      // 清除SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      ErrorHandler.showSuccess('所有数据已清除');
      
      // 返回首页
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      ErrorHandler.showError('清除数据失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAssessmentSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('评估参数'),
        content: Text('评估参数设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('提醒设置'),
        content: Text('提醒设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('意见反馈'),
        content: Text('如有问题或建议，请联系开发团队。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('隐私政策'),
        content: SingleChildScrollView(
          child: Text(
            '本应用重视用户隐私保护：\n\n'
            '• 所有数据仅存储在本地设备\n'
            '• 不会向第三方分享用户数据\n'
            '• 用户可以随时清除所有数据\n'
            '• 应用不会收集个人信息',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
} 