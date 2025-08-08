import 'package:flutter/material.dart';

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    value: selectedAge,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(73, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('${index}个月'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        onAgeChanged(value);
                      }
                    },
                  ),
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

