import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import 'welcome_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key, required this.cart});

  final CartController cart;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final List<CartItem> _snapshot;
  late final String _orderNumber;

  @override
  void initState() {
    super.initState();
    _snapshot = List.from(widget.cart.items);
    _orderNumber = (1000 + Random().nextInt(8999)).toString();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();

    // Clear cart after snapshot
    widget.cart.clear();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success animation
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 72,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Order Placed!',
                style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order is being prepared',
                style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 32),

              // Order number + ETA
              Row(
                children: [
                  Expanded(
                    child: Card.filled(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.confirmation_number_outlined, size: 32, color: cs.primary),
                            const SizedBox(height: 8),
                            Text('Order No.', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                            Text(
                              '#$_orderNumber',
                              style: tt.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card.filled(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.schedule_rounded, size: 32, color: cs.tertiary),
                            const SizedBox(height: 8),
                            Text('Est. Time', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                            Text(
                              '10–15 min',
                              style: tt.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Items summary
              Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Summary', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ..._snapshot.map(
                        (ci) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: ci.item.color.withAlpha(50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(ci.item.icon, size: 14, color: ci.item.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${ci.quantity}×  ${ci.item.name}${ci.size != null ? ' (${ci.size})' : ''}',
                                  style: tt.bodyMedium,
                                ),
                              ),
                              Text(
                                '₹${ci.subtotal.round()}',
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // New order button
              OutlinedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Start New Order'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
