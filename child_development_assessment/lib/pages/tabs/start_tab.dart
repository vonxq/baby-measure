import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StartTab extends StatelessWidget {
  const StartTab({
    super.key,
    required this.nameController,
    required this.name,
    required this.selectedAge,
    required this.onNameChanged,
    required this.onAgeChanged,
    required this.onStart,
  });

  final TextEditingController nameController;
  final String name;
  final int selectedAge;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onAgeChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 宝宝姓名输入
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '宝宝姓名',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: '请输入宝宝姓名',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  onChanged: onNameChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 月龄选择
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cake, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '宝宝月龄',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showAgePicker(context, selectedAge, onAgeChanged),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$selectedAge个月',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showAgeCalculator(context, onAgeChanged),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.blue[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate, color: Colors.blue[600], size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '计算',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 开始测试按钮
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                '开始测评',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAgePicker(BuildContext context, int currentAge, ValueChanged<int> onAgeChanged) {
  int selectedAge = currentAge;
  
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => Container(
      height: 280,
      padding: const EdgeInsets.only(top: 6.0),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 顶部工具栏
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '选择月龄',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onAgeChanged(selectedAge);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '确定',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 选择器
            Expanded(
              child: CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem: currentAge,
                ),
                onSelectedItemChanged: (int selectedItem) {
                  selectedAge = selectedItem;
                },
                children: List<Widget>.generate(73, (int index) {
                  return Center(
                    child: Text(
                      '$index 个月',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAgeCalculator(BuildContext context, ValueChanged<int> onAgeChanged) {
  final now = DateTime.now();
  final minDate = DateTime(now.year - 6, now.month, now.day); // 6年前
  final defaultDate = DateTime(now.year - 1, now.month, now.day); // 默认1岁
  
  // 确保默认日期在允许范围内
  final initialDate = defaultDate.isBefore(minDate) ? minDate : defaultDate;
  
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => _AgeCalculatorDialog(
      initialDate: initialDate,
      minimumDate: minDate,
      onAgeCalculated: onAgeChanged,
    ),
  );
}

class _AgeCalculatorDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minimumDate;
  final ValueChanged<int> onAgeCalculated;
  
  const _AgeCalculatorDialog({
    required this.initialDate,
    required this.minimumDate,
    required this.onAgeCalculated,
  });
  
  @override
  State<_AgeCalculatorDialog> createState() => _AgeCalculatorDialogState();
}

class _AgeCalculatorDialogState extends State<_AgeCalculatorDialog> {
  late DateTime selectedDate;
  int? calculatedMonths;
  int? recommendedAge;
  
  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _calculateAge();
  }
  
  void _calculateAge() {
    final now = DateTime.now();
    final difference = now.difference(selectedDate);
    final months = (difference.inDays / 30.44).round(); // 平均每月30.44天
    
    setState(() {
      calculatedMonths = months.clamp(0, 72); // 限制在0-72个月范围内
      recommendedAge = _getRecommendedAge(calculatedMonths!);
    });
  }
  
  int _getRecommendedAge(int actualMonths) {
    // 根据实际月龄推荐测试月龄，使用就近原则
    final availableAges = [0, 1, 2, 3, 4, 5, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60, 66, 72];
    
    int closestAge = availableAges[0];
    int minDifference = (actualMonths - availableAges[0]).abs();
    
    for (int age in availableAges) {
      int difference = (actualMonths - age).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestAge = age;
      }
    }
    
    return closestAge;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '计算宝宝月龄',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '请选择宝宝的出生日期：',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 日期选择器
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedDate,
                        maximumDate: DateTime.now(),
                        minimumDate: widget.minimumDate,
                        dateOrder: DatePickerDateOrder.ymd, // 年月日顺序
                        onDateTimeChanged: (DateTime date) {
                          selectedDate = date;
                          _calculateAge();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部按钮区域
          if (calculatedMonths != null && recommendedAge != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '您的宝宝为 $calculatedMonths 个月，建议使用 $recommendedAge 月龄测试',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onAgeCalculated(recommendedAge!);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        '使用 $recommendedAge 月龄',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

