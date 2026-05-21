import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sok_material/data/mock_menu.dart';
import 'package:sok_material/models/cart_controller.dart';
import 'package:sok_material/models/menu_item.dart';

const thaliCombo = MenuItem(
  id: 'thali_test',
  name: 'North Indian Thali',
  description: 'Test combo',
  price: 280,
  category: 'Combos',
  subCategory: 'Combo Special',
  isVeg: true,
  spiceLevel: 2,
  prepTime: '10 mins',
  imagePath: '',
  icon: Icons.set_meal,
  color: Color(0xFF8D6E63),
  isComboTemplate: true,
  comboReferencePrice: 0,
  comboSlots: [
    ComboSlot(
      slotId: 'main',
      title: 'Choose your main',
      customizationGroupId: 'main',
      defaultOptionId: 'dal',
      allowedOptionIds: ['dal', 'paneer'],
    ),
    ComboSlot(
      slotId: 'rice',
      title: 'Choose your rice',
      customizationGroupId: 'rice',
      defaultOptionId: 'jeera',
      allowedOptionIds: ['jeera'],
    ),
  ],
  customizationGroups: [
    MenuItemCustomizationGroup(
      id: 'main',
      title: 'Choose your main',
      selectionType: CustomOptionSelectionType.single,
      options: [
        MenuItemOption(id: 'dal', label: 'Dal Makhani', referencePriceDelta: 180),
        MenuItemOption(
          id: 'paneer',
          label: 'Paneer Tikka Masala',
          priceDelta: 20,
          referencePriceDelta: 220,
        ),
      ],
    ),
    MenuItemCustomizationGroup(
      id: 'rice',
      title: 'Choose your rice',
      selectionType: CustomOptionSelectionType.single,
      options: [
        MenuItemOption(id: 'jeera', label: 'Jeera Rice', referencePriceDelta: 140),
      ],
    ),
  ],
);

void main() {
  test('only one combo special is seeded in the combo menu', () {
    final comboTemplates = menuItems.where((item) => item.isComboTemplate).toList();

    expect(comboTemplates, hasLength(1));
    expect(comboTemplates.single.name, 'Build Your North Indian Thali');
  });

  test('combo pricing summary computes combo and savings', () {
    final pricing = thaliCombo.comboPricingSummary(const {
      'main': ['paneer'],
      'rice': ['jeera'],
    });

    expect(pricing.comboTotal, 300);
    expect(pricing.aLaCarteTotal, 360);
    expect(pricing.savingsAmount, 60);
  });

  test('combo lines merge only when configuration is identical', () {
    final cart = CartController(orderType: OrderType.dineIn);

    const comboASelections = {
      'main': ['dal'],
      'rice': ['jeera'],
    };
    const comboBSelections = {
      'main': ['paneer'],
      'rice': ['jeera'],
    };

    final pricingA = thaliCombo.comboPricingSummary(comboASelections);
    final pricingB = thaliCombo.comboPricingSummary(comboBSelections);

    cart.add(
      thaliCombo,
      selectedCustomizations: comboASelections,
      comboDetails: CartComboDetails(
        templateId: thaliCombo.id,
        selections: comboASelections,
        comboTotal: pricingA.comboTotal,
        aLaCarteTotal: pricingA.aLaCarteTotal,
        savingsAmount: pricingA.savingsAmount,
      ),
    );

    cart.add(
      thaliCombo,
      selectedCustomizations: comboASelections,
      comboDetails: CartComboDetails(
        templateId: thaliCombo.id,
        selections: comboASelections,
        comboTotal: pricingA.comboTotal,
        aLaCarteTotal: pricingA.aLaCarteTotal,
        savingsAmount: pricingA.savingsAmount,
      ),
    );

    cart.add(
      thaliCombo,
      selectedCustomizations: comboBSelections,
      comboDetails: CartComboDetails(
        templateId: thaliCombo.id,
        selections: comboBSelections,
        comboTotal: pricingB.comboTotal,
        aLaCarteTotal: pricingB.aLaCarteTotal,
        savingsAmount: pricingB.savingsAmount,
      ),
    );

    expect(cart.items.length, 2);
    expect(cart.items.first.quantity, 2);
    expect(cart.items.last.quantity, 1);
  });

  test('editing combo can merge with existing combo line', () {
    final cart = CartController(orderType: OrderType.dineIn);

    const comboASelections = {
      'main': ['dal'],
      'rice': ['jeera'],
    };
    const comboBSelections = {
      'main': ['paneer'],
      'rice': ['jeera'],
    };

    final pricingA = thaliCombo.comboPricingSummary(comboASelections);
    final pricingB = thaliCombo.comboPricingSummary(comboBSelections);

    cart.add(
      thaliCombo,
      selectedCustomizations: comboASelections,
      comboDetails: CartComboDetails(
        templateId: thaliCombo.id,
        selections: comboASelections,
        comboTotal: pricingA.comboTotal,
        aLaCarteTotal: pricingA.aLaCarteTotal,
        savingsAmount: pricingA.savingsAmount,
      ),
    );
    cart.add(
      thaliCombo,
      selectedCustomizations: comboBSelections,
      comboDetails: CartComboDetails(
        templateId: thaliCombo.id,
        selections: comboBSelections,
        comboTotal: pricingB.comboTotal,
        aLaCarteTotal: pricingB.aLaCarteTotal,
        savingsAmount: pricingB.savingsAmount,
      ),
    );

    final second = cart.items.last;
    cart.updateItem(
      second,
      selectedCustomizations: comboASelections,
      comboDetails: CartComboDetails(
        templateId: thaliCombo.id,
        selections: comboASelections,
        comboTotal: pricingA.comboTotal,
        aLaCarteTotal: pricingA.aLaCarteTotal,
        savingsAmount: pricingA.savingsAmount,
      ),
      quantity: 1,
    );

    expect(cart.items.length, 1);
    expect(cart.items.single.quantity, 2);
  });
}
