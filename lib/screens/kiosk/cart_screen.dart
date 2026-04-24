import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/coupons.dart';
import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import '../../services/haptic_service.dart';
import 'item_detail_sheet.dart';
import 'post_payment_flow.dart';
import 'qr_payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.cart});

  final CartController cart;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _methods = [
    (icon: Icons.qr_code_scanner_rounded, label: 'Pay with UPI', isQr: true),
    (icon: Icons.contactless_rounded, label: 'Tap to Pay', isQr: false),
    (
      icon: Icons.credit_card_rounded,
      label: 'Credit / Debit Card',
      isQr: false,
    ),
  ];

  CartController get cart => widget.cart;

  @override
  void initState() {
    super.initState();
    cart.applyCoupon(preAppliedCoupon);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: const Text('Clear Cart'),
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
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: cs.outline,
                  ),
                  const SizedBox(height: 16),
                  Text('Your order is empty', style: tt.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Add items from the menu',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      fixedSize: const Size(200, 56),
                      iconSize: 22,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, i) =>
                          _CartItemTile(cartItem: cart.items[i], cart: cart),
                    ),

                    // Coupon section
                    _CouponSection(cart: cart),

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
                                    child: Divider(
                                      color: cs.outlineVariant.withAlpha(120),
                                    ),
                                  ),
                                  _SummaryRow(
                                    'Subtotal',
                                    '₹${cart.subtotal.round()}',
                                    tt,
                                  ),
                                  if (cart.discount > 0) ...[
                                    const SizedBox(height: 6),
                                    _SummaryRow(
                                      'Item savings',
                                      '−₹${cart.discount.round()}',
                                      tt,
                                      color: Colors.green.shade600,
                                    ),
                                  ],
                                  if (cart.couponDiscount > 0) ...[
                                    const SizedBox(height: 6),
                                    _SummaryRow(
                                      'Coupon (${cart.appliedCoupon!.code})',
                                      '−₹${cart.couponDiscount.round()}',
                                      tt,
                                      color: Colors.green.shade600,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  _SummaryRow(
                                    'GST (5%)',
                                    '₹${cart.tax.round()}',
                                    tt,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Divider(
                                      color: cs.outlineVariant.withAlpha(120),
                                    ),
                                  ),
                                  _SummaryRow(
                                    'Total',
                                    '₹${cart.total.round()}',
                                    tt,
                                    bold: true,
                                    color: cs.primary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Payment buttons — UPI full-width, card methods side by side
                            _PaymentButton(method: _methods[0], cart: cart),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _PaymentButton(
                                    method: _methods[1],
                                    cart: cart,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _PaymentButton(
                                    method: _methods[2],
                                    cart: cart,
                                  ),
                                ),
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
                  Text(
                    item.name,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (cartItem.hasCustomizations)
                    Text(
                      cartItem.customizationSummary.join(' · '),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  if (item.isCustomizable)
                    TextButton(
                      onPressed: () {
                        HapticService.tap();
                        showItemDetail(
                          context,
                          item,
                          cart,
                          editingCartItem: cartItem,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Text('Edit'),
                    ),
                ],
              ),
            ),

            // Quantity controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () {
                    HapticService.tap();
                    cart.decrement(cartItem);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
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
                  onPressed: () {
                    HapticService.tap();
                    cart.increment(cartItem);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
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
  const _SummaryRow(
    this.label,
    this.value,
    this.tt, {
    this.bold = false,
    this.color,
  });

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

// ─── Coupon section ──────────────────────────────────────────────────────────

class _CouponSection extends StatelessWidget {
  const _CouponSection({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final applied = cart.appliedCoupon;
    final savings = cart.couponDiscount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Coupons & Offers',
                style: tt.labelLarge?.copyWith(color: cs.onSurface),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  HapticService.tap();
                  _showCouponsSheet(context, cart);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (applied != null)
            _AppliedCouponChip(coupon: applied, savings: savings, cart: cart)
          else
            _AddCouponRow(cart: cart),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AppliedCouponChip extends StatelessWidget {
  const _AppliedCouponChip({
    required this.coupon,
    required this.savings,
    required this.cart,
  });

  final Coupon coupon;
  final double savings;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.primary.withAlpha(50)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CookieBadge(
                  size: 24,
                  color: cs.primary,
                  child: Icon(
                    Icons.percent_rounded,
                    color: cs.primaryContainer,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    coupon.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    HapticService.tap();
                    cart.removeCoupon();
                  },
                  style: IconButton.styleFrom(
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                'Save ₹${savings.round()} with this code',
                style: tt.bodyMedium?.copyWith(color: cs.primary),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: CustomPaint(
                painter: _DashedRoundedBorder(color: cs.primary, radius: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.content_cut_rounded,
                        size: 14,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        coupon.code,
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCouponRow extends StatelessWidget {
  const _AddCouponRow({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.outlineVariant.withAlpha(160)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticService.tap();
          _showCouponsSheet(context, cart);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              _CookieBadge(
                size: 24,
                color: cs.surfaceContainerHigh,
                child: Icon(
                  Icons.percent_rounded,
                  color: cs.onSurfaceVariant,
                  size: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Apply a coupon',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showCouponsSheet(BuildContext context, CartController cart) {
  HapticService.tap();
  final isWide = MediaQuery.sizeOf(context).width >= 680;
  if (isWide) {
    showDialog(
      context: context,
      builder: (_) => _CouponsDialog(cart: cart),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CouponsSheet(cart: cart),
    );
  }
}

// ── Shared coupon list ────────────────────────────────────────────────────────

Widget _couponsHeader(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  return Row(
    children: [
      Icon(Icons.local_offer_rounded, color: cs.primary, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Available Offers',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          minimumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    ],
  );
}

Widget _couponsList(CartController cart, {ScrollController? controller}) {
  return ListView.separated(
    controller: controller,
    shrinkWrap: controller == null,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
    itemCount: availableCoupons.length,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (context, i) =>
        _CouponCard(coupon: availableCoupons[i], cart: cart),
  );
}

// ── Dialog (wide screens ≥ 680) ───────────────────────────────────────────────

class _CouponsDialog extends StatelessWidget {
  const _CouponsDialog({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                child: _couponsHeader(context),
              ),
              Divider(height: 1, color: cs.outlineVariant.withAlpha(120)),
              const SizedBox(height: 12),
              Flexible(child: _couponsList(cart)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet (narrow screens) ─────────────────────────────────────────────

class _CouponsSheet extends StatelessWidget {
  const _CouponsSheet({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scroll) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: _couponsHeader(context),
            ),
            Divider(height: 1, color: cs.outlineVariant.withAlpha(120)),
            const SizedBox(height: 12),
            Expanded(child: _couponsList(cart, controller: scroll)),
          ],
        ),
      ),
    );
  }
}

// ── Coupon card ───────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.cart});

  final Coupon coupon;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isApplied = cart.appliedCoupon?.code == coupon.code;
    final eligible = cart.subtotal >= coupon.minOrder;
    final savings = coupon.savings(cart.subtotal);

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isApplied
              ? cs.primary.withAlpha(50)
              : cs.outlineVariant.withAlpha(160),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Top body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge + title + button row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _CookieBadge(
                      size: 24,
                      color: eligible ? cs.primary : cs.surfaceContainerHigh,
                      child: Icon(
                        Icons.percent_rounded,
                        color: eligible
                            ? cs.primaryContainer
                            : cs.onSurfaceVariant,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        coupon.title,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isApplied)
                      FilledButton.tonal(
                        onPressed: () {
                          HapticService.tap();
                          cart.removeCoupon();
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(88, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Remove'),
                      )
                    else
                      FilledButton.tonal(
                        onPressed: eligible
                            ? () {
                                HapticService.tap();
                                cart.applyCoupon(coupon);
                                Navigator.pop(context);
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(88, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: eligible && savings > 0
                      ? Text(
                          'Save ₹${savings.round()} with this code',
                          style: tt.bodyMedium?.copyWith(color: cs.primary),
                        )
                      : Text(
                          'Min order ₹${coupon.minOrder.round()} required',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                ),

                const SizedBox(height: 14),

                // Code pill + View Details toggle
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Row(
                    children: [
                      CustomPaint(
                        painter: _DashedRoundedBorder(
                          color: eligible ? cs.primary : cs.outlineVariant,
                          radius: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.content_cut_rounded,
                                size: 14,
                                color: eligible
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                coupon.code,
                                style: tt.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: eligible
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dashed rounded border painter ───────────────────────────────────────────

class _DashedRoundedBorder extends CustomPainter {
  const _DashedRoundedBorder({required this.color, this.radius = 8});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(51)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, (d + dash).clamp(0.0, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRoundedBorder old) =>
      old.color != color || old.radius != radius;
}

// ─── Cookie badge shape ───────────────────────────────────────────────────────

class _CookieBadge extends StatelessWidget {
  const _CookieBadge({
    required this.size,
    required this.color,
    required this.child,
  });

  final double size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _CookieClipper(),
      child: Container(
        width: size,
        height: size,
        color: color,
        child: Center(child: child),
      ),
    );
  }
}

class _CookieClipper extends CustomClipper<Path> {
  const _CookieClipper();

  @override
  Path getClip(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    const sides = 12;
    const step = 2 * math.pi / sides;
    const startAngle = -math.pi / 2;
    // How much to pull the mid-edge control point inward (0.82 = fairly concave)
    const concavity = 0.82;

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final a0 = startAngle + i * step;
      final a1 = startAngle + (i + 1) * step;
      final aMid = (a0 + a1) / 2;

      final x0 = cx + r * math.cos(a0);
      final y0 = cy + r * math.sin(a0);
      final x1 = cx + r * math.cos(a1);
      final y1 = cy + r * math.sin(a1);
      final xc = cx + r * concavity * math.cos(aMid);
      final yc = cy + r * concavity * math.sin(aMid);

      if (i == 0) path.moveTo(x0, y0);
      path.quadraticBezierTo(xc, yc, x1, y1);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CookieClipper old) => false;
}

// ─── Payment button ───────────────────────────────────────────────────────────

class _PaymentButton extends StatelessWidget {
  const _PaymentButton({required this.method, required this.cart});

  final ({IconData icon, String label, bool isQr}) method;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {
        HapticService.tap();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => method.isQr
                ? QrPaymentScreen(cart: cart)
                : postPaymentDestination(
                    cart: cart,
                    paymentMethod: method.label,
                  ),
          ),
        );
      },
      icon: Icon(method.icon, size: 24),
      label: Row(
        children: [
          Expanded(child: Text(method.label)),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
