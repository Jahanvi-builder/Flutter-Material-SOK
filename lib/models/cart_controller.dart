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
  String? _tableToken;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity);
  double get subtotal => _items.fold(0.0, (sum, e) => sum + e.subtotal);
  double get discount => _items.fold(
    0.0,
    (sum, e) =>
        sum +
        (e.item.originalPrice != null
            ? (e.item.originalPrice! - e.item.price) * e.quantity
            : 0.0),
  );
  double get tax => subtotal * 0.05;
  Coupon? get appliedCoupon => _appliedCoupon;
  double get couponDiscount => _appliedCoupon?.savings(subtotal) ?? 0.0;
  double get total => subtotal + tax - couponDiscount;
  String? get tableToken => _tableToken;

  void applyCoupon(Coupon coupon) {
    _appliedCoupon = coupon;
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void setTableToken(String? token) {
    _tableToken = token;
    notifyListeners();
  }

  void add(
    MenuItem item, {
    String? size,
    List<String> addOns = const [],
    Map<String, List<String>> selectedCustomizations = const {},
    int quantity = 1,
  }) {
    final idx = _items.indexWhere(
      (ci) => _matchesConfiguration(
        ci,
        item: item,
        size: size,
        addOns: addOns,
        selectedCustomizations: selectedCustomizations,
      ),
    );

    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          item: item,
          quantity: quantity,
          size: size,
          addOns: List.unmodifiable(addOns),
          selectedCustomizations: _normalizeSelections(selectedCustomizations),
        ),
      );
    }
    notifyListeners();
  }

  void updateItem(
    CartItem cartItem, {
    String? size,
    List<String> addOns = const [],
    Map<String, List<String>> selectedCustomizations = const {},
    int? quantity,
  }) {
    final existingIndex = _items.indexOf(cartItem);
    if (existingIndex < 0) return;

    final updated = cartItem.copyWith(
      quantity: quantity ?? cartItem.quantity,
      size: size,
      addOns: List.unmodifiable(addOns),
      selectedCustomizations: _normalizeSelections(selectedCustomizations),
    );

    final duplicateIndex = _items.indexWhere(
      (ci) => !identical(ci, cartItem) && _sameConfiguration(ci, updated),
    );

    if (duplicateIndex >= 0) {
      _items[duplicateIndex].quantity += updated.quantity;
      _items.removeAt(existingIndex);
    } else {
      _items[existingIndex] = updated;
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
    _tableToken = null;
    notifyListeners();
  }

  bool _matchesConfiguration(
    CartItem cartItem, {
    required MenuItem item,
    String? size,
    List<String> addOns = const [],
    Map<String, List<String>> selectedCustomizations = const {},
  }) {
    return cartItem.item.id == item.id &&
        cartItem.size == size &&
        _sameStringList(cartItem.addOns, addOns) &&
        _sameSelections(
          cartItem.selectedCustomizations,
          selectedCustomizations,
        );
  }

  bool _sameConfiguration(CartItem a, CartItem b) {
    return a.item.id == b.item.id &&
        a.size == b.size &&
        _sameStringList(a.addOns, b.addOns) &&
        _sameSelections(a.selectedCustomizations, b.selectedCustomizations);
  }

  bool _sameSelections(
    Map<String, List<String>> a,
    Map<String, List<String>> b,
  ) {
    final keys = {...a.keys, ...b.keys};
    for (final key in keys) {
      if (!_sameStringList(
        a[key] ?? const <String>[],
        b[key] ?? const <String>[],
      )) {
        return false;
      }
    }
    return true;
  }

  bool _sameStringList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Map<String, List<String>> _normalizeSelections(
    Map<String, List<String>> selections,
  ) {
    return Map<String, List<String>>.unmodifiable({
      for (final entry in selections.entries)
        entry.key: List<String>.unmodifiable(entry.value),
    });
  }
}
