import 'package:flutter/material.dart';

import '../data/coupons.dart';
import 'cart_item.dart';
import 'menu_item.dart';

enum OrderType { dineIn, takeAway }

class CartController extends ChangeNotifier {
  CartController({required this.orderType});

  final OrderType orderType;
  final List<CartItem> _items = [];
  Coupon? _appliedCoupon;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity);
  double get subtotal => _items.fold(0.0, (sum, e) => sum + e.subtotal);
  double get discount => _items.fold(0.0, (sum, e) => sum +
      (e.item.originalPrice != null ? (e.item.originalPrice! - e.item.price) * e.quantity : 0.0));
  double get tax => subtotal * 0.05;
  Coupon? get appliedCoupon => _appliedCoupon;
  double get couponDiscount => _appliedCoupon?.savings(subtotal) ?? 0.0;
  double get total => subtotal + tax - couponDiscount;

  void applyCoupon(Coupon coupon) {
    _appliedCoupon = coupon;
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void add(MenuItem item, {String? size, List<String> addOns = const [], int quantity = 1}) {
    final idx = _items.indexWhere(
      (ci) => ci.item.id == item.id && ci.size == size,
    );
    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(CartItem(item: item, quantity: quantity, size: size, addOns: addOns));
    }
    notifyListeners();
  }

  void increment(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  void decrement(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      _items.remove(cartItem);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }
}
