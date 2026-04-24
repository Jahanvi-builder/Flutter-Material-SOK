import 'package:flutter/material.dart';

enum CustomOptionSelectionType { single, multiple }

class MenuItemOption {
  final String id;
  final String label;
  final double priceDelta;

  const MenuItemOption({
    required this.id,
    required this.label,
    this.priceDelta = 0,
  });
}

class MenuItemCustomizationGroup {
  final String id;
  final String title;
  final CustomOptionSelectionType selectionType;
  final List<MenuItemOption> options;
  final List<String> defaultOptionIds;

  const MenuItemCustomizationGroup({
    required this.id,
    required this.title,
    required this.selectionType,
    required this.options,
    this.defaultOptionIds = const [],
  });

  MenuItemOption? optionById(String id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String subCategory;
  final bool isVeg;
  final int spiceLevel; // 0 = none … 5 = extreme
  final String prepTime;
  final String
  imagePath; // filename only; full path resolved when images are available
  final IconData icon;
  final Color color;
  final List<String> sizes;
  final List<String> addOns;
  final List<MenuItemCustomizationGroup> customizationGroups;
  final double rating;
  final double? originalPrice;

  int? get discountPercent => originalPrice == null
      ? null
      : ((originalPrice! - price) / originalPrice! * 100).round();

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.subCategory,
    required this.isVeg,
    required this.spiceLevel,
    required this.prepTime,
    required this.imagePath,
    required this.icon,
    required this.color,
    this.sizes = const [],
    this.addOns = const [],
    this.customizationGroups = const [],
    this.rating = 4.0,
    this.originalPrice,
  });

  bool get isCustomizable =>
      sizes.isNotEmpty || addOns.isNotEmpty || customizationGroups.isNotEmpty;

  double customizationPrice(Map<String, List<String>> selections) {
    var total = 0.0;
    for (final group in customizationGroups) {
      final selectedIds = selections[group.id] ?? const <String>[];
      for (final id in selectedIds) {
        total += group.optionById(id)?.priceDelta ?? 0;
      }
    }
    return total;
  }

  List<String> customizationSummary(Map<String, List<String>> selections) {
    final summary = <String>[];
    for (final group in customizationGroups) {
      final selectedIds = selections[group.id] ?? const <String>[];
      for (final id in selectedIds) {
        final option = group.optionById(id);
        if (option != null) {
          summary.add(option.label);
        }
      }
    }
    return summary;
  }
}
