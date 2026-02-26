import 'package:flutter/material.dart';

import '../../data/mock_menu.dart';
import '../../models/cart_controller.dart';
import '../../models/menu_item.dart';
import '../../services/sound_service.dart';
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
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _searchVisible = false;
  final _searchController = TextEditingController();
  String? _phoneNumber;

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
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        actions: [
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Column(
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
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  showCheckmark: false,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                );
              },
            ),
          ),

          // Collapsible search bar
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _searchVisible
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
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
                  )
                : const SizedBox.shrink(),
          ),

          const Divider(height: 1),

          // Responsive menu grid
          Expanded(
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
          ),
        ],
      ),

      floatingActionButton: ListenableBuilder(
        listenable: widget.cart,
        builder: (context, _) {
          final searchFab = FloatingActionButton(
            heroTag: 'search_fab',
            onPressed: () {
              SoundService.playTap();
              setState(() {
                _searchVisible = !_searchVisible;
                if (!_searchVisible) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            child: Icon(
              _searchVisible ? Icons.search_off_rounded : Icons.search_rounded,
            ),
          );

          if (widget.cart.isEmpty) return searchFab;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                heroTag: 'cart_fab',
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              searchFab,
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
                                  SoundService.playTap();
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
                                      onPressed: () { SoundService.playTap(); cart.decrement(cartItem!); },
                                    ),
                                    Text('$count', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      constraints: const BoxConstraints.tightFor(width: 56, height: 56),
                                      onPressed: () { SoundService.playTap(); cart.increment(cartItem!); },
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
