import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import '../../models/menu_item.dart';

Future<void> openComboCustomizationScreen(
  BuildContext context, {
  required MenuItem comboItem,
  required CartController cart,
  CartItem? editingCartItem,
}) async {
  final media = MediaQuery.sizeOf(context);
  final isWide = media.width >= 900;

  if (isWide) {
    final dialogWidth = media.width > 1280 ? 1180.0 : media.width - 72;
    final dialogHeight = media.height > 960 ? 900.0 : media.height - 64;
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: ComboCustomizationScreen(
            comboItem: comboItem,
            cart: cart,
            editingCartItem: editingCartItem,
          ),
        ),
      ),
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.94,
      minChildSize: 0.6,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, controller) => ComboCustomizationScreen(
        comboItem: comboItem,
        cart: cart,
        editingCartItem: editingCartItem,
        scrollController: controller,
        showDragHandle: true,
      ),
    ),
  );
}

class ComboCustomizationScreen extends StatefulWidget {
  const ComboCustomizationScreen({
    super.key,
    required this.comboItem,
    required this.cart,
    this.editingCartItem,
    this.scrollController,
    this.showDragHandle = false,
  });

  final MenuItem comboItem;
  final CartController cart;
  final CartItem? editingCartItem;
  final ScrollController? scrollController;
  final bool showDragHandle;

  @override
  State<ComboCustomizationScreen> createState() =>
      _ComboCustomizationScreenState();
}

class _ComboCustomizationScreenState extends State<ComboCustomizationScreen> {
  late Map<String, List<String>> _selections;
  late int _quantity;
  int _step = 0;

