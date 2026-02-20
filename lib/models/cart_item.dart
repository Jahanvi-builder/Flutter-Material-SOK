import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  int quantity;
  final String? size;
  final List<String> addOns;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.size,
    this.addOns = const [],
  });

  double get subtotal => item.price * quantity;
}
