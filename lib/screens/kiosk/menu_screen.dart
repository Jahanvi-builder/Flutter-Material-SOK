import 'package:flutter/material.dart';

import '../../data/mock_menu.dart';
import '../../main.dart' show themeNotifier;
import '../../models/cart_controller.dart';
import '../../models/menu_item.dart';
import '../../services/haptic_service.dart';
import 'cart_screen.dart';
import 'item_detail_sheet.dart';
import 'phone_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.cart});

  final CartController cart;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}


class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;
  bool _useSideNav = true;
  bool _railExtended = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  String? _phoneNumber;

  String get _selectedCategory => menuCategories[_selectedIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final phone = await showPhoneOtpDialog(context);
      if (mounted) setState(() => _phoneNumber = phone);
    });
  }

  List<MenuItem> get _filtered {
    final byCategory = _selectedCategory == 'All'
        ? menuItems
        : menuItems.where((i) => i.category == _selectedCategory).toList();
    if (_searchQuery.isEmpty) return byCategory;
    final q = _searchQuery.toLowerCase();
    return byCategory
        .where((i) => i.name.toLowerCase().contains(q) || i.description.toLowerCase().contains(q))
        .toList();
  }

  void _openDetail(MenuItem item) {
    HapticService.tap();
    showItemDetail(context, item, widget.cart);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasty Bites'),
        centerTitle: false,
        titleSpacing: 4,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          SizedBox(
            width: 240,
            height: 40,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search menu…',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_useSideNav ? Icons.view_day_outlined : Icons.view_sidebar_outlined),
            tooltip: _useSideNav ? 'Top navigation' : 'Side navigation',
            onPressed: () => setState(() => _useSideNav = !_useSideNav),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) => IconButton(
              icon: Icon(mode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded),
              tooltip: mode == ThemeMode.dark ? 'Light mode' : 'Dark mode',
              onPressed: () {
                themeNotifier.value = mode == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
          ),
          if (_phoneNumber != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Tooltip(
                message: '+91 $_phoneNumber',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_rounded,
                    size: 22,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final cartFab = ListenableBuilder(
            listenable: widget.cart,
            builder: (context, _) {
              if (widget.cart.isEmpty) return const SizedBox.shrink();

              final allCartItems = widget.cart.items;
              final cartItems = allCartItems.take(2).toList();
              final extraCount = allCartItems.length - 2;
              const imgSize = 40.0;
              const overlap = 20.0;
              const step = imgSize - overlap;
              final totalSlots = cartItems.length + (extraCount > 0 ? 1 : 0);

              Widget buildCircle(Widget child) => Container(
                width: imgSize,
                height: imgSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: ClipOval(child: child),
              );

              final slots = [
                ...cartItems.map((ci) {
                  final item = ci.item;
                  return buildCircle(
                    item.imagePath.isNotEmpty
                        ? Image.asset(item.imagePath, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: item.color.withAlpha(50),
                              child: Icon(item.icon, size: 12, color: item.color),
                            ))
                        : ColoredBox(
                            color: item.color.withAlpha(50),
                            child: Icon(item.icon, size: 12, color: item.color),
                          ),
                  );
                }),
                if (extraCount > 0)
                  buildCircle(ColoredBox(
                    color: Colors.white,
                    child: Center(
                      child: Text('+$extraCount',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ),
                  )),
              ];

              final imagesWidget = SizedBox(
                width: imgSize + (totalSlots - 1) * step,
                height: imgSize,
                child: Stack(
                  children: slots.asMap().entries
                      .map((e) => Positioned(left: e.key * step.toDouble(), child: e.value))
                      .toList(),
                ),
              );

              return Transform.scale(
                scale: 1.2,
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton.extended(
                    heroTag: 'cart_fab',
                    shape: const StadiumBorder(),
                    extendedPadding: const EdgeInsets.fromLTRB(8, 16, 20, 16),
                    onPressed: () {
                      HapticService.tap();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CartScreen(cart: widget.cart)));
                    },
                    label: Row(
                      children: [
                        imagesWidget,
                        const SizedBox(width: 12),
                        const Text('View Cart',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

          final menuGrid = Expanded(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = switch (width) {
                    < 600 => 1,
                    < 900 => 2,
                    _ => 3,
                  };
                  // Card width → 4:3 image height + fixed text/button area (~160px)
                  const hSpacing = 12.0;
                  const hPadding = 32.0; // 16 left + 16 right
                  final cardWidth = (width - hPadding - (columns - 1) * hSpacing) / columns;
                  final cardHeight = cardWidth * 3 / 4 + 190;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: hSpacing,
                      mainAxisSpacing: 12,
                      childAspectRatio: cardWidth / cardHeight,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) => _MenuItemCard(
                      item: _filtered[i],
                      cart: widget.cart,
                      onTap: () => _openDetail(_filtered[i]),
                    ),
                  );
                },
              ),
            ),
          );

          if (_useSideNav) {
            final cs = Theme.of(context).colorScheme;
            final tt = Theme.of(context).textTheme;

            Widget buildCatIcon(String cat) {
              if (cat == 'All') {
                return ClipOval(
                  child: SizedBox(
                    width: 40, height: 40,
                    child: ColoredBox(
                      color: cs.surfaceContainer,
                      child: Center(child: Icon(Icons.apps_rounded, size: 20, color: cs.onSurface)),
                    ),
                  ),
                );
              }
              final leader = menuItems.firstWhere(
                (item) => item.category == cat,
                orElse: () => menuItems.first,
              );
              return ClipOval(
                child: SizedBox(
                  width: 40, height: 40,
                  child: leader.imagePath.isNotEmpty
                      ? Image.asset(
                          leader.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: leader.color.withAlpha(50),
                            child: Center(child: Icon(leader.icon, size: 18, color: leader.color)),
                          ),
                        )
                      : ColoredBox(
                          color: leader.color.withAlpha(50),
                          child: Center(child: Icon(leader.icon, size: 18, color: leader.color)),
                        ),
                ),
              );
            }

            final customRail = AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _railExtended ? 220.0 : 72.0,
              color: cs.surface,
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: _railExtended ? 'Collapse' : 'Expand',
                        icon: Icon(_railExtended ? Icons.menu_open_rounded : Icons.menu_rounded),
                        onPressed: () => setState(() => _railExtended = !_railExtended),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      children: menuCategories.asMap().entries.map((e) {
                        final i = e.key;
                        final cat = e.value;
                        final selected = i == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(32),
                            onTap: () { HapticService.tap(); setState(() => _selectedIndex = i); },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: selected ? cs.surfaceContainerHigh : Colors.transparent,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  buildCatIcon(cat),
                                  Expanded(
                                    child: AnimatedOpacity(
                                      opacity: _railExtended ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 150),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Text(
                                          cat,
                                          style: tt.bodyLarge?.copyWith(
                                            fontSize: 15,
                                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                            color: selected ? cs.onSurface : cs.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );

            // card radius (12) + grid left padding (16) + 12 = 40
            const contentCornerRadius = 40.0;

            return Row(
              children: [
                customRail,
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(contentCornerRadius),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: Column(children: [menuGrid])),
                        Positioned(bottom: 0, left: 0, right: 0, child: Center(child: cartFab)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Top chip navigation (default)
          return Column(
            children: [
              // Category chips
              SizedBox(
                height: 80,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: menuCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = menuCategories[i];
                    final selected = cat == _selectedCategory;

                    Widget chipLabel;
                    if (cat == 'All') {
                      chipLabel = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: ColoredBox(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                child: Center(
                                  child: Icon(Icons.apps_rounded, size: 16,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('All', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      );
                    } else {
                      final leader = menuItems.firstWhere(
                        (item) => item.category == cat,
                        orElse: () => menuItems.first,
                      );
                      chipLabel = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: leader.imagePath.isNotEmpty
                                  ? Image.asset(
                                      leader.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => ColoredBox(
                                        color: leader.color.withAlpha(50),
                                        child: Center(child: Icon(leader.icon, size: 14, color: leader.color)),
                                      ),
                                    )
                                  : ColoredBox(
                                      color: leader.color.withAlpha(50),
                                      child: Center(child: Icon(leader.icon, size: 14, color: leader.color)),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      );
                    }

                    return FilterChip(
                      label: chipLabel,
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedIndex = menuCategories.indexOf(cat)),
                      showCheckmark: false,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    );
                  },
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    Column(children: [menuGrid]),
                    Positioned(bottom: 0, left: 0, right: 0, child: Center(child: cartFab)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Color _starColor(double rating) {
  if (rating >= 4.5) return const Color(0xFF2E7D32); // dark green
  if (rating >= 4.0) return const Color(0xFFFFA726); // amber
  if (rating >= 3.5) return const Color(0xFF66BB6A); // light green
  return const Color(0xFFFFA726);
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.cart, required this.onTap});

  final MenuItem item;
  final CartController cart;
  final VoidCallback onTap;

  bool get _isCustomizable => item.sizes.isNotEmpty || item.addOns.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image — real asset when available, icon placeholder otherwise
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imagePath.isNotEmpty
                      ? Image.asset(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: item.color.withAlpha(50),
                            child: Center(child: Icon(item.icon, size: 64, color: item.color)),
                          ),
                        )
                      : ColoredBox(
                          color: item.color.withAlpha(50),
                          child: Center(child: Icon(item.icon, size: 64, color: item.color)),
                        ),
                  Positioned(
                    bottom: 10,
                    left: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: tt.labelMedium?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(Icons.star_rounded, size: 14, color: _starColor(item.rating)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text block — Expanded so it fills remaining space and
            // pushes the button to the bottom; maxLines keeps it fixed visually
            Expanded(
              child: ClipRect(
                child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: tt.titleSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: tt.bodySmall?.copyWith(fontSize: 14, color: cs.onSurfaceVariant.withAlpha(140)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ),
            ),

            // Price + add button — always at bottom
            ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttonWidth = constraints.maxWidth * 0.5;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: '₹',
                                style: tt.titleSmall?.copyWith(
                                  fontSize: 13,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '${item.price.round()}',
                                style: tt.titleSmall?.copyWith(
                                  fontSize: 22,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]),
                          ),
                          if (item.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹${item.originalPrice!.round()}',
                              style: tt.bodySmall?.copyWith(
                                fontSize: 13,
                                color: cs.onSurfaceVariant.withAlpha(120),
                                decoration: TextDecoration.lineThrough,
                                decorationColor: cs.onSurfaceVariant.withAlpha(120),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (_isCustomizable)
                        FilledButton.tonal(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            fixedSize: Size(buttonWidth, 56),
                            iconSize: 22,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'GoogleSansFlex', fontVariations: [FontVariation('ROND', 100.0)]),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 6),
                              Text('Add'),
                            ],
                          ),
                        )
                      else
                        ListenableBuilder(
                          listenable: cart,
                          builder: (context, _) {
                            final matches = cart.items.where((ci) => ci.item.id == item.id);
                            final cartItem = matches.isEmpty ? null : matches.first;
                            final count = cartItem?.quantity ?? 0;

                            if (count == 0) {
                              return FilledButton.tonal(
                                onPressed: () {
                                  HapticService.tap();
                                  cart.add(item);
                                },
                                style: FilledButton.styleFrom(
                                  fixedSize: Size(buttonWidth, 56),
                                  iconSize: 22,
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'GoogleSansFlex', fontVariations: [FontVariation('ROND', 100.0)]),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add),
                                    SizedBox(width: 6),
                                    Text('Add'),
                                  ],
                                ),
                              );
                            }

                            return SizedBox(
                              width: buttonWidth,
                              height: 56,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(color: cs.outlineVariant),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      constraints: const BoxConstraints.tightFor(width: 56, height: 56),
                                      onPressed: () { HapticService.tap(); cart.decrement(cartItem!); },
                                    ),
                                    Text('$count', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      constraints: const BoxConstraints.tightFor(width: 56, height: 56),
                                      onPressed: () { HapticService.tap(); cart.increment(cartItem!); },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
