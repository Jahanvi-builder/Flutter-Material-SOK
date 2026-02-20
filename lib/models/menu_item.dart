import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final IconData icon;
  final Color color;
  final List<String> sizes;
  final List<String> addOns;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.color,
    this.sizes = const [],
    this.addOns = const [],
  });
}
