import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:async';
import '../widgets/ShowQtyEditor.dart';
import '../widgets/FortmatWeekday.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});
  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final ApiService api = ApiService();
  // Map<String, dynamic>? delivery;
  bool loading = false;
  Map<String, double> _plan = {}; // final_plan（可被編輯）
  Timer? _timer; // ✅ 宣告 Timer 變數
  String currentTime = '';
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _startClock(); // ✅ 啟動時鐘
    _loadDelivery();
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ 關閉 Timer，防止 setState() after dispose
    super.dispose();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // ✅ 確保 widget 還在畫面上
      final now = DateTime.now();
      final weekDays = ['一', '二', '三', '四', '五', '六', '日'];
      final weekDayName = weekDays[now.weekday - 1];
      setState(
        () => currentTime =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
            '(${weekDayName}) '
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      );
    });
  }

  Future<void> _loadDelivery() async {
    setState(() => loading = true);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dayISO = iso(tomorrow);
    final data = await api.computeDelivery(dayISO); // ✅ 後端自動判斷平/假日 & 天氣 & 扣剩料
    // data 結構：{ confirmed, date_type, weather, base_plan, leftovers_today, final_plan }
    final map = Map<String, dynamic>.from(data['final_plan']);
    _plan = map.map(
      (k, v) => MapEntry(
        k,
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0,
      ),
    );
    if (!mounted) return;
    setState(() {
      loading = false;
      confirmed = data['confirmed'] == true;
    });
  }

  Future<void> _confirm() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));  //日期隔天所以這裡加一天
    final dayISO = iso(tomorrow);
    await api.confirmDelivery(dayISO, _plan);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('提貨已確認，庫存已更新')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
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
                const Text('隔日提貨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  Icon(Icons.local_shipping, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  const Text('DELIVERY', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadDelivery,
            tooltip: '重新載入',
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
                            Icon(Icons.local_shipping, color: Colors.teal),
                            const SizedBox(width: 8),
                            const Text(
                              '隔日提貨計畫',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            if (confirmed) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '已確認',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          confirmed 
                              ? '提貨計畫已確認並鎖定，庫存已同步扣除'
                              : '點擊右側按鈕可調整提貨數量，確認後會扣除相應庫存',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._plan.entries.map((e) {
                  final name = e.key;
                  final qty = e.value;
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: confirmed 
                              ? Colors.green.shade100 
                              : Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          confirmed ? Icons.check_circle : Icons.local_shipping,
                          color: confirmed ? Colors.green : Colors.teal,
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
                        '提貨數量：${qty.toString()}',
                        style: TextStyle(
                          fontSize: 20,
                          color: confirmed ? Colors.green.shade700 : Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: confirmed ? null : ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('調整', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () async {
                          final edited = await showQtyEditor(
                            context,
                            '$name 提貨量',
                            qty,
                          );
                          if (edited != null) {
                            setState(() => _plan[name] = edited);
                          }
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: confirmed ? null : _confirm,
                  icon: Icon(confirmed ? Icons.check_circle : Icons.check),
                  label: Text(confirmed ? '提貨已確認' : '確認提貨計畫'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: confirmed ? Colors.grey : Colors.teal,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
