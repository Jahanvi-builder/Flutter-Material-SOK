import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import '../../services/sound_service.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
        actions: [
          ListenableBuilder(
            listenable: cart,
            builder: (_, _) => cart.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => _confirmClear(context),
                    child: const Text('Clear all'),
                  ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: cs.outline),
                  const SizedBox(height: 16),
                  Text('Your order is empty', style: tt.titleLarge),
                  const SizedBox(height: 8),
                  Text('Add items from the menu', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Menu'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Items list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _CartItemTile(
                    cartItem: cart.items[i],
                    cart: cart,
                  ),
                ),
              ),

              // Order summary
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  border: Border(top: BorderSide(color: cs.outlineVariant)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _SummaryRow('Subtotal', '₹${cart.subtotal.round()}', tt),
                      const SizedBox(height: 6),
                      _SummaryRow('GST (5%)', '₹${cart.tax.round()}', tt),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        'Total',
                        '₹${cart.total.round()}',
                        tt,
                        bold: true,
                        color: cs.primary,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () {
                          SoundService.playTap();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(cart: cart),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Proceed to Payment'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Clear order?'),
        content: const Text('All items will be removed from your order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to menu
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.cartItem, required this.cart});

  final CartItem cartItem;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final item = cartItem.item;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Placeholder thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.color.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(width: 12),

            // Name + customizations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  if (cartItem.size != null)
                    Text(cartItem.size!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  if (cartItem.addOns.isNotEmpty)
                    Text(
                      '+ ${cartItem.addOns.join(', ')}',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),

            // Quantity controls
            Row(
              children: [
                IconButton.outlined(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () { SoundService.playTap(); cart.decrement(cartItem); },
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${cartItem.quantity}',
                    textAlign: TextAlign.center,
                    style: tt.titleSmall,
                  ),
                ),
                IconButton.filled(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () { SoundService.playTap(); cart.increment(cartItem); },
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Subtotal
            SizedBox(
              width: 60,
              child: Text(
                '₹${cartItem.subtotal.round()}',
                textAlign: TextAlign.right,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, this.tt, {this.bold = false, this.color});

  final String label;
  final String value;
  final TextTheme tt;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = (bold ? tt.titleMedium : tt.bodyLarge)?.copyWith(
      fontWeight: bold ? FontWeight.bold : null,
      color: color,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
