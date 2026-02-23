import 'package:flutter/material.dart';

import '../models/menu_item.dart';

const List<String> menuCategories = [
  'All',
  'North Indian',
  'South Indian',
  'Indo-Chinese',
  'Quick Bites',
  'Beverages',
];

const List<MenuItem> menuItems = [

  // ── North Indian › Breads ─────────────────────────────────────────────────
  MenuItem(
    id: 'NI_001', name: 'Butter Naan',
    description: 'Freshly baked clay oven bread glazed with butter.',
    price: 45, category: 'North Indian', subCategory: 'Breads',
    isVeg: true, spiceLevel: 0, prepTime: '8 mins',
    imagePath: 'Butter_Naan.jpg',
    icon: Icons.bakery_dining, color: Color(0xFFFFB74D),
  ),
  MenuItem(
    id: 'NI_002', name: 'Tandoori Roti',
    description: 'Whole wheat bread baked in a traditional clay oven.',
    price: 35, category: 'North Indian', subCategory: 'Breads',
    isVeg: true, spiceLevel: 0, prepTime: '8 mins',
    imagePath: 'Tandoori_Roti.jpg',
    icon: Icons.bakery_dining, color: Color(0xFFFF8A65),
  ),
  MenuItem(
    id: 'NI_003', name: 'Garlic Naan',
    description: 'Leavened bread topped with minced garlic and herbs.',
    price: 60, category: 'North Indian', subCategory: 'Breads',
    isVeg: true, spiceLevel: 1, prepTime: '10 mins',
    imagePath: 'Garlic_Naan.jpg',
    icon: Icons.bakery_dining, color: Color(0xFFFF7043),
  ),
  MenuItem(
    id: 'NI_004', name: 'Lachha Paratha',
    description: 'Multi-layered flaky whole wheat bread.',
    price: 55, category: 'North Indian', subCategory: 'Breads',
    isVeg: true, spiceLevel: 0, prepTime: '10 mins',
    imagePath: 'Lachha_Paratha.jpg',
    icon: Icons.bakery_dining, color: Color(0xFFA1887F),
  ),

  // ── North Indian › Gravy (Veg) ────────────────────────────────────────────
  MenuItem(
    id: 'NI_005', name: 'Dal Makhani',
    description: 'Slow-cooked black lentils with cream and butter.',
    price: 180, category: 'North Indian', subCategory: 'Gravy (Veg)',
    isVeg: true, spiceLevel: 1, prepTime: '5 mins',
    imagePath: 'Dal_Makhani.jpg',
    icon: Icons.soup_kitchen, color: Color(0xFFBF360C),
  ),
  MenuItem(
    id: 'NI_006', name: 'Dal Tadka',
    description: 'Yellow lentils tempered with garlic, cumin, and dry red chilies.',
    price: 160, category: 'North Indian', subCategory: 'Gravy (Veg)',
    isVeg: true, spiceLevel: 2, prepTime: '5 mins',
    imagePath: 'Dal_Tadka.jpg',
    icon: Icons.soup_kitchen, color: Color(0xFFF57F17),
  ),
  MenuItem(
    id: 'NI_008', name: 'Paneer Tikka Masala',
    description: 'Grilled cottage cheese in a spicy onion-tomato gravy.',
    price: 220, category: 'North Indian', subCategory: 'Gravy (Veg)',
    isVeg: true, spiceLevel: 3, prepTime: '15 mins',
    imagePath: 'Paneer_Tikka_Masala.jpg',
    icon: Icons.soup_kitchen, color: Color(0xFFFF7043),
  ),
  MenuItem(
    id: 'NI_009', name: 'Malai Kofta',
    description: 'Soft paneer dumplings in a rich, sweet cashew gravy.',
    price: 240, category: 'North Indian', subCategory: 'Gravy (Veg)',
    isVeg: true, spiceLevel: 0, prepTime: '15 mins',
    imagePath: 'Malai_Kofta.jpg',
    icon: Icons.soup_kitchen, color: Color(0xFFFFAB91),
  ),
  MenuItem(
    id: 'NI_010', name: 'Bhindi Do Pyaza',
    description: 'Stir-fried okra with double onions and spices.',
    price: 170, category: 'North Indian', subCategory: 'Gravy (Veg)',
    isVeg: true, spiceLevel: 2, prepTime: '12 mins',
    imagePath: 'Bhindi_Do_Pyaza.jpg',
    icon: Icons.set_meal, color: Color(0xFF8BC34A),
  ),

  // ── North Indian › Starters ───────────────────────────────────────────────
  MenuItem(
    id: 'NI_007', name: 'Paneer Tikka Angare',
    description: 'Smokey, spicy cottage cheese cubes grilled in a tandoor.',
    price: 240, category: 'North Indian', subCategory: 'Starters',
    isVeg: true, spiceLevel: 4, prepTime: '15 mins',
    imagePath: 'Paneer_Tikka_Angare.jpg',
    icon: Icons.kebab_dining, color: Color(0xFFFF5722),
  ),

  // ── North Indian › Gravy (Non-Veg) ───────────────────────────────────────
  MenuItem(
    id: 'NI_011', name: 'Murgh Lababdar',
    description: 'Boneless chicken in a creamy, tangy tomato sauce.',
    price: 280, category: 'North Indian', subCategory: 'Gravy (Non-Veg)',
    isVeg: false, spiceLevel: 2, prepTime: '18 mins',
    imagePath: 'Murgh_Lababdar.jpg',
    icon: Icons.set_meal, color: Color(0xFFFF8A65),
  ),
  MenuItem(
    id: 'NI_012', name: 'Classic Butter Chicken',
    description: 'Tandoori chicken pulled and cooked in a velvety butter sauce.',
    price: 320, category: 'North Indian', subCategory: 'Gravy (Non-Veg)',
    isVeg: false, spiceLevel: 1, prepTime: '18 mins',
    imagePath: 'Classic_Butter_Chicken.jpg',
    icon: Icons.set_meal, color: Color(0xFFFFB74D),
  ),
  MenuItem(
    id: 'NI_013', name: 'Mutton Rogan Josh',
    description: 'Slow-cooked lamb in a traditional Kashmiri red chili gravy.',
    price: 450, category: 'North Indian', subCategory: 'Gravy (Non-Veg)',
    isVeg: false, spiceLevel: 4, prepTime: '25 mins',
    imagePath: 'Mutton_Rogan_Josh.jpg',
    icon: Icons.set_meal, color: Color(0xFFD32F2F),
  ),

  // ── North Indian › Rice ───────────────────────────────────────────────────
  MenuItem(
    id: 'NI_014', name: 'Vegetable Pulao',
    description: 'Fragrant Basmati rice with seasonal veggies and mild spices.',
    price: 150, category: 'North Indian', subCategory: 'Rice',
    isVeg: true, spiceLevel: 1, prepTime: '10 mins',
    imagePath: 'Vegetable_Pulao.jpg',
    icon: Icons.rice_bowl, color: Color(0xFF81C784),
  ),
  MenuItem(
    id: 'NI_015', name: 'Lucknowi Chicken Biryani',
    description: 'Fragrant Basmati rice cooked with spice-marinated chicken.',
    price: 280, category: 'North Indian', subCategory: 'Rice',
    isVeg: false, spiceLevel: 3, prepTime: '15 mins',
    imagePath: 'Lucknowi_Chicken_Biryani.jpg',
    icon: Icons.rice_bowl, color: Color(0xFFFFCA28),
  ),
  MenuItem(
    id: 'NI_016', name: 'Jeera Rice',
    description: 'Steamed Basmati rice tempered with cumin seeds and ghee.',
    price: 140, category: 'North Indian', subCategory: 'Rice',
    isVeg: true, spiceLevel: 1, prepTime: '5 mins',
    imagePath: 'Jeera_Rice.jpg',
    icon: Icons.rice_bowl, color: Color(0xFFFFF176),
  ),

  // ── South Indian › Tiffin ─────────────────────────────────────────────────
  MenuItem(
    id: 'SI_001', name: 'Ghee Podi Idli',
    description: 'Steamed rice cakes tossed in spicy lentil powder and ghee.',
    price: 90, category: 'South Indian', subCategory: 'Tiffin',
    isVeg: true, spiceLevel: 3, prepTime: '5 mins',
    imagePath: 'Ghee_Podi_Idli_(2_pcs).jpg',
    icon: Icons.breakfast_dining, color: Color(0xFFBCAAA4),
  ),
  MenuItem(
    id: 'SI_002', name: 'Medu Vada',
    description: 'Savory lentil doughnuts served with sambar and chutney.',
    price: 90, category: 'South Indian', subCategory: 'Tiffin',
    isVeg: true, spiceLevel: 1, prepTime: '8 mins',
    imagePath: 'Medu_Vada_(2_pcs).jpg',
    icon: Icons.breakfast_dining, color: Color(0xFFFFCA28),
  ),
  MenuItem(
    id: 'SI_009', name: 'Ven Pongal',
    description: 'Peppery rice and moong dal mash tempered with cashews.',
    price: 95, category: 'South Indian', subCategory: 'Tiffin',
    isVeg: true, spiceLevel: 1, prepTime: '5 mins',
    imagePath: 'Ven_Pongal.jpg',
    icon: Icons.breakfast_dining, color: Color(0xFFFFF9C4),
  ),

  // ── South Indian › Dosa ───────────────────────────────────────────────────
  MenuItem(
    id: 'SI_003', name: 'Mysore Masala Dosa',
    description: 'Crispy crepe with spicy red chutney and potato mash.',
    price: 120, category: 'South Indian', subCategory: 'Dosa',
    isVeg: true, spiceLevel: 2, prepTime: '10 mins',
    imagePath: 'Mysore_Masala_Dosa.jpg',
    icon: Icons.breakfast_dining, color: Color(0xFFFFB74D),
  ),
  MenuItem(
    id: 'SI_004', name: 'Onion Rava Dosa',
    description: 'Thin, lacy semolina crepe with chopped onions.',
    price: 130, category: 'South Indian', subCategory: 'Dosa',
    isVeg: true, spiceLevel: 1, prepTime: '12 mins',
    imagePath: 'Onion_Rava_Dosa.jpg',
    icon: Icons.breakfast_dining, color: Color(0xFFFFE082),
  ),
  MenuItem(
    id: 'SI_005', name: 'Set Dosa',
    description: 'Soft, spongy pancakes served with vegetable saagu.',
    price: 110, category: 'South Indian', subCategory: 'Dosa',
    isVeg: true, spiceLevel: 1, prepTime: '10 mins',
    imagePath: 'Set_Dosa_(3_pcs).jpg',
    icon: Icons.breakfast_dining, color: Color(0xFFFFECB3),
  ),

  // ── South Indian › Uttapam ────────────────────────────────────────────────
  MenuItem(
    id: 'SI_010', name: 'Tomato & Onion Uttapam',
    description: 'Thick savory pancake topped with tomatoes and onions.',
    price: 115, category: 'South Indian', subCategory: 'Uttapam',
    isVeg: true, spiceLevel: 1, prepTime: '12 mins',
    imagePath: 'Tomato_&_Onion_Uttapam.jpg',
    icon: Icons.breakfast_dining, color: Color(0xFFFF8A65),
  ),

  // ── South Indian › Rice ───────────────────────────────────────────────────
  MenuItem(
    id: 'SI_006', name: 'Bisi Bele Bath',
    description: 'Hot lentil rice with tamarind, veggies, and ghee.',
    price: 100, category: 'South Indian', subCategory: 'Rice',
    isVeg: true, spiceLevel: 3, prepTime: '5 mins',
    imagePath: 'Bisi_Bele_Bath.jpg',
    icon: Icons.rice_bowl, color: Color(0xFFEF5350),
  ),
  MenuItem(
    id: 'SI_008', name: 'Curd Rice',
    description: 'Rice tempered with mustard, curry leaves, and pomegranate.',
    price: 80, category: 'South Indian', subCategory: 'Rice',
    isVeg: true, spiceLevel: 0, prepTime: '3 mins',
    imagePath: 'Curd_Rice.jpg',
    icon: Icons.rice_bowl, color: Color(0xFFB2EBF2),
  ),
  MenuItem(
    id: 'SI_011', name: 'Lemon Rice',
    description: 'Tangy rice tempered with peanuts and turmeric.',
    price: 90, category: 'South Indian', subCategory: 'Rice',
    isVeg: true, spiceLevel: 1, prepTime: '5 mins',
    imagePath: 'Lemon_Rice.jpg',
    icon: Icons.rice_bowl, color: Color(0xFFFFEE58),
  ),
  MenuItem(
    id: 'SI_012', name: 'Puliogare',
    description: 'Traditional spicy and sour tamarind-based rice.',
    price: 95, category: 'South Indian', subCategory: 'Rice',
    isVeg: true, spiceLevel: 3, prepTime: '5 mins',
    imagePath: 'Puliogare_(Tamarind_Rice).jpg',
    icon: Icons.rice_bowl, color: Color(0xFF795548),
  ),

  // ── South Indian › Curry ──────────────────────────────────────────────────
  MenuItem(
    id: 'SI_007', name: 'Chettinad Veg Curry',
    description: 'Spicy, peppery mixed vegetable curry with coconut base.',
    price: 160, category: 'South Indian', subCategory: 'Curry',
    isVeg: true, spiceLevel: 4, prepTime: '15 mins',
    imagePath: 'Chettinad_Veg_Curry.jpg',
    icon: Icons.soup_kitchen, color: Color(0xFF2E7D32),
  ),
  MenuItem(
    id: 'SI_013', name: 'Vegetable Ishtu',
    description: 'Mild, coconut milk-based stew with seasonal veggies.',
    price: 140, category: 'South Indian', subCategory: 'Curry',
    isVeg: true, spiceLevel: 0, prepTime: '15 mins',
    imagePath: 'Vegetable_Ishtu_(Stew).jpg',
    icon: Icons.soup_kitchen, color: Color(0xFF80CBC4),
  ),
  MenuItem(
    id: 'SI_014', name: 'Chicken Ghee Roast',
    description: 'Fiery Mangalorean chicken with clarified butter.',
    price: 310, category: 'South Indian', subCategory: 'Curry',
    isVeg: false, spiceLevel: 5, prepTime: '20 mins',
    imagePath: 'Chicken_Ghee_Roast.jpg',
    icon: Icons.set_meal, color: Color(0xFFB71C1C),
  ),

  // ── Indo-Chinese › Soup ───────────────────────────────────────────────────
  MenuItem(
    id: 'IC_001', name: 'Veg Manchow Soup',
    description: 'Spicy soup topped with crunchy fried noodles.',
    price: 110, category: 'Indo-Chinese', subCategory: 'Soup',
    isVeg: true, spiceLevel: 3, prepTime: '8 mins',
    imagePath: 'Veg_Manchow_Soup.jpg',
    icon: Icons.soup_kitchen, color: Color(0xFFEF9A9A),
  ),
  MenuItem(
    id: 'IC_002', name: 'Hot & Sour Chicken Soup',
    description: 'Thick peppery soup with shredded chicken.',
    price: 130, category: 'Indo-Chinese', subCategory: 'Soup',
    isVeg: false, spiceLevel: 3, prepTime: '8 mins',
    imagePath: 'Hot_&_Sour_Chicken_Soup.jpg',
    icon: Icons.soup_kitchen, color: Color(0xFFEF5350),
  ),

  // ── Indo-Chinese › Starters ───────────────────────────────────────────────
  MenuItem(
    id: 'IC_003', name: 'Honey Chilli Potato',
    description: 'Crispy potatoes in sweet and spicy sesame glaze.',
    price: 160, category: 'Indo-Chinese', subCategory: 'Starters',
    isVeg: true, spiceLevel: 2, prepTime: '12 mins',
    imagePath: 'Honey_Chilli_Potato.jpg',
    icon: Icons.fastfood, color: Color(0xFFFFCA28),
  ),
  MenuItem(
    id: 'IC_004', name: 'Veg Manchurian (Dry)',
    description: 'Fried veggie balls in ginger-garlic soy sauce.',
    price: 190, category: 'Indo-Chinese', subCategory: 'Starters',
    isVeg: true, spiceLevel: 2, prepTime: '15 mins',
    imagePath: 'Veg_Manchurian_(Dry).jpg',
    icon: Icons.fastfood, color: Color(0xFF8BC34A),
  ),
  MenuItem(
    id: 'IC_005', name: 'Chilli Chicken (Dry)',
    description: 'Chicken tossed with bell peppers and green chilies.',
    price: 260, category: 'Indo-Chinese', subCategory: 'Starters',
    isVeg: false, spiceLevel: 4, prepTime: '12 mins',
    imagePath: 'Chilli_Chicken_(Dry).jpg',
    icon: Icons.fastfood, color: Color(0xFFE53935),
  ),

  // ── Indo-Chinese › Main Gravy ─────────────────────────────────────────────
  MenuItem(
    id: 'IC_006', name: 'Paneer in Hot Garlic Sauce',
    description: 'Paneer cubes in bold, pungent garlic gravy.',
    price: 220, category: 'Indo-Chinese', subCategory: 'Main Gravy',
    isVeg: true, spiceLevel: 4, prepTime: '15 mins',
    imagePath: 'Paneer_in_Hot_Garlic_Sauce.jpg',
    icon: Icons.set_meal, color: Color(0xFFEF5350),
  ),
  MenuItem(
    id: 'IC_007', name: 'Chicken Manchurian',
    description: 'Chicken dumplings in thick, savory soy gravy.',
    price: 280, category: 'Indo-Chinese', subCategory: 'Main Gravy',
    isVeg: false, spiceLevel: 2, prepTime: '18 mins',
    imagePath: 'Chicken_Manchurian_(Gravy).jpg',
    icon: Icons.set_meal, color: Color(0xFF5D4037),
  ),

  // ── Indo-Chinese › Rice ───────────────────────────────────────────────────
  MenuItem(
    id: 'IC_008', name: 'Veg Fried Rice',
    description: 'Wok-tossed rice with scallions and vegetables.',
    price: 180, category: 'Indo-Chinese', subCategory: 'Rice',
    isVeg: true, spiceLevel: 1, prepTime: '10 mins',
    imagePath: 'Veg_Fried_Rice.jpg',
    icon: Icons.rice_bowl, color: Color(0xFFBA68C8),
  ),
  MenuItem(
    id: 'IC_009', name: 'Schezwan Egg Fried Rice',
    description: 'Rice tossed in spicy house-made Schezwan sauce.',
    price: 210, category: 'Indo-Chinese', subCategory: 'Rice',
    isVeg: false, spiceLevel: 5, prepTime: '10 mins',
    imagePath: 'Schezwan_Egg_Fried_Rice.jpg',
    icon: Icons.rice_bowl, color: Color(0xFFFF5722),
  ),

  // ── Indo-Chinese › Noodles ────────────────────────────────────────────────
  MenuItem(
    id: 'IC_010', name: 'Veg Hakka Noodles',
    description: 'Classic stir-fried noodles with julienne veggies.',
    price: 180, category: 'Indo-Chinese', subCategory: 'Noodles',
    isVeg: true, spiceLevel: 1, prepTime: '12 mins',
    imagePath: 'Veg_Hakka_Noodles.jpg',
    icon: Icons.ramen_dining, color: Color(0xFF9575CD),
  ),
  MenuItem(
    id: 'IC_011', name: 'Chicken Chilli Garlic Noodles',
    description: 'Spicy noodles with burnt garlic and chili flakes.',
    price: 240, category: 'Indo-Chinese', subCategory: 'Noodles',
    isVeg: false, spiceLevel: 4, prepTime: '12 mins',
    imagePath: 'Chicken_Chilli_Garlic_Noodles.jpg',
    icon: Icons.ramen_dining, color: Color(0xFFB71C1C),
  ),

  // ── Quick Bites › Snacks ──────────────────────────────────────────────────
  MenuItem(
    id: 'QB_001', name: 'Samosa',
    description: 'Potato-filled pastry with mint and tamarind chutneys.',
    price: 50, category: 'Quick Bites', subCategory: 'Snacks',
    isVeg: true, spiceLevel: 2, prepTime: '5 mins',
    imagePath: 'Samosa_(2_pcs).jpg',
    icon: Icons.fastfood, color: Color(0xFFFFCA28),
  ),
  MenuItem(
    id: 'QB_002', name: 'Mirchi Bajji',
    description: 'Large battered and deep-fried stuffed chilies.',
    price: 60, category: 'Quick Bites', subCategory: 'Snacks',
    isVeg: true, spiceLevel: 5, prepTime: '8 mins',
    imagePath: 'Mirchi_Bajji.jpg',
    icon: Icons.fastfood, color: Color(0xFF66BB6A),
  ),
  MenuItem(
    id: 'QB_003', name: 'Chicken 65',
    description: 'Spicy deep-fried chicken bites with curry leaves.',
    price: 220, category: 'Quick Bites', subCategory: 'Snacks',
    isVeg: false, spiceLevel: 4, prepTime: '10 mins',
    imagePath: 'Chicken_65.jpg',
    icon: Icons.fastfood, color: Color(0xFFFF5722),
  ),

  // ── Beverages › Cold ─────────────────────────────────────────────────────
  MenuItem(
    id: 'BEV_001', name: 'Watermelon Mint Cooler',
    description: 'Fresh juice with black salt and mint.',
    price: 90, category: 'Beverages', subCategory: 'Cold',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Watermelon_Mint_Cooler.jpg',
    icon: Icons.local_drink, color: Color(0xFFEF9A9A),
  ),
  MenuItem(
    id: 'BEV_002', name: 'ABC Juice',
    description: 'Apple, Beetroot, and Carrot blend.',
    price: 110, category: 'Beverages', subCategory: 'Cold',
    isVeg: true, spiceLevel: 0, prepTime: '8 mins',
    imagePath: 'ABC_Juice.jpg',
    icon: Icons.local_drink, color: Color(0xFFCE93D8),
  ),
  MenuItem(
    id: 'BEV_003', name: 'Fresh Orange Juice',
    description: '100% natural Valencia orange juice.',
    price: 70, category: 'Beverages', subCategory: 'Cold',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Fresh_Orange_Juice.jpg',
    icon: Icons.local_drink, color: Color(0xFFFF9800),
  ),
  MenuItem(
    id: 'BEV_006', name: 'Classic Cold Coffee',
    description: 'Blended coffee with milk and vanilla ice cream.',
    price: 130, category: 'Beverages', subCategory: 'Cold',
    isVeg: true, spiceLevel: 0, prepTime: '7 mins',
    imagePath: 'Classic_Cold_Coffee.jpg',
    icon: Icons.local_cafe, color: Color(0xFF795548),
  ),
  MenuItem(
    id: 'BEV_012', name: 'Iced Green Tea',
    description: 'Refreshing cold green tea with honey and lemon.',
    price: 70, category: 'Beverages', subCategory: 'Cold',
    isVeg: true, spiceLevel: 0, prepTime: '3 mins',
    imagePath: 'Iced_Green_Tea.jpg',
    icon: Icons.local_drink, color: Color(0xFF81C784),
  ),
  MenuItem(
    id: 'BEV_013', name: 'Lychee Sparkler',
    description: 'Lychee juice topped with soda and lime.',
    price: 95, category: 'Beverages', subCategory: 'Cold',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Lychee_Sparkler.jpg',
    icon: Icons.local_drink, color: Color(0xFFFF80AB),
  ),

  // ── Beverages › Mocktail ──────────────────────────────────────────────────
  MenuItem(
    id: 'BEV_004', name: 'Spicy Guava Mocktail',
    description: 'Guava juice with a chili-rimmed glass.',
    price: 110, category: 'Beverages', subCategory: 'Mocktail',
    isVeg: true, spiceLevel: 2, prepTime: '5 mins',
    imagePath: 'Spicy_Guava_Mocktail.jpg',
    icon: Icons.local_bar, color: Color(0xFFF48FB1),
  ),
  MenuItem(
    id: 'BEV_005', name: 'Blue Lagoon',
    description: 'Citrus-based blue curacao syrup with lemon-lime soda.',
    price: 110, category: 'Beverages', subCategory: 'Mocktail',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Blue_Lagoon.jpg',
    icon: Icons.local_bar, color: Color(0xFF42A5F5),
  ),

  // ── Beverages › Hot ───────────────────────────────────────────────────────
  MenuItem(
    id: 'BEV_015', name: 'Masala Chai',
    description: 'Strong brewed tea with ginger, cardamom, and cloves.',
    price: 25, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 1, prepTime: '5 mins',
    imagePath: 'Masala_Chai.jpg',
    icon: Icons.coffee, color: Color(0xFFFF8F00),
  ),
  MenuItem(
    id: 'BEV_016', name: 'Filter Kaapi',
    description: 'Traditional South Indian decoction with frothed milk.',
    price: 30, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Filter_Kaapi.jpg',
    icon: Icons.coffee, color: Color(0xFF6D4C41),
  ),
  MenuItem(
    id: 'BEV_007', name: 'Ginger Cardamom Tea',
    description: 'The classic Indian Adrak-Elaichi chai.',
    price: 30, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 1, prepTime: '5 mins',
    imagePath: 'Ginger_Cardamom_Tea.jpg',
    icon: Icons.coffee, color: Color(0xFFFFB74D),
  ),
  MenuItem(
    id: 'BEV_008', name: 'Lemon Honey Tea',
    description: 'Light black tea infused with fresh lemon and honey.',
    price: 40, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 0, prepTime: '3 mins',
    imagePath: 'Lemon_Honey_Tea.jpg',
    icon: Icons.coffee, color: Color(0xFFFFEE58),
  ),
  MenuItem(
    id: 'BEV_014', name: 'Jasmine Tea',
    description: 'Fragrant hot oriental tea served without milk.',
    price: 60, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Jasmine_Tea.jpg',
    icon: Icons.coffee, color: Color(0xFFE1BEE7),
  ),
  MenuItem(
    id: 'BEV_011', name: 'Espresso Shot',
    description: 'Intense, concentrated coffee for a quick caffeine kick.',
    price: 60, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 0, prepTime: '2 mins',
    imagePath: 'Espresso_Shot.jpg',
    icon: Icons.coffee, color: Color(0xFF4E342E),
  ),
  MenuItem(
    id: 'BEV_009', name: 'Bournvita',
    description: 'Warm malt-based chocolate milk drink.',
    price: 50, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Bournvita.jpg',
    icon: Icons.coffee, color: Color(0xFF5D4037),
  ),
  MenuItem(
    id: 'BEV_010', name: 'Horlicks',
    description: 'Warm malt-based milk drink.',
    price: 50, category: 'Beverages', subCategory: 'Hot',
    isVeg: true, spiceLevel: 0, prepTime: '5 mins',
    imagePath: 'Horlicks.jpg',
    icon: Icons.coffee, color: Color(0xFF8D6E63),
  ),
];
