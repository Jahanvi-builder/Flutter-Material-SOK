import 'package:flutter/material.dart';

import '../../data/mock_menu.dart';
import '../../models/cart_controller.dart';
import '../../models/menu_item.dart';
import '../../services/sound_service.dart';
import 'cart_screen.dart';
import 'item_detail_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.cart, this.phoneNumber});

  final CartController cart;
  final String? phoneNumber;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

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
    SoundService.playTap();
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
        actions: [
          if (widget.phoneNumber != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Tooltip(
                message: '+91 ${widget.phoneNumber}',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Column(
        children: [
          // Category chips + search
          SizedBox(
            height: 72,
            child: Row(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: menuCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = menuCategories[i];
                      final selected = cat == _selectedCategory;
                      return FilterChip(
                        label: Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                        showCheckmark: false,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      );
                    },
                  ),
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
                  child: SizedBox(
                    width: 200,
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
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Responsive menu grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = switch (width) {
                  < 600 => 1,
                  < 1100 => 2,
                  _ => 3,
                };
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 360,
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

      floatingActionButton: ListenableBuilder(
        listenable: widget.cart,
        builder: (context, _) {
          if (widget.cart.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              SoundService.playTap();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen(cart: widget.cart)),
              );
            },
            icon: Badge(
              label: Text('${widget.cart.itemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: Row(
              children: [
                const Text(
                  'Go to Cart',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${widget.cart.total.round()}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
            // Placeholder image — fixed height
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ColoredBox(
                color: item.color.withAlpha(50),
                child: Icon(item.icon, size: 64, color: item.color),
              ),
            ),

            // Text block — Expanded so it fills remaining space and
            // pushes the button to the bottom; maxLines keeps it fixed visually
            Expanded(
              child: ClipRect(
                child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: tt.titleSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: tt.bodySmall?.copyWith(fontSize: 16, color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ),
            ),

            // Price + add button — always at bottom
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 56),
                      iconSize: 22,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
