import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/FortmatWeekday.dart';
import '../widgets/ShowQtyEditor.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final api = ApiService();
  bool loading = false;
  Map<String, dynamic>? inventory;
  String currentTime = '';
  Timer? _timer;

  // 紀錄哪個品項展開設定區
  String? expandedItem;

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadInventory();
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

  Future<void> _loadInventory() async {
    setState(() => loading = true);
    final data = await api.fetchInventory();
    if (!mounted) return;
    setState(() {
      inventory = data; // {魚肚: {qty:8, danger_level:5}, ...}
      loading = false;
    });
  }

  Future<void> _updateItem(String name, double newQty) async {
    try {
      await api.updateInventory({name: newQty});
      await _loadInventory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已更新 $name 庫存為 ${newQty.toStringAsFixed(1)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失敗：$e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
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
                const Text('庫存管理', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  Icon(Icons.inventory, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  const Text('INVENTORY', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadInventory,
            tooltip: '重新載入',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : inventory == null
              ? const Center(child: Text("沒有庫存資料"))
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
                                Icon(Icons.inventory, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  '庫存管理',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '點擊右側按鈕可調整庫存數量',
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
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDanger ? Colors.red.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              isDanger ? Icons.warning : Icons.inventory_2,
                              color: isDanger ? Colors.red : Colors.blue,
                              size: 28,
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
                              const SizedBox(height: 6),
                              Text(
                                '目前庫存：${qty.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isDanger ? Colors.red.shade700 : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '危險警戒值：${danger.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 20),
                            label: const Text('調整庫存', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(100, 44),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () async {
                              final newQty = await showQtyEditor(
                                context, 
                                '$name 庫存量', 
                                qty,
                              );
                              if (newQty != null) {
                                await _updateItem(name, newQty);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
    );
  }
}
