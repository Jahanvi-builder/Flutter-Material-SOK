import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import '../../models/menu_item.dart';
import '../../services/haptic_service.dart';

Color _starColor(double rating) {
  if (rating >= 4.5) return const Color(0xFF2E7D32);
  if (rating >= 4.0) return const Color(0xFFFFA726);
  if (rating >= 3.5) return const Color(0xFF66BB6A);
  return const Color(0xFFFFA726);
}

const _chipShape = StadiumBorder();
const _chipPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const _chipLabelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
const _chipSpacing = 8.0;

void showItemDetail(
  BuildContext context,
  MenuItem item,
  CartController cart, {
  CartItem? editingCartItem,
}) {
  final isWide = MediaQuery.sizeOf(context).width >= 700;

  if (isWide) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(40),
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: SizedBox(
          width: 560,
          child: _ItemDetailContent(
            item: item,
            cart: cart,
            editingCartItem: editingCartItem,
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Material(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: _ItemDetailContent(
            item: item,
            cart: cart,
            editingCartItem: editingCartItem,
            scrollController: scrollController,
            showDragHandle: true,
          ),
        ),
      ),
    );
  }
}

class _ItemDetailContent extends StatefulWidget {
  const _ItemDetailContent({
    required this.item,
    required this.cart,
    this.editingCartItem,
    this.scrollController,
    this.showDragHandle = false,
  });

  final MenuItem item;
  final CartController cart;
  final CartItem? editingCartItem;
  final ScrollController? scrollController;
  final bool showDragHandle;

  @override
  State<_ItemDetailContent> createState() => _ItemDetailContentState();
}

