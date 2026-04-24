import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../services/haptic_service.dart';
import 'post_payment_flow.dart';

enum _PaymentMethod { tapToPay, card, qr }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.cart});

  final CartController cart;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod _selected = _PaymentMethod.tapToPay;

  static const _methods = [
    (
      method: _PaymentMethod.tapToPay,
      icon: Icons.contactless_rounded,
      title: 'Tap to Pay',
      subtitle: 'Use your phone, watch, or contactless card',
    ),
    (
      method: _PaymentMethod.card,
      icon: Icons.credit_card_rounded,
      title: 'Credit / Debit Card',
      subtitle: 'Insert or swipe your card',
    ),
    (
      method: _PaymentMethod.qr,
      icon: Icons.qr_code_scanner_rounded,
      title: 'Pay by QR',
      subtitle: 'Scan with your banking app',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order total summary card
              Card.filled(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Total',
                              style: tt.labelLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '₹${widget.cart.total.round()}',
                              style: tt.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.cart.itemCount} item${widget.cart.itemCount == 1 ? '' : 's'}',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'How would you like to pay?',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // Payment method options
              Expanded(
                child: ListView(
                  children: _methods.map((m) {
                    final isSelected = _selected == m.method;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card.outlined(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? cs.primary : cs.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => setState(() => _selected = m.method),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cs.primaryContainer
                                        : cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    m.icon,
                                    size: 28,
                                    color: isSelected
                                        ? cs.onPrimaryContainer
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.title,
                                        style: tt.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? cs.primary : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        m.subtitle,
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: cs.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  HapticService.tap();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => postPaymentDestination(
                        cart: widget.cart,
                        paymentMethod: 'Paid',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_rounded),
                label: Text('Confirm Payment · ₹${widget.cart.total.round()}'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
