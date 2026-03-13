import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pitstop/core/models/order_record.dart';

class OrderHistoryProvider extends ChangeNotifier {
  static const String _prefsKey = 'order_history';
  final List<OrderRecord> _orders = [];

  OrderHistoryProvider() {
    _loadFromPrefs();
  }

  List<OrderRecord> get orders => List.unmodifiable(_orders);

  Future<void> addOrder(OrderRecord order) async {
    _orders.insert(0, order);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _orders.map((order) => order.toMap()).toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        _orders
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((item) => OrderRecord.fromMap(Map<String, dynamic>.from(item))),
          );
        notifyListeners();
      }
    } catch (_) {
      // Ignore corrupted data to avoid crashing the app.
    }
  }
}
