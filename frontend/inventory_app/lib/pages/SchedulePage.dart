import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/FortmatWeekday.dart';
import '../widgets/ShowDangerEditor.dart';
import '../widgets/ShowQtyEditor.dart';


class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final api = ApiService();
  bool loading = true;
  String currentTime = '';
  Timer? _timer;
  bool showDangerSettings = false; // 新增：控制是否顯示危險量設定模式
  Map<String, dynamic>? inventory; // 新增：存儲庫存資料

  // 依 weekday 分組的列表：Monday..Sunday
  final List<String> weekdaysEn = const ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  final Map<String, List<Map<String, dynamic>>> grouped = {
    "Monday": [], "Tuesday": [], "Wednesday": [], "Thursday": [], "Friday": [], "Saturday": [], "Sunday": []
  };

  @override
  void initState() {
    super.initState();
    _startClock();
    _load();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        currentTime = formatNowWithWeekday(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      if (mounted) setState(() => loading = true);
      final list = await api.fetchSchedule(); // [{id,weekday,task,item,qty,done}, ...]
      // 清空
      grouped.forEach((k, v) => v.clear());
      // 分組
      for (final t in list) {
        final wd = (t['weekday'] ?? '').toString();
        if (grouped.containsKey(wd)) {
          grouped[wd]!.add(Map<String, dynamic>.from(t));
        }
      }
    } catch (e) {
      debugPrint('load schedule error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadInventory() async {
    try {
      final data = await api.fetchInventory();
      if (mounted) {
        setState(() {
          inventory = data; // {魚肚: {qty:8, danger_level:5}, ...}
        });
      }
    } catch (e) {
      debugPrint('load inventory error: $e');
    }
  }

  Future<void> _updateDangerLevel(String item, double newDanger) async {
    try {
      await api.updateDangerLevels({item: newDanger});
      await _loadInventory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已更新 $item 的危險量為 ${newDanger.toStringAsFixed(1)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失敗：$e')),
      );
    }
  }

  Future<void> _complete(int id) async {
    try {
      await api.completeTask(id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('任務完成，庫存已更新')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('完成失敗：$e')));
    }
  }

  Future<void> _updateTaskQty(int id, double newQty) async {
    try {
      await api.updateTaskQty(id, newQty);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('任務數量已更新')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新失敗：$e')));
    }
  }

  Future<void> _moveTask(int id, String newWeekday) async {
    try {
      await api.moveTask(id, newWeekday);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('任務已移動')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('移動失敗：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final zh = const ['一','二','三','四','五','六','日'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: showDangerSettings ? Colors.orange.shade600 : Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentTime, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                Text(
                  showDangerSettings ? '安全量設定' : '工作排程', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showDangerSettings ? Icons.warning : Icons.calendar_today, 
                    color: Colors.white, 
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    showDangerSettings ? 'SAFETY' : 'SCHEDULE', 
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              showDangerSettings ? Icons.schedule : Icons.warning, 
              size: 28,
            ),
            onPressed: () async {
              if (!showDangerSettings) {
                await _loadInventory(); // 切換到危險量設定時載入庫存資料
              }
              setState(() {
                showDangerSettings = !showDangerSettings;
              });
            },
            tooltip: showDangerSettings ? '返回排程' : '安全量設定',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _load,
            tooltip: '重新載入',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : showDangerSettings
              ? _buildDangerSettingsView()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // 手機版 (寬度小於600px) 使用單欄布局
                    final isMobile = constraints.maxWidth < 600;
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: weekdaysEn.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2, 
                        crossAxisSpacing: 8, 
                        mainAxisSpacing: 8, 
                        childAspectRatio: isMobile ? 2.5 : 1.15,  // 手機版用更寬的比例
                      ),
                      itemBuilder: (ctx, i) {
                final wdEn = weekdaysEn[i];
                final tasks = grouped[wdEn]!;
                return DragTarget<Map<String, dynamic>>(
                  onAccept: (task) {
                    // 移動任務到這個星期幾
                    final taskId = (task['id'] as num).toInt();
                    _moveTask(taskId, wdEn);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHighlighted = candidateData.isNotEmpty;
                    return Card(
                      elevation: isHighlighted ? 8 : 3,
                      color: isHighlighted ? Colors.blue.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('星期${zh[i]}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                if (isHighlighted) 
                                  const Icon(Icons.add, color: Colors.blue),
                              ],
                            ),
                            const Divider(),
                            Expanded(
                              child: tasks.isEmpty
                                  ? Center(
                                      child: Text(
                                        isHighlighted ? '拖曳到此處' : '— 無任務 —', 
                                        style: TextStyle(
                                          color: isHighlighted ? Colors.blue : Colors.grey,
                                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: tasks.length,
                                      itemBuilder: (ctx, j) {
                                        final t = tasks[j];
                                        final id = (t['id'] as num).toInt();
                                        final rawTitle = t['task']?.toString() ?? '';
                                        final item = t['item']?.toString() ?? '';
                                        final qty = (t['qty'] is num) ? (t['qty'] as num).toDouble() : double.tryParse('${t['qty']}') ?? 0.0;
                                        final done = t['done'] == true;
                                        
                                        // 移除 "製作" 並簡化顯示
                                        String title = rawTitle.replaceAll('製作 ', '');
                                        // 如果 title 包含品項名稱，移除重複的品項資訊
                                        if (title.contains(item) && item.isNotEmpty) {
                                          title = title.replaceAll(item, '').trim();
                                          // 移除多餘的空格和標點
                                          title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
                                        }
                                        
                                        return LongPressDraggable<Map<String, dynamic>>(
                                          data: t,
                                          delay: const Duration(milliseconds: 500), // 防止意外拖拽
                                          feedback: Material(
                                            elevation: 8,
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              width: 200,
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(title.isNotEmpty ? title : item, 
                                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                                  Text('品項：$item', 
                                                      style: const TextStyle(fontSize: 12)),
                                                  Text('數量：${qty.toStringAsFixed(1)}', 
                                                      style: const TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text('移動中...', style: TextStyle(color: Colors.grey)),
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: done ? Colors.green.shade50 : Colors.white,
                                              border: Border.all(color: done ? Colors.green.shade200 : Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.drag_handle, size: 16, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        title.isNotEmpty ? title : item,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600,
                                                          decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text('品項：$item',
                                                          style: const TextStyle(fontSize: 16, color: Colors.black87)),
                                                      Text('數量：${qty.toStringAsFixed(1)}',
                                                          style: const TextStyle(fontSize: 16, color: Colors.black87)),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      tooltip: '完成',
                                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                                      onPressed: () => _complete(id),
                                                    ),
                                                    IconButton(
                                                      tooltip: '編輯數量',
                                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                                      onPressed: () async {
                                                        final newQty = await showQtyEditor(
                                                          context, 
                                                          '調整 $title 數量', 
                                                          qty,
                                                        );
                                                        if (newQty != null) {
                                                          await _updateTaskQty(id, newQty);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
                    );
                  },
                ),
    );
  }

  Widget _buildDangerSettingsView() {
    if (inventory == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('載入庫存資料中...'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      '安全庫存量設定',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '當庫存低於安全量時，會在庫存頁面以紅色標示警告',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...inventory!.entries.map((entry) {
          final name = entry.key;
          final data = entry.value;
          final qty = (data['qty'] as num).toDouble();
          final danger = (data['danger_level'] as num).toDouble();
          final isDanger = qty < danger;

          return Card(
            color: isDanger ? Colors.red.shade50 : Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDanger ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isDanger ? Icons.warning : Icons.check_circle,
                  color: isDanger ? Colors.red : Colors.green,
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: isDanger ? Colors.red.shade800 : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '目前庫存：${qty.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '安全量：${danger.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('調整', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () async {
                  final newDanger = await showDangerEditor(
                    context, 
                    '$name 安全量', 
                    danger,
                  );
                  if (newDanger != null) {
                    await _updateDangerLevel(name, newDanger);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}