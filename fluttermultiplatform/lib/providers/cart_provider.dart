import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  CartProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cronos_cart');
    if (cartJson != null) {
      final List<dynamic> list = jsonDecode(cartJson);
      _items = list.map((e) => CartItem.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cronos_cart', jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void addItem(Product product, [int quantity = 1]) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _saveToStorage();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      _items[idx].quantity = quantity < 1 ? 1 : quantity;
      _saveToStorage();
      notifyListeners();
    }
  }

  void clearCart() {
    _items = [];
    _saveToStorage();
    notifyListeners();
  }

  void clear() => clearCart();

  double get totalAmount => _items.fold(0, (sum, i) => sum + i.product.price * i.quantity);
  double get totalPrice => totalAmount;
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);
}
