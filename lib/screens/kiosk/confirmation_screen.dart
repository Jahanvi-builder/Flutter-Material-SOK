import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import '../home_screen.dart';
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

    // Clear cart after the first frame — calling clear() synchronously in
    // initState fires notifyListeners() during build, causing a framework error.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.cart.clear());
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

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
                          style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your order is being prepared · 10–15 min',
                          style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),

                        // Order number colored box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Order No. #$_orderNumber',
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Items summary
                        Card.outlined(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order Summary', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                                const SizedBox(height: 16),
                                ..._snapshot.map(
                                  (ci) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: SizedBox(
                                            width: 56,
                                            height: 56,
                                            child: ci.item.imagePath.isNotEmpty
                                                ? Image.asset(
                                                    ci.item.imagePath,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) => ColoredBox(
                                                      color: ci.item.color.withAlpha(50),
                                                      child: Icon(ci.item.icon, size: 24, color: ci.item.color),
                                                    ),
                                                  )
                                                : ColoredBox(
                                                    color: ci.item.color.withAlpha(50),
                                                    child: Icon(ci.item.icon, size: 24, color: ci.item.color),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            '${ci.item.name}${ci.size != null ? ' (${ci.size})' : ''}',
                                            style: tt.bodyLarge,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 36,
                                          child: Text(
                                            '${ci.quantity}×',
                                            textAlign: TextAlign.end,
                                            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            '₹${ci.subtotal.round()}',
                                            textAlign: TextAlign.end,
                                            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Pinned button pair at bottom
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('New Order'),
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size.fromHeight(56),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonal(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        ),
                        style: FilledButton.styleFrom(
                          fixedSize: const Size.fromHeight(56),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        child: const Text('Go to Home'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
