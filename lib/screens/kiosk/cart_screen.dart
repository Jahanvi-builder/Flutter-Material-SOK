import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import '../../services/sound_service.dart';
import 'confirmation_screen.dart';
import 'qr_payment_screen.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.cart});

  final CartController cart;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _methods = [
    (icon: Icons.qr_code_scanner_rounded, label: 'Pay with UPI',         isQr: true),
    (icon: Icons.contactless_rounded,     label: 'Tap to Pay',          isQr: false),
    (icon: Icons.credit_card_rounded,     label: 'Credit / Debit Card', isQr: false),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
        actions: [
          if (!widget.cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: const Text('Clear Cart'),
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.cart,
        builder: (context, _) {
          if (widget.cart.isEmpty) {
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
                    style: FilledButton.styleFrom(
                      fixedSize: const Size(200, 56),
                      iconSize: 22,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    child: const Text('Browse Menu'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  // Items list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, i) => _CartItemTile(
                      cartItem: widget.cart.items[i],
                      cart: widget.cart,
                    ),
                  ),

                  // Order summary + payment
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Divider(color: cs.outlineVariant.withAlpha(120)),
                                ),
                                _SummaryRow('Subtotal', '₹${widget.cart.subtotal.round()}', tt),
                                if (widget.cart.discount > 0) ...[
                                  const SizedBox(height: 6),
                                  _SummaryRow(
                                    'Discount',
                                    '−₹${widget.cart.discount.round()}',
                                    tt,
                                    color: Colors.green.shade600,
                                  ),
                                ],
                                const SizedBox(height: 6),
                                _SummaryRow('GST (5%)', '₹${widget.cart.tax.round()}', tt),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(color: cs.outlineVariant.withAlpha(120)),
                                ),
                                _SummaryRow(
                                  'Total',
                                  '₹${widget.cart.total.round()}',
                                  tt,
                                  bold: true,
                                  color: cs.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Payment buttons — UPI full-width, card methods side by side
                          _PaymentButton(method: _methods[0], cart: widget.cart),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _PaymentButton(method: _methods[1], cart: widget.cart)),
                              const SizedBox(width: 10),
                              Expanded(child: _PaymentButton(method: _methods[2], cart: widget.cart)),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
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
              widget.cart.clear();
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

    return Card.filled(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Dish thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: item.imagePath.isNotEmpty
                    ? Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: item.color.withAlpha(50),
                          child: Icon(item.icon, color: item.color, size: 28),
                        ),
                      )
                    : ColoredBox(
                        color: item.color.withAlpha(50),
                        child: Icon(item.icon, color: item.color, size: 28),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + customizations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
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
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () { SoundService.playTap(); cart.decrement(cartItem); },
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
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
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () { SoundService.playTap(); cart.increment(cartItem); },
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                    minimumSize: const Size(32, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Subtotal
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.originalPrice != null)
                    Text(
                      '₹${(item.originalPrice! * cartItem.quantity).round()}',
                      textAlign: TextAlign.right,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant.withAlpha(120),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: cs.onSurfaceVariant.withAlpha(120),
                      ),
                    ),
                  Text(
                    '₹${cartItem.subtotal.round()}',
                    textAlign: TextAlign.right,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w500),
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
      fontWeight: bold ? FontWeight.w500 : null,
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

class _PaymentButton extends StatelessWidget {
  const _PaymentButton({required this.method, required this.cart});

  final ({IconData icon, String label, bool isQr}) method;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {
        SoundService.playTap();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => method.isQr
                ? QrPaymentScreen(cart: cart)
                : ConfirmationScreen(cart: cart, paymentMethod: method.label),
          ),
        );
      },
      icon: Icon(method.icon, size: 24),
      label: Row(
        children: [
          Expanded(child: Text(method.label)),
          Icon(Icons.chevron_right_rounded, size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
      ),
    );
  }
}
