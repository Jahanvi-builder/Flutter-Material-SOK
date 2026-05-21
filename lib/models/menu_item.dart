import 'package:flutter/material.dart';

enum CustomOptionSelectionType { single, multiple }

class MenuItemOption {
  final String id;
  final String label;
  final double priceDelta;
  final double referencePriceDelta;
  final String? imagePath;

  const MenuItemOption({
    required this.id,
    required this.label,
    this.priceDelta = 0,
    this.referencePriceDelta = 0,
    this.imagePath,
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

class ComboSlot {
  final String slotId;
  final String title;
  final bool required;
  final String customizationGroupId;
  final String? defaultOptionId;
  final List<String> allowedOptionIds;

  const ComboSlot({
    required this.slotId,
    required this.title,
    required this.customizationGroupId,
    this.required = true,
    this.defaultOptionId,
    this.allowedOptionIds = const [],
  });
}

class ComboUpgrade {
  final String id;
  final String title;
  final String customizationGroupId;
  final List<String> allowedOptionIds;

  const ComboUpgrade({
    required this.id,
    required this.title,
    required this.customizationGroupId,
    this.allowedOptionIds = const [],
  });
}

class ComboSelection {
  final Map<String, List<String>> selections;
  final int quantity;

  const ComboSelection({required this.selections, this.quantity = 1});
}

class ComboPricingSummary {
  final double comboTotal;
  final double aLaCarteTotal;

  const ComboPricingSummary({
    required this.comboTotal,
    required this.aLaCarteTotal,
  });

  double get savingsAmount => (aLaCarteTotal - comboTotal).clamp(0, double.infinity);
}

class CartComboDetails {
  final String templateId;
  final Map<String, List<String>> selections;
  final double comboTotal;
  final double aLaCarteTotal;
  final double savingsAmount;

  const CartComboDetails({
    required this.templateId,
    required this.selections,
    required this.comboTotal,
    required this.aLaCarteTotal,
    required this.savingsAmount,
  });
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
  final String imagePath;
  final IconData icon;
  final Color color;
  final List<String> sizes;
  final List<String> addOns;
  final List<MenuItemCustomizationGroup> customizationGroups;
  final double rating;
  final double? originalPrice;
  final bool isComboTemplate;
  final bool isMerchantDefinedCombo;
  final double? comboReferencePrice;
  final List<ComboSlot> comboSlots;
  final List<ComboUpgrade> comboUpgrades;

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
    this.isComboTemplate = false,
    this.isMerchantDefinedCombo = false,
    this.comboReferencePrice,
    this.comboSlots = const [],
    this.comboUpgrades = const [],
  });

  bool get isCustomizable =>
      sizes.isNotEmpty ||
      addOns.isNotEmpty ||
      customizationGroups.isNotEmpty ||
      isComboTemplate;

  MenuItemCustomizationGroup? customizationGroupById(String id) {
    for (final group in customizationGroups) {
      if (group.id == id) return group;
    }
    return null;
  }

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

  ComboPricingSummary comboPricingSummary(Map<String, List<String>> selections) {
    final comboTotal = price + customizationPrice(selections);
    var aLaCarteTotal = comboReferencePrice ?? comboTotal;
    for (final group in customizationGroups) {
      final selectedIds = selections[group.id] ?? const <String>[];
      for (final id in selectedIds) {
        aLaCarteTotal += group.optionById(id)?.referencePriceDelta ?? 0;
      }
    }
    return ComboPricingSummary(
      comboTotal: comboTotal,
      aLaCarteTotal: aLaCarteTotal,
    );
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
