import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../../app/routes.dart';
import '../../data/models/baby.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 确保宝宝数据已加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      if (!babyProvider.hasBabies) {
        Get.offAllNamed(AppRoutes.babyManagement);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('儿童发育评估'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Get.toNamed(AppRoutes.history),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, child) {
          if (babyProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (!babyProvider.hasBabies) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('还没有宝宝信息', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.babyManagement),
                    child: Text('添加宝宝'),
                  ),
                ],
              ),
            );
          }

          final currentBaby = babyProvider.currentBaby!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 宝宝信息卡片
                _buildBabyCard(currentBaby, babyProvider),
                SizedBox(height: 24),
                
                // 功能按钮
                _buildFunctionButtons(),
                SizedBox(height: 24),
                
                // 快速操作
                _buildQuickActions(currentBaby),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAssessment(),
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }

  Widget _buildBabyCard(Baby baby, BabyProvider babyProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: baby.avatar != null
                      ? ClipOval(child: Image.asset(baby.avatar!))
                      : Icon(Icons.child_care, size: 30, color: Colors.blue[600]),
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
                      SizedBox(height: 4),
                      Text(
                        '${baby.gender == 'male' ? '男' : '女'} · ${baby.ageInMonths.toStringAsFixed(1)}个月',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // TODO: 编辑宝宝信息
                    } else if (value == 'switch') {
                      _showBabySelector(babyProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('编辑信息')),
                    PopupMenuItem(value: 'switch', child: Text('切换宝宝')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('功能', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.assessment,
                title: '开始评估',
                subtitle: '进行发育行为评估',
                color: Colors.blue,
                onTap: _startAssessment,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.history,
                title: '历史记录',
                subtitle: '查看评估历史',
                color: Colors.green,
                onTap: () => Get.toNamed(AppRoutes.history),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.child_care,
                title: '宝宝管理',
                subtitle: '管理宝宝信息',
                color: Colors.orange,
                onTap: () => Get.toNamed(AppRoutes.babyManagement),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.help,
                title: '使用帮助',
                subtitle: '了解如何使用',
                color: Colors.purple,
                onTap: () {
                  // TODO: 帮助页面
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFunctionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(Baby baby) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('快速操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.today, color: Colors.blue),
                  title: Text('今日评估'),
                  subtitle: Text('为${baby.name}进行今日评估'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: _startAssessment,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.trending_up, color: Colors.green),
                  title: Text('发育趋势'),
                  subtitle: Text('查看${baby.name}的发育趋势'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Get.toNamed(AppRoutes.history),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBabySelector(BabyProvider babyProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择宝宝', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...babyProvider.babies.map((baby) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(baby.name[0], style: TextStyle(color: Colors.blue[600])),
              ),
              title: Text(baby.name),
              subtitle: Text('${baby.ageInMonths.toStringAsFixed(1)}个月'),
              trailing: babyProvider.currentBaby?.id == baby.id
                  ? Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                babyProvider.setCurrentBaby(baby);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _startAssessment() {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    if (babyProvider.currentBaby != null) {
      Get.toNamed(AppRoutes.assessment);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先选择宝宝')),
      );
    }
  }
} 