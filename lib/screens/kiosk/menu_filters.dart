import 'package:flutter/material.dart';

import '../../models/menu_item.dart';

enum FoodTypeFilter { veg, nonVeg }

class MenuFilterState {
  final FoodTypeFilter? foodType;

  const MenuFilterState({this.foodType});

  static const empty = MenuFilterState();

  bool get vegOnly => foodType == FoodTypeFilter.veg;
  bool get nonVegOnly => foodType == FoodTypeFilter.nonVeg;
  bool get hasAnyActive => foodType != null;

  MenuFilterState copyWith({
    FoodTypeFilter? foodType,
    bool clearFoodType = false,
  }) {
    return MenuFilterState(
      foodType: clearFoodType ? null : foodType ?? this.foodType,
    );
  }
}

List<MenuItem> filterMenuItems(
  List<MenuItem> items, {
  required String category,
  required String searchQuery,
  required MenuFilterState filters,
}) {
  Iterable<MenuItem> filtered = category == 'All'
      ? items
      : items.where((item) => item.category == category);

  if (filters.vegOnly) {
    filtered = filtered.where((item) => item.isVeg);
  } else if (filters.nonVegOnly) {
    filtered = filtered.where((item) => !item.isVeg);
  }

  if (searchQuery.isNotEmpty) {
    final q = searchQuery.toLowerCase();
    filtered = filtered.where(
      (item) =>
          item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.subCategory.toLowerCase().contains(q),
    );
  }

  return filtered.toList();
}

class MenuFilterBar extends StatelessWidget {
  const MenuFilterBar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    required this.onClearAll,
  });

  final MenuFilterState filters;
  final ValueChanged<MenuFilterState> onFiltersChanged;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _FoodTypeTag(
            label: 'Veg',
            isVeg: true,
            selected: filters.vegOnly,
            onTap: () => onFiltersChanged(
              const MenuFilterState(foodType: FoodTypeFilter.veg),
            ),
            onClear: () => onFiltersChanged(MenuFilterState.empty),
          ),
          const SizedBox(width: 10),
          _FoodTypeTag(
            label: 'Non-Veg',
            isVeg: false,
            selected: filters.nonVegOnly,
            onTap: () => onFiltersChanged(
              const MenuFilterState(foodType: FoodTypeFilter.nonVeg),
            ),
            onClear: () => onFiltersChanged(MenuFilterState.empty),
          ),
          const Spacer(),
          if (filters.hasAnyActive)
            TextButton(onPressed: onClearAll, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class MenuEmptyState extends StatelessWidget {
  const MenuEmptyState({super.key, required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_off_rounded, size: 64, color: cs.outline),
            const SizedBox(height: 16),
            Text('No dishes match this filter', style: tt.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Clear the selected food filter or search text to explore the full menu again.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: onClearFilters,
              child: const Text('Clear Filter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodTypeTag extends StatelessWidget {
  const _FoodTypeTag({
    required this.label,
    required this.isVeg,
    required this.selected,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final bool isVeg;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fillColor = selected ? cs.primaryContainer : cs.surfaceContainerHigh;
    final textColor = selected ? cs.onPrimaryContainer : cs.onSurface;
    final borderColor = selected ? cs.primary.withAlpha(90) : cs.outlineVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: selected ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FoodTypeDot(isVeg: isVeg, selected: selected),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodTypeDot extends StatelessWidget {
  const _FoodTypeDot({required this.isVeg, required this.selected});

  final bool isVeg;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      width: 18,
      height: 18,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: selected ? 1.5 : 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
