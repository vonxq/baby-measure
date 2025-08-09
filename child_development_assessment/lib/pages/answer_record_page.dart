import 'package:flutter/material.dart';
import '../models/test_result.dart';
import '../services/data_service.dart';
import '../models/assessment_data.dart';
import '../models/assessment_item.dart';
import '../utils/area_utils.dart';

class AnswerRecordPage extends StatefulWidget {
  const AnswerRecordPage({super.key, this.runtimeResult, this.historyId});

  final TestResult? runtimeResult; // 结果页直接跳转时传入
  final String? historyId; // 历史卡片跳转时传入

  @override
  State<AnswerRecordPage> createState() => _AnswerRecordPageState();
}

class _AnswerRecordPageState extends State<AnswerRecordPage> with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();

  bool _isLoading = true;
  String? _error;

  late TabController _tabController;

  List<AssessmentData> _allData = [];
  late Map<int, bool> _answers; // itemId -> passed

  // 快速跳转 section key
  final Map<int, GlobalKey> _ageSectionKeys = {};
  final Map<String, GlobalKey> _areaSectionKeys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _dataService.loadAssessmentData();
      Map<int, bool>? testResults;

      if (widget.runtimeResult != null) {
        testResults = widget.runtimeResult!.testResults;
      } else if (widget.historyId != null) {
        final list = await _dataService.loadTestResults();
        final found = list.firstWhere(
          (e) => e['id'] == widget.historyId,
          orElse: () => {},
        );
        if (found.isEmpty) {
          throw Exception('未找到对应的答题记录');
        }
        final raw = Map<String, dynamic>.from(found['testResults'] as Map);
        // JSON 反序列化后 key 可能是字符串，需要转为 int
        testResults = raw.map((k, v) => MapEntry(int.parse(k), v as bool));
      }

      if (testResults == null) {
        throw Exception('答题记录为空');
      }

      setState(() {
        _allData = data;
        _answers = testResults!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载答题记录失败：$e';
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
        title: const Text('答题记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '按月龄查看'),
            Tab(text: '按能区查看'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildByAgeView(),
                    _buildByAreaView(),
                  ],
                ),
    );
  }

  // =============== 按月龄查看 ===============
  Widget _buildByAgeView() {
    // 收集答题涉及到的月龄，升序
    final Set<int> ages = {};
    final Map<int, List<AssessmentItem>> ageToItems = {};

    for (final data in _allData) {
      for (final item in data.testItems) {
        if (_answers.containsKey(item.id)) {
          ages.add(data.ageMonth);
          ageToItems.putIfAbsent(data.ageMonth, () => []);
          ageToItems[data.ageMonth]!.add(item);
        }
      }
    }
    final sortedAges = ages.toList()..sort();

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(
            minExtent: 56,
            maxExtent: 56,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: sortedAges
                      .map((age) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text('$age 月龄'),
                              onPressed: () => _scrollToAge(age),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 8),
            ...sortedAges.map((age) {
              _ageSectionKeys.putIfAbsent(age, () => GlobalKey());
              final items = ageToItems[age]!..sort((a, b) => a.id.compareTo(b.id));
              return _buildAgeSection(age, items);
            }).toList(),
          ]),
        ),
      ],
    );
  }

  Widget _buildAgeSection(int age, List<AssessmentItem> items) {
    return Container(
      key: _ageSectionKeys[age],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${age}月龄', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...items.map(_buildAnswerItemCard),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToAge(int age) {
    final key = _ageSectionKeys[age];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 250),
        alignment: 0,
      );
    }
  }

  // =============== 按能区查看 ===============
  Widget _buildByAreaView() {
    final Map<String, List<_ItemWithAge>> areaToItems = {};
    for (final data in _allData) {
      for (final item in data.testItems) {
        if (_answers.containsKey(item.id)) {
          areaToItems.putIfAbsent(data.area, () => []);
          areaToItems[data.area]!.add(_ItemWithAge(item: item, age: data.ageMonth));
        }
      }
    }

    final areas = areaToItems.keys.toList()..sort();

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(
            minExtent: 56,
            maxExtent: 56,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: areas
                      .map((area) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(AreaUtils.displayName(area)),
                              onPressed: () => _scrollToArea(area),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 8),
            ...areas.map((area) {
              _areaSectionKeys.putIfAbsent(area, () => GlobalKey());
              final list = areaToItems[area]!..sort((a, b) {
                final c = a.age.compareTo(b.age);
                if (c != 0) return c;
                return a.item.id.compareTo(b.item.id);
              });
              return _buildAreaSection(area, list);
            }).toList(),
          ]),
        ),
      ],
    );
  }

  Widget _buildAreaSection(String area, List<_ItemWithAge> items) {
    return Container(
      key: _areaSectionKeys[area],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${AreaUtils.displayName(area)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...items.map((iwa) => _buildAnswerItemCard(iwa.item, subtitle: '${iwa.age}月龄')),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToArea(String area) {
    final key = _areaSectionKeys[area];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 250),
        alignment: 0,
      );
    }
  }

  // =============== 题目卡片（复用速查样式 + 背景区分） ===============
  Widget _buildAnswerItemCard(AssessmentItem item, {String? subtitle}) {
    final bool passed = _answers[item.id] ?? false;
    final Color bg = passed ? Colors.green[50]! : Colors.red[50]!;
    final Color border = passed ? Colors.green[200]! : Colors.red[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('#${item.id} · ${item.name}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
          const SizedBox(height: 8),
          _buildKeyValueRow('操作说明', item.operation),
          const SizedBox(height: 6),
          _buildKeyValueRow('通过标准', item.passCondition),
          const SizedBox(height: 6),
          _buildKeyValueRow('本题分数', item.score.toStringAsFixed(1)),
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

class _ItemWithAge {
  final AssessmentItem item;
  final int age;
  _ItemWithAge({required this.item, required this.age});
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.minExtent, required this.maxExtent, required this.child});

  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent || oldDelegate.child != child;
  }
}

