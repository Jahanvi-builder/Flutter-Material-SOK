import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sok_material/models/cart_controller.dart';
import 'package:sok_material/models/menu_item.dart';
import 'package:sok_material/screens/kiosk/combo_customization_screen.dart';

const requiredCombo = MenuItem(
  id: 'combo_required',
  name: 'North Indian Thali',
  description: 'Test combo',
  price: 180,
  category: 'Combos',
  subCategory: 'Combo Special',
  isVeg: true,
  spiceLevel: 2,
  prepTime: '5 mins',
  imagePath: 'images/Food/North indian/dal_makhni.jpg',
  icon: Icons.set_meal,
  color: Color(0xFF8D6E63),
  isComboTemplate: true,
  comboReferencePrice: 0,
  comboSlots: [
    ComboSlot(
      slotId: 'main',
      title: 'Choose your main',
      customizationGroupId: 'combo_main',
      required: true,
      allowedOptionIds: ['dal_makhani'],
    ),
    ComboSlot(
      slotId: 'bread',
      title: 'Choose your bread',
      customizationGroupId: 'combo_bread',
      required: true,
      allowedOptionIds: ['tandoori_roti'],
    ),
  ],
  customizationGroups: [
    MenuItemCustomizationGroup(
      id: 'combo_main',
      title: 'Choose your main',
      selectionType: CustomOptionSelectionType.single,
      options: [
        MenuItemOption(
          id: 'dal_makhani',
          label: 'Dal Makhani',
          imagePath: 'images/Food/North indian/dal_makhni.jpg',
          referencePriceDelta: 180,
        ),
      ],
    ),
    MenuItemCustomizationGroup(
      id: 'combo_bread',
      title: 'Choose your bread',
      selectionType: CustomOptionSelectionType.single,
      options: [
        MenuItemOption(
          id: 'tandoori_roti',
          label: 'Tandoori Roti',
          imagePath: 'images/Food/North indian/dal_makhni.jpg',
          referencePriceDelta: 40,
        ),
      ],
    ),
  ],
);

void main() {
  Widget buildScreen({
    required CartController cart,
    required double width,
    required double height,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: Scaffold(
          body: ComboCustomizationScreen(
            key: ValueKey('${width}x$height'),
            comboItem: requiredCombo,
            cart: cart,
          ),
        ),
      ),
    );
  }

  testWidgets('combo stepper can review and add combo to cart', (
    tester,
  ) async {
    final cart = CartController(orderType: OrderType.dineIn);

    await tester.pumpWidget(buildScreen(cart: cart, width: 390, height: 844));

    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byIcon(Icons.radio_button_checked), findsNothing);
    expect(find.byIcon(Icons.radio_button_off), findsNothing);
    expect(find.byKey(const Key('combo_builder_header')), findsNothing);
    expect(find.text('Choose your main'), findsAtLeastNWidgets(1));
    expect(find.text('Choose your bread'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('combo_quantity_selector')), findsOneWidget);
    expect(find.text('Included'), findsNWidgets(2));
    expect(find.textContaining('+₹'), findsNothing);

    final reviewButton = tester.widget<FilledButton>(
      find.byKey(const Key('combo_primary_action')),
    );
    expect(reviewButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('combo_primary_action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('combo_builder_header')), findsOneWidget);
    final heroImage = tester.widget<Image>(
      find.byKey(const Key('combo_header_hero_image')),
    );
    expect(
      (heroImage.image as AssetImage).assetName,
      'images/Food/North indian/dal_makhni.jpg',
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('combo_header_price_row')),
        matching: find.text('You save ₹40'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('combo_review_separator_0')), findsOneWidget);
    expect(find.byKey(const Key('combo_back_action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('combo_primary_action')));
    await tester.pumpAndSettle();

    expect(cart.items, hasLength(1));
    expect(cart.items.single.comboDetails, isNotNull);
  });

  testWidgets('shows large cards on wide layout and compact tiles on narrow layout', (
    tester,
  ) async {
    final cart = CartController(orderType: OrderType.dineIn);

    await tester.pumpWidget(buildScreen(cart: cart, width: 390, height: 844));
    expect(find.byKey(const Key('combo_option_tile_dal_makhani')), findsOneWidget);
    expect(find.byKey(const Key('combo_option_card_dal_makhani')), findsNothing);
    expect(find.byKey(const Key('combo_builder_header')), findsNothing);

    await tester.tap(find.byKey(const Key('combo_primary_action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('combo_review_tile_dal_makhani')), findsOneWidget);
    expect(find.byKey(const Key('combo_review_separator_0')), findsOneWidget);

    await tester.pumpWidget(buildScreen(cart: cart, width: 1200, height: 900));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('combo_option_card_dal_makhani')), findsOneWidget);
    expect(find.byKey(const Key('combo_slot_grid_main')), findsOneWidget);
    expect(find.byKey(const Key('combo_builder_header')), findsNothing);

    await tester.tap(find.byKey(const Key('combo_primary_action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('combo_review_card_dal_makhani')), findsOneWidget);
    expect(find.byKey(const Key('combo_review_card_tandoori_roti')), findsOneWidget);
    expect(find.byKey(const Key('combo_option_card_dal_makhani')), findsNothing);
    final wideHeroImage = tester.widget<Image>(
      find.byKey(const Key('combo_header_hero_image')),
    );
    expect(
      (wideHeroImage.image as AssetImage).assetName,
      'images/Food/North indian/dal_makhni.jpg',
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('combo_header_price_row')),
        matching: find.text('You save ₹40'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('combo_review_separator_0')), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsNothing);
    expect(find.byIcon(Icons.radio_button_off), findsNothing);
  });
}
