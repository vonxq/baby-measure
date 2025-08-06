import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/baby_provider.dart';
import '../../app/routes.dart';
import '../../data/models/baby.dart';

class BabyManagementPage extends StatefulWidget {
  @override
  _BabyManagementPageState createState() => _BabyManagementPageState();
}

class _BabyManagementPageState extends State<BabyManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String _selectedGender = 'male';
  bool _isAdding = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('宝宝管理'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddBabyDialog,
          ),
        ],
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, child) {
          if (babyProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (babyProvider.babies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('还没有宝宝信息', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showAddBabyDialog,
                    icon: Icon(Icons.add),
                    label: Text('添加第一个宝宝'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: babyProvider.babies.length,
            itemBuilder: (context, index) {
              final baby = babyProvider.babies[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue[100],
                    child: baby.avatar != null
                        ? ClipOval(child: Image.asset(baby.avatar!))
                        : Icon(Icons.child_care, size: 25, color: Colors.blue[600]),
                  ),
                  title: Text(baby.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${baby.gender == 'male' ? '男' : '女'} · ${baby.ageInMonths.toStringAsFixed(1)}个月',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleBabyAction(value, baby, babyProvider),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text('编辑')),
                      PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                  ),
                  onTap: () {
                    babyProvider.setCurrentBaby(baby);
                    Get.back();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddBabyDialog() {
    _nameController.clear();
    _selectedBirthDate = null;
    _selectedGender = 'male';
    _isAdding = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加宝宝'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '宝宝姓名',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入宝宝姓名';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '出生日期',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedBirthDate != null
                          ? '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}'
                          : '请选择出生日期',
                      style: TextStyle(color: _selectedBirthDate != null ? Colors.black : Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: '性别',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'male', child: Text('男')),
                    DropdownMenuItem(value: 'female', child: Text('女')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: _saveBaby,
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  void _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365)),
      firstDate: DateTime.now().subtract(Duration(days: 365 * 6)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _saveBaby() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请选择出生日期')),
      );
      return;
    }

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final baby = Baby(
      id: Uuid().v4(),
      name: _nameController.text.trim(),
      birthDate: _selectedBirthDate!,
      gender: _selectedGender,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await babyProvider.addBaby(baby);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('宝宝添加成功')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加失败，请重试')),
      );
    }
  }

  void _handleBabyAction(String action, Baby baby, BabyProvider babyProvider) {
    switch (action) {
      case 'edit':
        _showEditBabyDialog(baby, babyProvider);
        break;
      case 'delete':
        _showDeleteConfirmDialog(baby, babyProvider);
        break;
    }
  }

  void _showEditBabyDialog(Baby baby, BabyProvider babyProvider) {
    _nameController.text = baby.name;
    _selectedBirthDate = baby.birthDate;
    _selectedGender = baby.gender;
    _isAdding = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑宝宝信息'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '宝宝姓名',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入宝宝姓名';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '出生日期',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: '性别',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'male', child: Text('男')),
                    DropdownMenuItem(value: 'female', child: Text('女')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _updateBaby(baby, babyProvider),
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  void _updateBaby(Baby baby, BabyProvider babyProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final updatedBaby = baby.copyWith(
      name: _nameController.text.trim(),
      birthDate: _selectedBirthDate!,
      gender: _selectedGender,
      updatedAt: DateTime.now(),
    );

    final success = await babyProvider.updateBaby(updatedBaby);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('宝宝信息更新成功')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败，请重试')),
      );
    }
  }

  void _showDeleteConfirmDialog(Baby baby, BabyProvider babyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除宝宝"${baby.name}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBaby(baby, babyProvider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  void _deleteBaby(Baby baby, BabyProvider babyProvider) async {
    final success = await babyProvider.deleteBaby(baby.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('宝宝删除成功')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败，请重试')),
      );
    }
  }
} 