import 'package:flutter/material.dart';

import '../../data/mock_menu.dart';
import '../../models/cart_controller.dart';
import '../../models/menu_item.dart';
import '../../services/haptic_service.dart';
import 'cart_screen.dart';
import 'item_detail_sheet.dart';

// Explicit M3 NavigationRailDestinations — outlined icon (unselected),
// filled icon (selected), matching the M3 icon-state convention.
const _railDestinations = <NavigationRailDestination>[
  NavigationRailDestination(
    icon:         Icon(Icons.restaurant_menu_outlined),
    selectedIcon: Icon(Icons.restaurant_menu),
    label:        Text('All'),
  ),
  NavigationRailDestination(
    icon:         Icon(Icons.local_cafe_outlined),
    selectedIcon: Icon(Icons.local_cafe),
    label:        Text('Beverages'),
  ),
  NavigationRailDestination(
    icon:         Icon(Icons.dinner_dining_outlined),
    selectedIcon: Icon(Icons.dinner_dining),
    label:        Text('Combos'),
  ),
  NavigationRailDestination(
    icon:         Icon(Icons.kebab_dining_outlined),
    selectedIcon: Icon(Icons.kebab_dining),
    label:        Text('North Indian'),
  ),
  NavigationRailDestination(
    icon:         Icon(Icons.breakfast_dining_outlined),
    selectedIcon: Icon(Icons.breakfast_dining),
    label:        Text('South Indian'),
  ),
  NavigationRailDestination(
    icon:         Icon(Icons.ramen_dining_outlined),
    selectedIcon: Icon(Icons.ramen_dining),
    label:        Text('Indo-Chinese'),
  ),
  NavigationRailDestination(
    icon:         Icon(Icons.fastfood_outlined),
    selectedIcon: Icon(Icons.fastfood),
    label:        Text('Quick Bites'),
  ),
];

/// Wrapper that owns the CartController for the /left route.
class LeftNavMenuRoute extends StatefulWidget {
  const LeftNavMenuRoute({super.key});

  @override
  State<LeftNavMenuRoute> createState() => _LeftNavMenuRouteState();
}

class _LeftNavMenuRouteState extends State<LeftNavMenuRoute> {
  final _cart = CartController(orderType: OrderType.dineIn);

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MenuScreenLeft(cart: _cart);
}

class MenuScreenLeft extends StatefulWidget {
  const MenuScreenLeft({super.key, required this.cart, this.phoneNumber});

  final CartController cart;
  final String? phoneNumber;

  @override
  State<MenuScreenLeft> createState() => _MenuScreenLeftState();
}

class _MenuScreenLeftState extends State<MenuScreenLeft> {
  int _selectedIndex = 0;
  bool _extended = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  String get _selectedCategory => menuCategories[_selectedIndex];

  List<MenuItem> get _filtered {
    final byCategory = _selectedCategory == 'All'
        ? menuItems
        : menuItems.where((i) => i.category == _selectedCategory).toList();
    if (_searchQuery.isEmpty) return byCategory;
    final q = _searchQuery.toLowerCase();
    return byCategory
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q))
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasty Bites'),
        centerTitle: false,
        actions: [
          if (widget.phoneNumber != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Tooltip(
                message: '+91 ${widget.phoneNumber}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.person_rounded, size: 22,
                      color: cs.onPrimaryContainer),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Row(
        children: [
          // ── Left navigation rail ─────────────────────────────────────────
          NavigationRail(
            extended: _extended,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) =>
                setState(() => _selectedIndex = i),
            leading: IconButton(
              tooltip: _extended ? 'Collapse menu' : 'Expand menu',
              icon: Icon(
                _extended ? Icons.menu_open_rounded : Icons.menu_rounded,
              ),
              onPressed: () => setState(() => _extended = !_extended),
            ),
            destinations: _railDestinations,
          ),
          const VerticalDivider(width: 1, thickness: 1),

          // ── Main content ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
                const Divider(height: 1),

                // Menu grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = switch (width) {
                        < 600  => 1,
                        < 1100 => 2,
                        _      => 3,
                      };
                      const hSpacing = 12.0;
                      const hPadding = 32.0;
                      final cardWidth =
                          (width - hPadding - (columns - 1) * hSpacing) /
                              columns;
                      final cardHeight = cardWidth * 3 / 4 + 160;
                      return GridView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: hSpacing,
                          mainAxisSpacing: 12,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) => _MenuItemCard(
                          item: _filtered[i],
                          onTap: () => _openDetail(_filtered[i]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: ListenableBuilder(
        listenable: widget.cart,
        builder: (context, _) {
          if (widget.cart.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              HapticService.tap();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CartScreen(cart: widget.cart)),
              );
            },
            icon: Badge(
              label: Text('${widget.cart.itemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: Row(
              children: [
                const Text('Go to Cart',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${widget.cart.total.round()}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.onTap});

  final MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: item.imagePath.isNotEmpty
                  ? Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: item.color.withAlpha(50),
                        child: Center(
                            child: Icon(item.icon,
                                size: 64, color: item.color)),
                      ),
                    )
                  : ColoredBox(
                      color: item.color.withAlpha(50),
                      child: Center(
                          child: Icon(item.icon,
                              size: 64, color: item.color)),
                    ),
            ),
            Expanded(
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: tt.titleSmall?.copyWith(
                            fontSize: 20, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: tt.bodySmall?.copyWith(
                            fontSize: 16, color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${item.price.round()}',
                    style: tt.titleSmall?.copyWith(
                      fontSize: 20,
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 56),
                      iconSize: 22,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 6),
                        Text('Add'),
                      ],
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
