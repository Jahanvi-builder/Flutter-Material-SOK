import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  int quantity;
  final String? size;
  final List<String> addOns;
  final Map<String, List<String>> selectedCustomizations;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.size,
    this.addOns = const [],
    this.selectedCustomizations = const {},
  });

  double get unitPrice =>
      item.price + item.customizationPrice(selectedCustomizations);
  double get subtotal => unitPrice * quantity;

  List<String> get customizationSummary => [
    ?size,
    ...addOns,
    ...item.customizationSummary(selectedCustomizations),
  ];

  bool get hasCustomizations => customizationSummary.isNotEmpty;

  CartItem copyWith({
    MenuItem? item,
    int? quantity,
    String? size,
    List<String>? addOns,
    Map<String, List<String>>? selectedCustomizations,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      addOns: addOns ?? this.addOns,
      selectedCustomizations:
          selectedCustomizations ?? this.selectedCustomizations,
    );
  }
}
