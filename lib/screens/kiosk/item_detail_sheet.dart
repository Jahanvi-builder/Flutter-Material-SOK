import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/menu_item.dart';
import '../../services/sound_service.dart';

// Shared chip style matching the menu category chips
const _chipShape = StadiumBorder();
const _chipPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const _chipLabelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
const _chipSpacing = 8.0;

/// Call this instead of showModalBottomSheet/showDialog directly.
/// Automatically picks the right presentation based on screen width.
void showItemDetail(BuildContext context, MenuItem item, CartController cart) {
  final isWide = MediaQuery.sizeOf(context).width >= 700;

  if (isWide) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(40),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SizedBox(
          width: 560,
          child: _ItemDetailContent(item: item, cart: cart),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _ItemDetailContent(
          item: item,
          cart: cart,
          scrollController: scrollController,
          showDragHandle: true,
        ),
      ),
    );
  }
}

class _ItemDetailContent extends StatefulWidget {
  const _ItemDetailContent({
    required this.item,
    required this.cart,
    this.scrollController,
    this.showDragHandle = false,
  });

  final MenuItem item;
  final CartController cart;
  final ScrollController? scrollController;
  final bool showDragHandle;

  @override
  State<_ItemDetailContent> createState() => _ItemDetailContentState();
}

class _ItemDetailContentState extends State<_ItemDetailContent> {
  late String? _selectedSize;
  final Set<String> _selectedAddOns = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.item.sizes.isNotEmpty ? widget.item.sizes.first : null;
  }

  double get _itemTotal => widget.item.price * _quantity;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showDragHandle) ...[
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
        ],

        Flexible(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: item.color.withAlpha(60),
                    child: Icon(item.icon, size: 80, color: item.color),
                  ),
                ),
                const SizedBox(height: 20),

                // Name + price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '₹${item.price.round()}',
                      style: tt.headlineSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sub-category + veg indicator + prep time
                Row(
                  children: [
                    _VegIndicator(isVeg: item.isVeg),
                    const SizedBox(width: 8),
                    Text(
                      item.subCategory,
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Icon(Icons.schedule_rounded, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      item.prepTime,
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),

                // Spice level
                if (item.spiceLevel > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: i < item.spiceLevel ? const Color(0xFFE53935) : cs.outlineVariant,
                      ),
                    )),
                  ),
                ],

                const SizedBox(height: 8),
                Text(item.description, style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),

                // Sizes
                if (item.sizes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Size', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: _chipSpacing,
                    runSpacing: _chipSpacing,
                    children: item.sizes.map((size) {
                      return ChoiceChip(
                        label: Text(size, style: _chipLabelStyle),
                        selected: _selectedSize == size,
                        onSelected: (_) => setState(() => _selectedSize = size),
                        shape: _chipShape,
                        padding: _chipPadding,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],

                // Add-ons
                if (item.addOns.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Add-ons', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: _chipSpacing,
                    runSpacing: _chipSpacing,
                    children: item.addOns.map((addon) {
                      final selected = _selectedAddOns.contains(addon);
                      return FilterChip(
                        label: Text(addon, style: _chipLabelStyle),
                        selected: selected,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _selectedAddOns.add(addon);
                          } else {
                            _selectedAddOns.remove(addon);
                          }
                        }),
                        shape: _chipShape,
                        padding: _chipPadding,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 32),

                // Quantity + Add to Cart
                Row(
                  children: [
                    // Quantity stepper
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outlineVariant),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () { SoundService.playTap(); setState(() => _quantity--); }
                                : null,
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '$_quantity',
                              textAlign: TextAlign.center,
                              style: tt.titleLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () { SoundService.playTap(); setState(() => _quantity++); },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add to cart button
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          SoundService.playTap();
                          widget.cart.add(
                            item,
                            size: _selectedSize,
                            addOns: _selectedAddOns.toList(),
                            quantity: _quantity,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} added to order'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: Text('Add to Cart  ·  ₹${_itemTotal.round()}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Standard Indian veg / non-veg dot indicator
class _VegIndicator extends StatelessWidget {
  const _VegIndicator({required this.isVeg});
  final bool isVeg;

  static const _vegColor   = Color(0xFF2E7D32);
  static const _nonVegColor = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? _vegColor : _nonVegColor;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
