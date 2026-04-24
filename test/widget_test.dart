import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sok_material/models/cart_controller.dart';
import 'package:sok_material/models/menu_item.dart';

void main() {
  const vegHakkaNoodles = MenuItem(
    id: 'IC_010',
    name: 'Veg Hakka Noodles',
    description: 'Classic stir-fried noodles with julienne veggies.',
    price: 180,
    category: 'Indo-Chinese',
    subCategory: 'Noodles',
    isVeg: true,
    spiceLevel: 1,
    prepTime: '12 mins',
    imagePath: 'images/Food/Chinese/hakka_noodles.jpg',
    icon: Icons.ramen_dining,
    color: Color(0xFF9575CD),
    customizationGroups: [
      MenuItemCustomizationGroup(
        id: 'spice',
        title: 'Spice Level',
        selectionType: CustomOptionSelectionType.single,
        defaultOptionIds: ['medium'],
        options: [
          MenuItemOption(id: 'mild', label: 'Mild'),
          MenuItemOption(id: 'medium', label: 'Medium'),
          MenuItemOption(id: 'spicy', label: 'Spicy'),
        ],
      ),
      MenuItemCustomizationGroup(
        id: 'portion',
        title: 'Portion',
        selectionType: CustomOptionSelectionType.single,
        defaultOptionIds: ['regular'],
        options: [
          MenuItemOption(id: 'regular', label: 'Regular'),
          MenuItemOption(id: 'large', label: 'Large', priceDelta: 40),
        ],
      ),
      MenuItemCustomizationGroup(
        id: 'extras',
        title: 'Add Extras',
        selectionType: CustomOptionSelectionType.multiple,
        options: [
          MenuItemOption(
            id: 'extra_veggies',
            label: 'Extra Veggies',
            priceDelta: 30,
          ),
          MenuItemOption(id: 'paneer', label: 'Paneer', priceDelta: 50),
        ],
      ),
    ],
  );

  group('Cart customization logic', () {
    test('calculates unit price and summary for structured customizations', () {
      final cart = CartController(orderType: OrderType.dineIn);

      cart.add(
        vegHakkaNoodles,
        selectedCustomizations: const {
          'spice': ['spicy'],
          'portion': ['large'],
          'extras': ['paneer', 'extra_veggies'],
        },
      );

      expect(cart.items, hasLength(1));
      expect(cart.items.single.unitPrice, 300);
      expect(cart.items.single.customizationSummary, [
        'Spicy',
        'Large',
        'Paneer',
        'Extra Veggies',
      ]);
    });

    test('merges identical configurations and separates different ones', () {
      final cart = CartController(orderType: OrderType.dineIn);

      cart.add(
        vegHakkaNoodles,
        selectedCustomizations: const {
          'spice': ['medium'],
          'portion': ['regular'],
        },
      );
      cart.add(
        vegHakkaNoodles,
        selectedCustomizations: const {
          'spice': ['medium'],
          'portion': ['regular'],
        },
      );
      cart.add(
        vegHakkaNoodles,
        selectedCustomizations: const {
          'spice': ['spicy'],
          'portion': ['regular'],
        },
      );

      expect(cart.items, hasLength(2));
      expect(cart.items.first.quantity, 2);
      expect(cart.items.last.quantity, 1);
    });

    test('editing can merge into an existing cart line', () {
      final cart = CartController(orderType: OrderType.dineIn);

      cart.add(
        vegHakkaNoodles,
        selectedCustomizations: const {
          'spice': ['medium'],
          'portion': ['regular'],
        },
      );
      cart.add(
        vegHakkaNoodles,
        selectedCustomizations: const {
          'spice': ['spicy'],
          'portion': ['regular'],
        },
      );

      final spicyItem = cart.items.last;
      cart.updateItem(
        spicyItem,
        selectedCustomizations: const {
          'spice': ['medium'],
          'portion': ['regular'],
        },
        quantity: spicyItem.quantity,
      );

      expect(cart.items, hasLength(1));
      expect(cart.items.single.quantity, 2);
      expect(cart.items.single.customizationSummary, ['Medium', 'Regular']);
    });

    test('clears dine-in table token when the cart is reset', () {
      final cart = CartController(orderType: OrderType.dineIn);

      cart.setTableToken('12');
      expect(cart.tableToken, '12');

      cart.clear();

      expect(cart.tableToken, isNull);
    });
  });
}
