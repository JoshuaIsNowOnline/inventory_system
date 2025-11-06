import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:async';
import '../widgets/FortmatWeekday.dart';
import '../widgets/ShowQtyEditor.dart';

class LeftoverPage extends StatefulWidget {
  const LeftoverPage({super.key});
  @override
  State<LeftoverPage> createState() => _LeftoverPageState();
}

class _LeftoverPageState extends State<LeftoverPage> {
  final api = ApiService();
  bool loading = true;
  String currentTime = '';
  Timer? _timer;

  // 控制器：品項 → TextController
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _startClock();
    _initData();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => currentTime = formatNowWithWeekday(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _initData() async {
    final today = DateTime.now();
    final todayISO = iso(today);

    // 1) 取得全部品項（用 inventory 的 key）
    final inv = await api.fetchInventory(); // {item: qty, ...}
    // 2) 取得今天已存的剩料
    final left = await api.getLeftovers(todayISO); // {item: qty, ...}

    // 過濾不需要計入剩料的品項
    final excludedItems = ['腸子', '蝦肉丸', '脆丸', '骨頭'];
    
    // 建立 controller，預設值為 left 中的數字或 0
    for (var name in inv.keys) {
      if (excludedItems.contains(name)) continue; // 跳過不需要的品項
      
      final v = (left[name] is num)
          ? (left[name] as num).toDouble()
          : double.tryParse('${left[name]}') ?? 0.0;
      _controllers[name] = TextEditingController(text: v.toString());
    }

    setState(() => loading = false);
  }

  Future<void> _updateLeftover(String name, double newQty) async {
    final controller = _controllers[name];
    if (controller != null) {
      controller.text = newQty.toString();
      await _save();
    }
  }

  Future<void> _save() async {
    try {
      final todayISO = iso(DateTime.now());
      final map = <String, double>{};

      // 讀取 TextField 的數字（空白或非法就當 0）
      _controllers.forEach((name, ctrl) {
        final v = double.tryParse(ctrl.text.trim()) ?? 0.0;
        map[name] = v;
      });

      await api.upsertLeftovers(todayISO, map);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('今日剩料已儲存')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('儲存失敗：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
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
                const Text('當日剩料', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  const Text('LEFTOVER', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 28),
            onPressed: _save,
            tooltip: '儲存剩料',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 標題卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              '當日剩料記錄',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '記錄今日各品項的剩餘數量，用於計算明日提貨量',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._controllers.entries.map((e) {
                  final name = e.key;
                  final controller = e.value;
                  final currentValue = double.tryParse(controller.text) ?? 0.0;
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: currentValue > 0 
                              ? Colors.green.shade100 
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          currentValue > 0 ? Icons.restaurant_menu : Icons.remove_circle_outline,
                          color: currentValue > 0 ? Colors.green : Colors.grey,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      subtitle: Text(
                        '剩料數量：${currentValue.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 20,
                          color: currentValue > 0 ? Colors.green.shade700 : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('調整', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () async {
                          final newQty = await showQtyEditor(
                            context, 
                            '$name 剩料數量', 
                            currentValue,
                          );
                          if (newQty != null) {
                            await _updateLeftover(name, newQty);
                          }
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('儲存全部剩料'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