  bool get _isEditing => widget.editingCartItem != null;
  bool get _showWideLayout => MediaQuery.sizeOf(context).width >= 900;
  bool get _showVisualCards => MediaQuery.sizeOf(context).width >= 720;
  EdgeInsets get _contentPadding => EdgeInsets.fromLTRB(
    _showWideLayout ? 24 : 16,
    _showWideLayout ? 24 : 16,
    _showWideLayout ? 24 : 16,
    _showWideLayout ? 28 : 20,
  );
  ComboPricingSummary get _pricing =>
      widget.comboItem.comboPricingSummary(_selections);
  double get _totalPrice => _pricing.comboTotal * _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.editingCartItem?.quantity ?? 1;
    _selections = {
      for (final group in widget.comboItem.customizationGroups)
        group.id: List<String>.from(
          widget.editingCartItem?.selectedCustomizations[group.id] ??
              _defaultSelectionFor(group.id),
        ),
    };
  }

  List<String> _defaultSelectionFor(String groupId) {
    final slot = widget.comboItem.comboSlots
        .where((entry) => entry.customizationGroupId == groupId)
        .firstOrNull;
    if (slot?.defaultOptionId != null) {
      return [slot!.defaultOptionId!];
    }
    final group = widget.comboItem.customizationGroupById(groupId);
    if (group == null) return const <String>[];
    if (group.defaultOptionIds.isNotEmpty) return group.defaultOptionIds;
    if (group.selectionType == CustomOptionSelectionType.single &&
        group.options.isNotEmpty) {
      return [group.options.first.id];
    }
    return const <String>[];
  }

  bool get _isSelectionValid {
    for (final slot in widget.comboItem.comboSlots) {
      if (!slot.required) continue;
      final selected = _selections[slot.customizationGroupId] ?? const <String>[];
      if (selected.isEmpty) return false;
      final selectedId = selected.first;
      if (slot.allowedOptionIds.isNotEmpty &&
          !slot.allowedOptionIds.contains(selectedId)) {
        return false;
      }
    }
    return true;
  }

  ButtonStyle get _actionButtonStyle => FilledButton.styleFrom(
    fixedSize: const Size.fromHeight(56),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontFamily: 'GoogleSansFlex',
      fontVariations: [FontVariation('ROND', 100.0)],
    ),
  );

  void _toggleOption(
    MenuItemCustomizationGroup group,
    MenuItemOption option,
    bool selected,
  ) {
    setState(() {
      final current = List<String>.from(
        _selections[group.id] ?? const <String>[],
      );
      if (group.selectionType == CustomOptionSelectionType.single) {
        _selections[group.id] = selected ? [option.id] : const <String>[];
      } else {
        if (selected) {
          if (!current.contains(option.id)) current.add(option.id);
        } else {
          current.remove(option.id);
        }
        _selections[group.id] = current;
      }
    });
  }

  void _saveToCart() {
    final pricing = _pricing;
    final comboDetails = CartComboDetails(
      templateId: widget.comboItem.id,
      selections: {
        for (final entry in _selections.entries)
          entry.key: List<String>.from(entry.value),
      },
      comboTotal: pricing.comboTotal,
      aLaCarteTotal: pricing.aLaCarteTotal,
      savingsAmount: pricing.savingsAmount,
    );

    if (_isEditing) {
      widget.cart.updateItem(
        widget.editingCartItem!,
        selectedCustomizations: _selections,
        comboDetails: comboDetails,
        quantity: _quantity,
      );
    } else {
      widget.cart.add(
        widget.comboItem,
        selectedCustomizations: _selections,
        comboDetails: comboDetails,
        quantity: _quantity,
      );
    }

    Navigator.pop(context);
  }

  MenuItemOption? _selectedOptionForSlot(ComboSlot slot) {
    final group = widget.comboItem.customizationGroupById(
      slot.customizationGroupId,
    );
    final selectedIds = _selections[slot.customizationGroupId] ?? const <String>[];
    if (group == null || selectedIds.isEmpty) return null;
    return group.optionById(selectedIds.first);
  }

  List<_ReviewSelectionEntry> _selectedReviewEntries() {
    return widget.comboItem.comboSlots
        .map(
          (slot) => _ReviewSelectionEntry(
            option: _selectedOptionForSlot(slot),
          ),
        )
        .where((entry) => entry.option != null)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      child: Column(
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
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: _contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_step == 1) ...[
                    _HeaderSection(
                      comboItem: widget.comboItem,
                      heroImagePath: widget.comboItem.imagePath,
                      pricing: _pricing,
                      quantity: _quantity,
                      showWideLayout: _showWideLayout,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_step == 0)
                    _buildSelectionStep(context)
                  else
                    _buildReviewStep(context),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Material(
              elevation: 10,
              color: cs.surface,
              shadowColor: Colors.black.withAlpha(22),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(
                    top: BorderSide(color: cs.outlineVariant.withAlpha(90)),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  _showWideLayout ? 24 : 16,
                  14,
                  _showWideLayout ? 24 : 16,
                  16,
                ),
                child: _buildFooter(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.comboItem.comboSlots
          .map((slot) => _buildSlotSection(context, slot))
          .toList(),
    );
  }

  Widget _buildSlotSection(BuildContext context, ComboSlot slot) {
    final group = widget.comboItem.customizationGroupById(
      slot.customizationGroupId,
    );
    if (group == null) return const SizedBox.shrink();

    final selectedIds = _selections[group.id] ?? const <String>[];
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slot.title, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Pick one item for your thali.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          if (_showVisualCards)
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 980
                    ? 4
                    : constraints.maxWidth >= 700
                    ? 3
                    : 2;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 16) / columns;
                final cardHeight = cardWidth * 1.22;
                return GridView.builder(
                  key: Key('combo_slot_grid_${slot.slotId}'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: group.options.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: cardWidth / cardHeight,
                  ),
                  itemBuilder: (context, index) {
                    final option = group.options[index];
                    final selected = selectedIds.contains(option.id);
                    return _ComboOptionCard(
                      key: Key('combo_option_card_${option.id}'),
                      option: option,
                      selected: selected,
                      fallbackIcon: widget.comboItem.icon,
                      tintColor: widget.comboItem.color,
                      onTap: () => _toggleOption(group, option, true),
                    );
                  },
                );
              },
            )
          else
            Column(
              children: group.options.map((option) {
                final selected = selectedIds.contains(option.id);
                return _CompactOptionTile(
                  key: Key('combo_option_tile_${option.id}'),
                  option: option,
                  selected: selected,
                  fallbackIcon: widget.comboItem.icon,
                  tintColor: widget.comboItem.color,
                  onTap: () => _toggleOption(group, option, true),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final entries = _selectedReviewEntries();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review your thali',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Check each selection and total before adding it to your order.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _ReviewCardComposition(
          entries: entries,
          showVisualCards: _showVisualCards,
          fallbackIcon: widget.comboItem.icon,
          tintColor: widget.comboItem.color,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (_step == 0) {
      return Row(
        children: [
          SizedBox(
            width: 176,
            child: _QuantitySelector(
              key: const Key('combo_quantity_selector'),
              quantity: _quantity,
              onDecrement: _quantity > 1 ? () => setState(() => _quantity--) : null,
              onIncrement: () => setState(() => _quantity++),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.tonal(
              key: const Key('combo_primary_action'),
              style: _actionButtonStyle,
              onPressed: _isSelectionValid ? () => setState(() => _step = 1) : null,
              child: _ActionLabel(
                label: 'Review Combo',
                price: _totalPrice.round(),
              ),
            ),
          ),
        ],
      );
    }

    if (_showWideLayout) {
      return Row(
        children: [
          SizedBox(
            width: 128,
            child: FilledButton.tonal(
              key: const Key('combo_back_action'),
              style: _actionButtonStyle,
              onPressed: () => setState(() => _step = 0),
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 176,
            child: _QuantitySelector(
              key: const Key('combo_quantity_selector'),
              quantity: _quantity,
              onDecrement: _quantity > 1 ? () => setState(() => _quantity--) : null,
              onIncrement: () => setState(() => _quantity++),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.tonal(
              key: const Key('combo_primary_action'),
              style: _actionButtonStyle,
              onPressed: _saveToCart,
              child: _ActionLabel(
                label: _isEditing ? 'Update Order' : 'Add to Cart',
                price: _totalPrice.round(),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            key: const Key('combo_back_action'),
            style: _actionButtonStyle,
            onPressed: () => setState(() => _step = 0),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: _QuantitySelector(
                key: const Key('combo_quantity_selector'),
                quantity: _quantity,
                onDecrement: _quantity > 1 ? () => setState(() => _quantity--) : null,
                onIncrement: () => setState(() => _quantity++),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 7,
              child: FilledButton.tonal(
                key: const Key('combo_primary_action'),
                style: _actionButtonStyle,
                onPressed: _saveToCart,
                child: _ActionLabel(
                  label: _isEditing ? 'Update Order' : 'Add to Cart',
                  price: _totalPrice.round(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.comboItem,
    required this.heroImagePath,
    required this.pricing,
    required this.quantity,
    required this.showWideLayout,
  });

  final MenuItem comboItem;
  final String heroImagePath;
  final ComboPricingSummary pricing;
  final int quantity;
  final bool showWideLayout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final titleStyle = showWideLayout
        ? tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600)
        : tt.titleLarge?.copyWith(fontWeight: FontWeight.w600);
    final subtitleStyle = (showWideLayout ? tt.titleMedium : tt.titleSmall)
        ?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
    final comboTotal = pricing.comboTotal * quantity;
    final referenceTotal = pricing.aLaCarteTotal * quantity;
    final savings = pricing.savingsAmount * quantity;

    final detailPanel = Container(
      key: const Key('combo_builder_header'),
      padding: EdgeInsets.all(showWideLayout ? 16 : 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            comboItem.name,
            style: titleStyle,
          ),
          const SizedBox(height: 4),
          Text(
            'Build your thali / Pick your meal components',
            style: subtitleStyle,
          ),
          const SizedBox(height: 10),
          Wrap(
            key: const Key('combo_header_price_row'),
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '₹',
                      style: tt.titleLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '${comboTotal.round()}',
                      style: tt.headlineSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _SavingsBadge(value: 'You save ₹${savings.round()}'),
              Text(
                '₹${referenceTotal.round()}',
                style: tt.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant.withAlpha(160),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: cs.onSurfaceVariant.withAlpha(160),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final hero = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: showWideLayout ? 1.45 : 16 / 8.2,
        child: heroImagePath.isNotEmpty
            ? Image.asset(
                key: const Key('combo_header_hero_image'),
                heroImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => KeyedSubtree(
                  key: const Key('combo_header_hero_fallback'),
                  child: _HeroFallback(comboItem: comboItem),
                ),
              )
            : KeyedSubtree(
                key: const Key('combo_header_hero_fallback'),
                child: _HeroFallback(comboItem: comboItem),
              ),
      ),
    );

    if (showWideLayout) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final baseHeight = (constraints.maxWidth * 0.22)
              .clamp(220.0, 264.0)
              .toDouble();
          final headerHeight = referenceTotal > 999
              ? baseHeight + 12
              : baseHeight;
          return SizedBox(
            height: headerHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: hero),
                const SizedBox(width: 16),
                Expanded(flex: 8, child: detailPanel),
              ],
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        hero,
        const SizedBox(height: 10),
        detailPanel,
      ],
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.comboItem});

  final MenuItem comboItem;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: comboItem.color.withAlpha(60),
      child: Center(
        child: Icon(
          comboItem.icon,
          size: 72,
          color: comboItem.color,
        ),
      ),
    );
  }
}

class _SavingsBadge extends StatelessWidget {
  const _SavingsBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        value,
        style: tt.titleSmall?.copyWith(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ComboOptionCard extends StatelessWidget {
  const _ComboOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.fallbackIcon,
    required this.tintColor,
    this.onTap,
  });

  final MenuItemOption option;
  final bool selected;
  final IconData fallbackIcon;
  final Color tintColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: selected ? cs.primary : cs.outlineVariant.withAlpha(140),
          width: selected ? 1.8 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: option.imagePath?.isNotEmpty == true
                  ? Image.asset(
                      option.imagePath!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _OptionFallback(
                        fallbackIcon: fallbackIcon,
                        tintColor: tintColor,
                      ),
                    )
                  : _OptionFallback(
                      fallbackIcon: fallbackIcon,
                      tintColor: tintColor,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.priceDelta > 0
                        ? '+₹${option.priceDelta.round()}'
                        : 'Included',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall?.copyWith(
                      fontSize: option.priceDelta > 0 ? 22 : 16,
                      color: option.priceDelta > 0
                          ? cs.primary
                          : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactOptionTile extends StatelessWidget {
  const _CompactOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.fallbackIcon,
    required this.tintColor,
    this.onTap,
  });

  final MenuItemOption option;
  final bool selected;
  final IconData fallbackIcon;
  final Color tintColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? cs.primary : cs.outlineVariant.withAlpha(140),
          width: selected ? 1.8 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: option.imagePath?.isNotEmpty == true
                ? Image.asset(
                    option.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _OptionFallback(
                      fallbackIcon: fallbackIcon,
                      tintColor: tintColor,
                    ),
                  )
                : _OptionFallback(
                    fallbackIcon: fallbackIcon,
                    tintColor: tintColor,
                  ),
          ),
        ),
        title: Text(option.label, style: tt.titleMedium),
        subtitle: Text(
          option.priceDelta > 0 ? '+₹${option.priceDelta.round()}' : 'Included',
          style: tt.bodyMedium?.copyWith(
            color: option.priceDelta > 0 ? cs.primary : cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ReviewCardComposition extends StatelessWidget {
  const _ReviewCardComposition({
    required this.entries,
    required this.showVisualCards,
    required this.fallbackIcon,
    required this.tintColor,
  });

  final List<_ReviewSelectionEntry> entries;
  final bool showVisualCards;
  final IconData fallbackIcon;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (showVisualCards) {
          final cardWidth = constraints.maxWidth >= 1080
              ? 196.0
              : constraints.maxWidth >= 840
                  ? 172.0
                  : 156.0;
          final cardHeight = cardWidth * 1.22;
          return Wrap(
            spacing: 16,
            runSpacing: 20,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _ReviewOptionCard(
                    key: Key('combo_review_card_${entries[i].option!.id}'),
                    option: entries[i].option!,
                    fallbackIcon: fallbackIcon,
                    tintColor: tintColor,
                  ),
                ),
                if (i < entries.length - 1)
                  _ReviewSeparator(key: Key('combo_review_separator_$i')),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              _CompactOptionTile(
                key: Key('combo_review_tile_${entries[i].option!.id}'),
                option: entries[i].option!,
                selected: true,
                fallbackIcon: fallbackIcon,
                tintColor: tintColor,
              ),
              if (i < entries.length - 1) ...[
                const SizedBox(height: 4),
                _ReviewSeparator(key: Key('combo_review_separator_$i')),
                const SizedBox(height: 8),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _ReviewOptionCard extends StatelessWidget {
  const _ReviewOptionCard({
    super.key,
    required this.option,
    required this.fallbackIcon,
    required this.tintColor,
  });

  final MenuItemOption option;
  final IconData fallbackIcon;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: cs.primary,
          width: 1.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentHeight = (constraints.maxHeight * 0.44)
              .clamp(82.0, 96.0)
              .toDouble();
          final imageHeight = constraints.maxHeight - contentHeight;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                key: const Key('combo_review_card_image_section'),
                height: imageHeight,
                width: double.infinity,
                child: option.imagePath?.isNotEmpty == true
                    ? Image.asset(
                        option.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _OptionFallback(
                          fallbackIcon: fallbackIcon,
                          tintColor: tintColor,
                        ),
                      )
                    : _OptionFallback(
                        fallbackIcon: fallbackIcon,
                        tintColor: tintColor,
                      ),
              ),
              SizedBox(
                key: const Key('combo_review_card_content_section'),
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 38,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            option.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleSmall?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        option.priceDelta > 0
                            ? '+₹${option.priceDelta.round()}'
                            : 'Included',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(
                          fontSize: 16,
                          color: option.priceDelta > 0
                              ? cs.primary
                              : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewSeparator extends StatelessWidget {
  const _ReviewSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      child: Text(
        '+',
        style: tt.headlineSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              constraints: const BoxConstraints.tightFor(width: 56, height: 56),
              onPressed: onDecrement,
            ),
            Expanded(
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: tt.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              constraints: const BoxConstraints.tightFor(width: 56, height: 56),
              onPressed: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.label, required this.price});

  final String label;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label  ·  '),
          const TextSpan(text: '₹', style: TextStyle(fontSize: 13)),
          TextSpan(text: '$price'),
        ],
      ),
    );
  }
}

class _OptionFallback extends StatelessWidget {
  const _OptionFallback({
    required this.fallbackIcon,
    required this.tintColor,
  });

  final IconData fallbackIcon;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: tintColor.withAlpha(50),
      child: Center(
        child: Icon(fallbackIcon, size: 28, color: tintColor),
      ),
    );
  }
}

class _ReviewSelectionEntry {
  const _ReviewSelectionEntry({
    required this.option,
  });

  final MenuItemOption? option;
}


extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
