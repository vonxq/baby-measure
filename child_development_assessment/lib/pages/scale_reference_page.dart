import 'package:flutter/material.dart';
import '../models/assessment_data.dart';
import '../models/assessment_item.dart';
import '../services/data_service.dart';

class ScaleReferencePage extends StatefulWidget {
  const ScaleReferencePage({super.key});

  @override
  State<ScaleReferencePage> createState() => _ScaleReferencePageState();
}

class _ScaleReferencePageState extends State<ScaleReferencePage>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  List<AssessmentData> _allData = [];
  List<int> _allAges = [];
  List<String> _allAreas = [];

  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;
  int _selectedAge = 6; // 默认6月龄
  String _selectedArea = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _dataService.loadAssessmentData();
      final ages = _dataService.getAvailableAges(data);
      final areas = data.map((e) => e.area).toSet().toList()..sort();

      setState(() {
        _allData = data;
        _allAges = ages;
        _allAreas = areas;
        if (!_allAges.contains(_selectedAge) && _allAges.isNotEmpty) {
          _selectedAge = _allAges.first;
        }
        _selectedArea = _allAreas.isNotEmpty ? _allAreas.first : '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载量表数据失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评估量表说明'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '按月龄查看'),
            Tab(text: '按能区查看'),
            Tab(text: '按题目查看'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildByAgeTab(),
                    _buildByAreaTab(),
                    _buildByItemTab(),
                  ],
                ),
    );
  }

  Widget _buildByAgeTab() {
    final ageData = _allData.where((e) => e.ageMonth == _selectedAge).toList();
    final areaToItems = <String, List<AssessmentItem>>{};
    for (final d in ageData) {
      areaToItems.putIfAbsent(d.area, () => []);
      areaToItems[d.area]!.addAll(d.testItems);
    }

    return Column(
      children: [
        _buildToolbar(
          left: Row(
            children: [
              const Text('月龄：'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedAge,
                items: _allAges
                    .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text('$age 月龄'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAge = v ?? _selectedAge),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: areaToItems.entries
                .map((entry) => _buildAreaSection(
                      header: '${entry.key}（${_selectedAge}月龄）',
                      items: entry.value,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildByAreaTab() {
    final filtered = _allData.where((e) => e.area == _selectedArea).toList()
      ..sort((a, b) => a.ageMonth.compareTo(b.ageMonth));

    return Column(
      children: [
        _buildToolbar(
          left: Row(
            children: [
              const Text('能区：'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedArea.isEmpty ? null : _selectedArea,
                hint: const Text('选择能区'),
                items: _allAreas
                    .map((area) => DropdownMenuItem(
                          value: area,
                          child: Text(area),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedArea = v ?? _selectedArea),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final d = filtered[index];
              return _buildAreaSection(
                header: '${d.area} · ${d.ageMonth}月龄',
                items: d.testItems,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildByItemTab() {
    final flattened = <_ItemRow>[];
    for (final d in _allData) {
      for (final item in d.testItems) {
        flattened.add(_ItemRow(
          id: item.id,
          name: item.name,
          operation: item.operation,
          passCondition: item.passCondition,
          score: item.score,
          area: d.area,
          ageMonth: d.ageMonth,
        ));
      }
    }
    flattened.sort((a, b) => a.id.compareTo(b.id));

    return Column(
      children: [
        _buildToolbar(left: const Text('全部题目（按ID升序）')),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: flattened.length,
            itemBuilder: (context, index) {
              final r = flattened[index];
              return _buildItemCard(
                header: '#${r.id} · ${r.name}',
                subtitle: '${r.area} · ${r.ageMonth}月龄',
                operation: r.operation,
                passCondition: r.passCondition,
                score: r.score,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar({required Widget left}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          left,
          const Spacer(),
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSection({required String header, required List<AssessmentItem> items}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...items.map((i) => _buildItemCard(
                  header: '#${i.id} · ${i.name}',
                  subtitle: null,
                  operation: i.operation,
                  passCondition: i.passCondition,
                  score: i.score,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard({
    required String header,
    String? subtitle,
    required String operation,
    required String passCondition,
    required double score,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
          const SizedBox(height: 8),
          _buildKeyValueRow('操作说明', operation),
          const SizedBox(height: 6),
          _buildKeyValueRow('通过标准', passCondition),
          const SizedBox(height: 6),
          _buildKeyValueRow('本题分数', score.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildKeyValueRow(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: Text(k, style: TextStyle(color: Colors.grey[800], fontSize: 12))),
        const SizedBox(width: 8),
        Expanded(child: Text(v, style: TextStyle(color: Colors.grey[900], fontSize: 12))),
      ],
    );
  }
}

class _ItemRow {
  final int id;
  final String name;
  final String operation;
  final String passCondition;
  final double score;
  final String area;
  final int ageMonth;

  _ItemRow({
    required this.id,
    required this.name,
    required this.operation,
    required this.passCondition,
    required this.score,
    required this.area,
    required this.ageMonth,
  });
}

