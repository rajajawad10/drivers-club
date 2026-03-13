import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pitstop/features/member_portal/domain/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  static const String _prefsKey = 'cart_items';
  final List<CartItem> _items = [];

  CartProvider() {
    _loadCartFromPrefs();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalCount => _items.fold(0, (total, item) => total + item.quantity);

  double get totalPrice => _items.fold(
        0,
        (total, item) => total + (item.price * item.quantity),
      );

  void addItem(CartItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    _saveCartToPrefs();
    notifyListeners();
  }

  void increaseQty(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) {
      return;
    }
    _items[index].quantity += 1;
    _saveCartToPrefs();
    notifyListeners();
  }

  void decreaseQty(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) {
      return;
    }
    if (_items[index].quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index].quantity -= 1;
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCartToPrefs();
    notifyListeners();
  }

  void clear() {
    clearCart();
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((item) => item.toMap()).toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        _items
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((item) => CartItem.fromMap(Map<String, dynamic>.from(item))),
          );
        notifyListeners();
      }
    } catch (_) {
      // Ignore corrupted data to avoid crashing the app.
    }
  }
}
