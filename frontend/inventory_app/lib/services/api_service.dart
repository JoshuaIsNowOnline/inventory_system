import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 根據平台選擇正確的 URL
  String get baseUrl {
    // 🌐 使用 Render 雲端部署的 API
    return 'https://inventory-system-api-wu21.onrender.com';
    
    // 💡 本地開發時可以切換為以下配置：
    // if (kIsWeb) {
    //   return 'http://127.0.0.1:8000';
    // } else if (Platform.isAndroid) {
    //   return 'http://10.0.2.2:8000';
    // } else {
    //   return 'http://127.0.0.1:8000';
    // }
  }

  // 更新危險量
  Future<void> updateDangerLevels(Map<String, double> dangerLevels) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory/danger'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dangerLevels),
    );
    if (response.statusCode != 200) {
      throw Exception('更新危險量失敗');
    }
  }

  // 取得庫存
  Future<Map<String, dynamic>> fetchInventory() async {
    final response = await http.get(Uri.parse('$baseUrl/inventory'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('取得庫存失敗');
    }
  }

  // 更新庫存
  Future<Map<String, dynamic>> updateInventory(
    Map<String, dynamic> updates,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'updates': updates}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('更新庫存失敗');
    }
  }

  // 取得剩料
  Future<Map<String, dynamic>> getLeftovers(String dayISO) async {
    final r = await http.get(Uri.parse('$baseUrl/leftovers/$dayISO'));
    if (r.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(r.body));
    }
    throw Exception('取得剩料失敗');
  }

  // 更新剩料
  Future<Map<String, dynamic>> upsertLeftovers(
    String dayISO,
    Map<String, dynamic> leftovers,
  ) async {
    final r = await http.post(
      Uri.parse('$baseUrl/leftovers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'day': dayISO, 'leftovers': leftovers}),
    );
    if (r.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(r.body));
    }
    throw Exception('更新剩料失敗');
  }

  // 計算提貨計畫
  Future<Map<String, dynamic>> computeDelivery(
    String dayISO, {
    String? weather,
    double safety = 1.0,
  }) async {
    final body = {'day': dayISO, 'safety_factor': safety};
    if (weather != null) body['weather'] = weather;
    final r = await http.post(
      Uri.parse('$baseUrl/delivery'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (r.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(r.body));
    }
    throw Exception('取得提貨失敗');
  }

  // 確認提貨
  Future<Map<String, dynamic>> confirmDelivery(
    String dayISO,
    Map<String, dynamic> items,
  ) async {
    final r = await http.post(
      Uri.parse('$baseUrl/delivery/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'day': dayISO, 'items': items}),
    );
    if (r.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(r.body));
    }
    throw Exception('確認提貨失敗');
  }

  // 取得排程
  Future<List<dynamic>> fetchSchedule() async {
    final response = await http.get(Uri.parse('$baseUrl/schedule'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('無法取得排程');
    }
  }

  // 完成排程任務
  Future<void> completeTask(int id) async {
    final r = await http.post(Uri.parse('$baseUrl/schedule/complete/$id'));
    if (r.statusCode != 200) throw Exception('完成失敗');
  }

  // 刪除排程任務
  Future<void> deleteTask(int id) async {
    final r = await http.post(Uri.parse('$baseUrl/schedule/delete/$id'));
    if (r.statusCode != 200) throw Exception('刪除失敗');
  }

  // 移動排程任務到不同星期幾
  Future<void> moveTask(int id, String newWeekday) async {
    final r = await http.post(
      Uri.parse('$baseUrl/schedule/move/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'new_weekday': newWeekday}),
    );
    if (r.statusCode != 200) throw Exception('移動失敗');
  }

  // 更新排程任務數量
  Future<void> updateTaskQty(int id, double newQty) async {
    final r = await http.post(
      Uri.parse('$baseUrl/schedule/update_qty/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'new_qty': newQty}),
    );
    if (r.statusCode != 200) throw Exception('更新數量失敗');
  }
}
