import 'package:flutter/material.dart';

Future<double?> showQtyEditor(
  BuildContext context,
  String title,
  double current, {
  double? maxValue,
}) {
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
                            temp = (temp - 1).clamp(0, maxValue ?? 9999);
                          });
                        },
                        icon: const Icon(Icons.remove_circle,size: 36),
                      ),
                      IconButton(
                        onPressed: () {
                          setSt(() {
                            temp = ((temp * 10 - 1) / 10).clamp(0, maxValue ?? 9999);
                            temp = double.parse(temp.toStringAsFixed(1));
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Column(
                        children: [
                          Text(
                            temp.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          if (maxValue != null && maxValue != double.infinity)
                            Text(
                              '最大: ${maxValue.toStringAsFixed(1)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          setSt(() {
                            temp = ((temp * 10 + 1) / 10).clamp(0, maxValue ?? 9999);
                            temp = double.parse(temp.toStringAsFixed(1));
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      IconButton(
                        onPressed: () {
                          setSt(() {
                            temp = (temp + 1).clamp(0, maxValue ?? 9999);
                          });
                        },
                        icon: const Icon(Icons.add_circle, size: 36),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(temp),
              child: const Text('確定', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );
    },
  );
}
