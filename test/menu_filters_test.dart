import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sok_material/models/menu_item.dart';
import 'package:sok_material/screens/kiosk/menu_filters.dart';

void main() {
  const items = [
    MenuItem(
      id: 'veg_quick',
      name: 'Veg Meal',
      description: 'Fresh and light',
      price: 120,
      category: 'Combos',
      subCategory: 'Lunch',
      isVeg: true,
      spiceLevel: 1,
      prepTime: '8 mins',
      imagePath: '',
      icon: Icons.restaurant,
      color: Color(0xFF66BB6A),
      rating: 4.7,
      originalPrice: 150,
    ),
    MenuItem(
      id: 'veg_spicy',
      name: 'Veg Curry',
      description: 'Spicy house curry',
      price: 160,
      category: 'North Indian',
      subCategory: 'Gravy',
      isVeg: true,
      spiceLevel: 4,
      prepTime: '14 mins',
      imagePath: '',
      icon: Icons.soup_kitchen,
      color: Color(0xFF81C784),
      rating: 4.3,
    ),
    MenuItem(
      id: 'nonveg_quick',
      name: 'Chicken Roll',
      description: 'Quick bite for pickup',
      price: 180,
      category: 'Quick Bites',
      subCategory: 'Rolls',
      isVeg: false,
      spiceLevel: 2,
      prepTime: '10 mins',
      imagePath: '',
      icon: Icons.fastfood,
      color: Color(0xFFE57373),
      rating: 4.8,
    ),
  ];

  test('default filters show all items', () {
    final filtered = filterMenuItems(
      items,
      category: 'All',
      searchQuery: '',
      filters: MenuFilterState.empty,
    );

    expect(filtered, hasLength(3));
  });

  test('veg only returns veg dishes', () {
    final filtered = filterMenuItems(
      items,
      category: 'All',
      searchQuery: '',
      filters: const MenuFilterState(foodType: FoodTypeFilter.veg),
    );

    expect(filtered.map((item) => item.id), ['veg_quick', 'veg_spicy']);
  });

  test('non-veg only returns non-veg dishes', () {
    final filtered = filterMenuItems(
      items,
      category: 'All',
      searchQuery: '',
      filters: const MenuFilterState(foodType: FoodTypeFilter.nonVeg),
    );

    expect(filtered.map((item) => item.id), ['nonveg_quick']);
  });

  test('category and search combine with veg filter', () {
    final filtered = filterMenuItems(
      items,
      category: 'Combos',
      searchQuery: 'veg',
      filters: const MenuFilterState(foodType: FoodTypeFilter.veg),
    );

    expect(filtered.map((item) => item.id), ['veg_quick']);
  });
}
