import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  bool _onlyWrong = false; // 是否仅显示未通过项
  double? _actualAge; // 实际月龄（用于超过实际月龄的错题提示）

  // 快速跳转 section key
  final Map<int, GlobalKey> _ageSectionKeys = {};
  final Map<String, GlobalKey> _areaSectionKeys = {};
  final ScrollController _ageScrollController = ScrollController();
  final ScrollController _areaScrollController = ScrollController();
  int? _currentAgeSection; // 当前高亮月龄（滚动模式遗留，不再用于渲染）
  String? _currentAreaSection; // 当前高亮能区（滚动模式遗留，不再用于渲染）
  int? _selectedAge; // 选中的月龄，仅展示该月龄
  String? _selectedArea; // 选中的能区，仅展示该能区
  bool _ageAnimating = false; // 按月龄视图是否在程序滚动中

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _load();
    // 重新启用按月龄视图的滚动监听
    _ageScrollController.addListener(_onAgeScroll);
    _areaScrollController.addListener(_onAreaScroll);
  }

  Future<void> _load() async {
    try {
      final data = await _dataService.loadAssessmentData();
      Map<int, bool>? testResults;

      if (widget.runtimeResult != null) {
        testResults = widget.runtimeResult!.testResults;
        _actualAge = widget.runtimeResult!.actualAge;
      } else if (widget.historyId != null) {
        final list = await _dataService.loadTestResults();
        final found = list.firstWhere(
          (e) => e['id'] == widget.historyId,
          orElse: () => {},
        );
        if (found.isEmpty) {
          throw Exception('未找到对应的测评记录');
        }
        final raw = Map<String, dynamic>.from(found['testResults'] as Map);
        // JSON 反序列化后 key 可能是字符串，需要转为 int
        testResults = raw.map((k, v) => MapEntry(int.parse(k), v as bool));
        _actualAge = (found['actualAge'] as num?)?.toDouble();
      }

      if (testResults == null) {
        throw Exception('测评记录为空');
      }

      setState(() {
        _allData = data;
        _answers = testResults!;
        _isLoading = false;
      });
      // 初始化选择项
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureValidSelections(forceReset: true);
      });
    } catch (e) {
      setState(() {
        _error = '加载测评记录失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _ageScrollController.dispose();
    _areaScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测评记录'),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _onlyWrong = !_onlyWrong),
            icon: Icon(
              _onlyWrong ? Icons.filter_alt : Icons.filter_alt_off,
              color: _onlyWrong ? Colors.red[600] : Colors.grey[700],
              size: 18,
            ),
            label: Text(
              _onlyWrong ? '仅看未通过项' : '查看全部',
              style: TextStyle(
                fontSize: 12,
                color: _onlyWrong ? Colors.red[600] : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                  physics: const NeverScrollableScrollPhysics(),
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
        final bool? passed = _answers[item.id];
        if (passed != null && (!_onlyWrong || passed == false)) {
          ages.add(data.ageMonth);
          ageToItems.putIfAbsent(data.ageMonth, () => []);
          ageToItems[data.ageMonth]!.add(item);
        }
      }
    }
    final sortedAges = ages.toList()..sort();

    if (sortedAges.isEmpty) {
      return Center(child: Text(_onlyWrong ? '暂无未通过项' : '暂无测评记录'));
    }

    return CustomScrollView(
      controller: _ageScrollController,
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
                              backgroundColor: _selectedAge == age ? Colors.blue[50] : null,
                              shape: StadiumBorder(side: BorderSide(color: _selectedAge == age ? Colors.blue[200]! : Colors.grey[300]!)),
                              label: Text('$age 月龄', style: TextStyle(color: _selectedAge == age ? Colors.blue[700] : null)),
                              onPressed: () => setState(() => _selectedAge = age),
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
            () {
              final int selected = (_selectedAge != null && sortedAges.contains(_selectedAge))
                  ? _selectedAge!
                  : sortedAges.first;
              _ageSectionKeys.putIfAbsent(selected, () => GlobalKey());
              final List<AssessmentItem> items =
                  List<AssessmentItem>.from(ageToItems[selected] ?? const <AssessmentItem>[]);
              items.sort((a, b) => a.id.compareTo(b.id));
              return _buildAgeSection(selected, items);
            }(),
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
              ...items.map((it) => _buildAnswerItemCard(it, area: it.area, ageMonth: age)),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToAge(int age) {
  final key = _ageSectionKeys[age];
  if (key?.currentContext == null) return;
  final renderObject = key!.currentContext!.findRenderObject();
  if (renderObject == null) return;
  final viewport = RenderAbstractViewport.of(renderObject);
  if (viewport == null) return;

  final currentOffset = _ageScrollController.hasClients ? _ageScrollController.offset : 0.0;
  final topAlignOffset = viewport.getOffsetToReveal(renderObject, 0).offset - 56; // 顶对齐
  final bottomAlignOffset = viewport.getOffsetToReveal(renderObject, 1).offset; // 底对齐

  // 优先选择能让目标可见的偏移量
  double targetOffset = (currentOffset < topAlignOffset) ? topAlignOffset : bottomAlignOffset;
  targetOffset = targetOffset.clamp(0.0, _ageScrollController.position.maxScrollExtent);

  _ageAnimating = true;
  final before = currentOffset;
  _ageScrollController
      .animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      )
      .whenComplete(() async {
    // 若位移过小，回退使用 ensureVisible 兜底
    final after = _ageScrollController.hasClients ? _ageScrollController.offset : before;
    if ((after - before).abs() < 1.0) {
      try {
        await Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          alignment: 0.5,  // 改为居中
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      } catch (_) {}
    }
    _ageAnimating = false;
    if (mounted) setState(() => _currentAgeSection = age);
  });
}
  // =============== 按能区查看 ===============
  Widget _buildByAreaView() {
    final Map<String, List<_ItemWithAge>> areaToItems = {};
    for (final data in _allData) {
      for (final item in data.testItems) {
        final bool? passed = _answers[item.id];
        if (passed != null && (!_onlyWrong || passed == false)) {
          areaToItems.putIfAbsent(data.area, () => []);
          areaToItems[data.area]!.add(_ItemWithAge(item: item, age: data.ageMonth));
        }
      }
    }

    final areas = areaToItems.keys.toList()..sort();

    if (areas.isEmpty) {
      return Center(child: Text(_onlyWrong ? '暂无未通过项' : '暂无测评记录'));
    }

    return CustomScrollView(
      controller: _areaScrollController,
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
                              backgroundColor: _selectedArea == area ? Colors.blue[50] : null,
                              shape: StadiumBorder(side: BorderSide(color: _selectedArea == area ? Colors.blue[200]! : Colors.grey[300]!)),
                              label: Text(AreaUtils.displayName(area), style: TextStyle(color: _selectedArea == area ? Colors.blue[700] : null)),
                              onPressed: () => setState(() => _selectedArea = area),
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
            () {
              final String selected = (_selectedArea != null && areas.contains(_selectedArea))
                  ? _selectedArea!
                  : areas.first;
              _areaSectionKeys.putIfAbsent(selected, () => GlobalKey());
              final List<_ItemWithAge> list =
                  List<_ItemWithAge>.from(areaToItems[selected] ?? const <_ItemWithAge>[]);
              list.sort((a, b) {
                final c = a.age.compareTo(b.age);
                if (c != 0) return c;
                return a.item.id.compareTo(b.item.id);
              });
              return _buildAreaSection(selected, list);
            }(),
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
              ...items.map((iwa) => _buildAnswerItemCard(iwa.item, area: area, ageMonth: iwa.age)),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToArea(String area) {
    final key = _areaSectionKeys[area];
    if (key?.currentContext == null) return;
    final renderObject = key!.currentContext!.findRenderObject();
    if (renderObject == null) return;
    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return;
    final target = viewport.getOffsetToReveal(renderObject, 0).offset - 56;
    final clamped = target.clamp(0.0, _areaScrollController.position.maxScrollExtent);
    _areaScrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(milliseconds: 320), _updateCurrentAreaSection);
  }

  // =============== 题目卡片（复用速查样式 + 背景区分） ===============
  Widget _buildAnswerItemCard(AssessmentItem item, {String? subtitle, int? ageMonth, String? area}) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '#${item.id} · ${item.name}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              if (area != null && ageMonth != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    '${AreaUtils.displayName(area)} · ${ageMonth}月龄',
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                ),
            ],
          ),
          if (item.name.contains('R') || item.name.contains('*')) ...[
            const SizedBox(height: 6),
            _buildSpecialMarkerTips(item.name),
          ],
          const SizedBox(height: 8),
          _buildKeyValueRow('操作说明', item.operation),
          const SizedBox(height: 6),
          _buildKeyValueRow('通过标准', item.passCondition),
          const SizedBox(height: 6),
          if (!passed && ageMonth != null && _actualAge != null && ageMonth > _actualAge!) ...[
            _buildBeyondAgeReassureTip(),
            const SizedBox(height: 6),
          ],
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

  // 特殊标记提示（与速查一致）
  Widget _buildSpecialMarkerTips(String name) {
    List<Widget> tips = [];

    if (name.contains('R')) {
      tips.add(_buildTipItem(
        icon: Icons.family_restroom,
        iconColor: Colors.blue[600]!,
        backgroundColor: Colors.blue[50]!,
        borderColor: Colors.blue[200]!,
        title: 'R 标记说明',
        content: '该项目的表现可以通过询问家长获得',
      ));
    }

    if (name.contains('*')) {
      tips.add(_buildTipItem(
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange[600]!,
        backgroundColor: Colors.orange[50]!,
        borderColor: Colors.orange[200]!,
        title: '* 标记说明',
        content: '该项目如果未通过需要引起注意',
      ));
    }

    return Column(
      children: tips
          .map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: tip,
              ))
          .toList(),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 超出实际月龄的未通过项安心提示
  Widget _buildBeyondAgeReassureTip() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '该项目属于超出宝宝实际月龄的测查，不通过并不代表异常，属正常测试过程，请不必担心。',
              style: TextStyle(fontSize: 12, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _onAgeScroll() {
    if (_ageAnimating) return;
    _updateCurrentAgeSection();
  }

  void _onAreaScroll() {
    _updateCurrentAreaSection();
  }

  void _onTabChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureValidSelections();
    });
  }

  void _resetHighlightForActiveTab({bool forceTop = false}) {
    // 兼容旧逻辑占位，已不使用滚动高亮
  }

  void _ensureValidSelections({bool forceReset = false}) {
    if (_tabController.index == 0) {
      if (forceReset || _selectedAge == null) {
        if (_ageSectionKeys.isNotEmpty) {
          final ages = _ageSectionKeys.keys.toList()..sort();
          setState(() => _selectedAge = ages.first);
        }
      }
    } else {
      if (forceReset || _selectedArea == null) {
        if (_areaSectionKeys.isNotEmpty) {
          final areas = _areaSectionKeys.keys.toList()..sort();
          setState(() => _selectedArea = areas.first);
        }
      }
    }
  }

  void _updateCurrentAgeSection() {
    if (_ageSectionKeys.isEmpty) return;
    int? nearest;
    double minDy = double.infinity;
    _ageSectionKeys.forEach((age, key) {
      final ctx = key.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return;
      final pos = box.localToGlobal(Offset.zero);
      final dy = (pos.dy - kToolbarHeight - 56).abs(); // 距离顶部 pinned header 的距离
      if (dy < minDy) {
        minDy = dy;
        nearest = age;
      }
    });
    if (nearest != null && nearest != _currentAgeSection) {
      setState(() => _currentAgeSection = nearest);
    }
  }

  void _updateCurrentAreaSection() {
    if (_areaSectionKeys.isEmpty) return;
    String? nearest;
    double minDy = double.infinity;
    _areaSectionKeys.forEach((area, key) {
      final ctx = key.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return;
      final pos = box.localToGlobal(Offset.zero);
      final dy = (pos.dy - kToolbarHeight - 56).abs();
      if (dy < minDy) {
        minDy = dy;
        nearest = area;
      }
    });
    if (nearest != null && nearest != _currentAreaSection) {
      setState(() => _currentAreaSection = nearest);
    }
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

