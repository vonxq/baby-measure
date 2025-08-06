import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/baby_provider.dart';
import '../../data/models/baby.dart';
import '../../core/utils/error_handler.dart';

class BabyEditPage extends StatefulWidget {
  final Baby? baby; // 如果为null，则为添加模式

  const BabyEditPage({Key? key, this.baby}) : super(key: key);

  @override
  _BabyEditPageState createState() => _BabyEditPageState();
}

class _BabyEditPageState extends State<BabyEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String _selectedGender = 'male';
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.baby != null;
    if (_isEditMode) {
      _nameController.text = widget.baby!.name;
      _selectedBirthDate = widget.baby!.birthDate;
      _selectedGender = widget.baby!.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑宝宝信息' : '添加宝宝'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _showDeleteConfirmDialog,
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingMessage: '保存中...',
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像选择
                _buildAvatarSection(),
                SizedBox(height: 24),
                
                // 基本信息
                _buildBasicInfoSection(),
                SizedBox(height: 24),
                
                // 保存按钮
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '宝宝头像',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _selectAvatar,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue[300]!, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.blue[600],
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '点击选择头像',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // 姓名
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '宝宝姓名 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入宝宝姓名';
                }
                if (value.trim().length > 20) {
                  return '姓名长度不能超过20个字符';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // 出生日期
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '出生日期 *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}'
                      : '请选择出生日期',
                  style: TextStyle(
                    color: _selectedBirthDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // 性别
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: '性别 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
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
            SizedBox(height: 16),
            
            // 当前月龄显示
            if (_selectedBirthDate != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      '当前月龄: ${_calculateAgeInMonths().toStringAsFixed(1)}个月',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveBaby,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          _isEditMode ? '保存修改' : '添加宝宝',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  void _selectAvatar() {
    // TODO: 实现头像选择功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('头像选择功能开发中...')),
    );
  }

  void _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(Duration(days: 365)),
      firstDate: DateTime.now().subtract(Duration(days: 365 * 6)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  double _calculateAgeInMonths() {
    if (_selectedBirthDate == null) return 0.0;
    
    final now = DateTime.now();
    int years = now.year - _selectedBirthDate!.year;
    int months = now.month - _selectedBirthDate!.month;
    int days = now.day - _selectedBirthDate!.day;
    
    double totalMonths = years * 12 + months + days / 30.0;
    return double.parse(totalMonths.toStringAsFixed(1));
  }

  void _saveBaby() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ErrorHandler.showError('请选择出生日期');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      
      if (_isEditMode) {
        // 编辑模式
        final updatedBaby = widget.baby!.copyWith(
          name: _nameController.text.trim(),
          birthDate: _selectedBirthDate!,
          gender: _selectedGender,
          updatedAt: DateTime.now(),
        );
        
        final success = await babyProvider.updateBaby(updatedBaby);
        if (success) {
          ErrorHandler.showSuccess('宝宝信息更新成功');
          Get.back();
        } else {
          ErrorHandler.showError('更新失败，请重试');
        }
      } else {
        // 添加模式
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
          ErrorHandler.showSuccess('宝宝添加成功');
          Get.back();
        } else {
          ErrorHandler.showError('添加失败，请重试');
        }
      }
    } catch (e) {
      ErrorHandler.showError('操作失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除宝宝"${widget.baby!.name}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBaby();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  void _deleteBaby() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final success = await babyProvider.deleteBaby(widget.baby!.id);
      
      if (success) {
        ErrorHandler.showSuccess('宝宝删除成功');
        Get.back();
      } else {
        ErrorHandler.showError('删除失败，请重试');
      }
    } catch (e) {
      ErrorHandler.showError('删除失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 