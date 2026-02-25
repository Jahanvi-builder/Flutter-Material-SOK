import 'package:flutter/material.dart';

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
  final String imagePath; // filename only; full path resolved when images are available
  final IconData icon;
  final Color color;
  final List<String> sizes;
  final List<String> addOns;
  final double rating;

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
    this.rating = 4.0,
  });
}