class _ItemDetailContentState extends State<_ItemDetailContent> {
  late String? _selectedSize;
  late Set<String> _selectedAddOns;
  late Map<String, List<String>> _selectedCustomizations;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    final editingItem = widget.editingCartItem;
    _selectedSize =
        editingItem?.size ??
        (widget.item.sizes.isNotEmpty ? widget.item.sizes.first : null);
    _selectedAddOns = {...editingItem?.addOns ?? const <String>[]};
    _selectedCustomizations = {
      for (final group in widget.item.customizationGroups)
        group.id: List<String>.from(
          editingItem?.selectedCustomizations[group.id] ??
              (group.defaultOptionIds.isNotEmpty
                  ? group.defaultOptionIds
                  : group.selectionType == CustomOptionSelectionType.single &&
                        group.options.isNotEmpty
                  ? [group.options.first.id]
                  : const <String>[]),
        ),
    };
    _quantity = editingItem?.quantity ?? 1;
  }

  double get _unitPrice =>
      widget.item.price +
      widget.item.customizationPrice(_selectedCustomizations);
  double get _itemTotal => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEditing = widget.editingCartItem != null;

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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: item.imagePath.isNotEmpty
                        ? Image.asset(
                            item.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: item.color.withAlpha(60),
                              child: Center(
                                child: Icon(
                                  item.icon,
                                  size: 80,
                                  color: item.color,
                                ),
                              ),
                            ),
                          )
                        : ColoredBox(
                            color: item.color.withAlpha(60),
                            child: Center(
                              child: Icon(
                                item.icon,
                                size: 80,
                                color: item.color,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.originalPrice != null) ...[
                          Text(
                            '₹${item.originalPrice!.round()}',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant.withAlpha(120),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: cs.onSurfaceVariant.withAlpha(
                                120,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '₹',
                                style: tt.titleMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '${_unitPrice.round()}',
                                style: tt.headlineSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _VegIndicator(isVeg: item.isVeg),
                    const SizedBox(width: 8),
                    Text(
                      item.subCategory,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: tt.labelMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: _starColor(item.rating),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.prepTime,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (item.spiceLevel > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: i < item.spiceLevel
                              ? const Color(0xFFE53935)
                              : cs.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (item.customizationGroups.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Customize Your Order',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...item.customizationGroups.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _CustomizationGroupSection(
                        group: group,
                        selectedIds:
                            _selectedCustomizations[group.id] ??
                            const <String>[],
                        onSingleSelected: (optionId) => setState(() {
                          _selectedCustomizations[group.id] = [optionId];
                        }),
                        onToggleSelected: (optionId, selected) => setState(() {
                          final current = [
                            ..._selectedCustomizations[group.id] ??
                                const <String>[],
                          ];
                          if (selected) {
                            if (!current.contains(optionId)) {
                              current.add(optionId);
                            }
                          } else {
                            current.remove(optionId);
                          }
                          _selectedCustomizations[group.id] = current;
                        }),
                      ),
                    ),
                  ),
                ],
                if (item.sizes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Size',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                if (item.addOns.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Add-ons',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: _chipSpacing,
                    runSpacing: _chipSpacing,
                    children: item.addOns.map((addon) {
                      final selected = _selectedAddOns.contains(addon);
                      return FilterChip(
                        label: Text(addon, style: _chipLabelStyle),
                        selected: selected,
                        onSelected: (value) => setState(() {
                          if (value) {
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
                Row(
                  children: [
                    SizedBox(
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.outlineVariant),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              constraints: const BoxConstraints.tightFor(
                                width: 56,
                                height: 56,
                              ),
                              onPressed: _quantity > 1
                                  ? () {
                                      HapticService.tap();
                                      setState(() => _quantity--);
                                    }
                                  : null,
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: tt.titleMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              constraints: const BoxConstraints.tightFor(
                                width: 56,
                                height: 56,
                              ),
                              onPressed: () {
                                HapticService.tap();
                                setState(() => _quantity++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () {
                          HapticService.tap();
                          final selectionMap = {
                            for (final entry in _selectedCustomizations.entries)
                              entry.key: List<String>.from(entry.value),
                          };
                          if (isEditing) {
                            widget.cart.updateItem(
                              widget.editingCartItem!,
                              size: _selectedSize,
                              addOns: _selectedAddOns.toList(),
                              selectedCustomizations: selectionMap,
                              quantity: _quantity,
                            );
                          } else {
                            widget.cart.add(
                              item,
                              size: _selectedSize,
                              addOns: _selectedAddOns.toList(),
                              selectedCustomizations: selectionMap,
                              quantity: _quantity,
                            );
                          }
                          final overlay = Overlay.of(context);
                          Navigator.pop(context);
                          _showToast(
                            overlay,
                            isEditing
                                ? '${item.name} updated'
                                : '${item.name} added to order',
                            cs,
                          );
                        },
                        style: FilledButton.styleFrom(
                          fixedSize: const Size.fromHeight(56),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'GoogleSansFlex',
                            fontVariations: [FontVariation('ROND', 100.0)],
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: isEditing
                                    ? 'Update Order  ·  '
                                    : 'Add to Cart  ·  ',
                              ),
                              const TextSpan(
                                text: '₹',
                                style: TextStyle(fontSize: 13),
                              ),
                              TextSpan(text: '${_itemTotal.round()}'),
                            ],
                          ),
                        ),
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

class _CustomizationGroupSection extends StatelessWidget {
  const _CustomizationGroupSection({
    required this.group,
    required this.selectedIds,
    required this.onSingleSelected,
    required this.onToggleSelected,
  });

  final MenuItemCustomizationGroup group;
  final List<String> selectedIds;
  final ValueChanged<String> onSingleSelected;
  final void Function(String optionId, bool selected) onToggleSelected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: _chipSpacing,
          runSpacing: _chipSpacing,
          children: group.options.map((option) {
            final selected = selectedIds.contains(option.id);
            final label = option.priceDelta > 0
                ? '${option.label} (+₹${option.priceDelta.round()})'
                : option.label;

            if (group.selectionType == CustomOptionSelectionType.single) {
              return ChoiceChip(
                label: Text(label, style: _chipLabelStyle),
                selected: selected,
                onSelected: (_) => onSingleSelected(option.id),
                shape: _chipShape,
                padding: _chipPadding,
                showCheckmark: false,
              );
            }

            return FilterChip(
              label: Text(label, style: _chipLabelStyle),
              selected: selected,
              onSelected: (value) => onToggleSelected(option.id, value),
              shape: _chipShape,
              padding: _chipPadding,
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}

void _showToast(OverlayState overlay, String message, ColorScheme cs) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: cs.inverseSurface,
                shape: const StadiumBorder(),
                shadows: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x33000000),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: cs.onInverseSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(seconds: 2), () {
    if (entry.mounted) entry.remove();
  });
}

class _VegIndicator extends StatelessWidget {
  const _VegIndicator({required this.isVeg});

  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      width: 18,
      height: 18,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
