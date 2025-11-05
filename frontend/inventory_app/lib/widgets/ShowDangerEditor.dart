import 'package:flutter/material.dart';

Future<double?> showDangerEditor(
  BuildContext context,
  String title,
  double current,
) {
  double temp = current;
  return showModalBottomSheet<double>(
    context: context,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '設定危險庫存警戒值',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatefulBuilder(
                  builder: (ctx, setSt) => Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setSt(() {
                            temp = (temp - 1).clamp(0, 9999);
                          });
                        },
                        icon: const Icon(Icons.remove_circle, size: 36, color: Colors.red),
                      ),
                      IconButton(
                        onPressed: () {
                          setSt(() {
                            temp = ((temp * 10 - 1) / 10).clamp(0, 9999);
                            temp = double.parse(temp.toStringAsFixed(1));
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.orange.shade50,
                        ),
                        child: Text(
                          temp.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setSt(() {
                            temp = (temp * 10 + 1) / 10;
                            temp = double.parse(temp.toStringAsFixed(1));
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () {
                          setSt(() {
                            temp = (temp + 1);
                          });
                        },
                        icon: const Icon(Icons.add_circle, size: 36, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '當庫存低於此值時會標示為危險狀態',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('取消', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(temp),
                    child: const Text('確定', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}