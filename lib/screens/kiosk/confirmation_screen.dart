import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../models/cart_controller.dart';
import '../../models/cart_item.dart';
import 'welcome_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.cart,
    this.paymentMethod = 'Paid',
  });

  final CartController cart;
  final String paymentMethod;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _tickAnim;
  late final String _orderNumber;
  late final String _dateTime;
  late final List<CartItem> _snapshot;
  late final double _subtotal;
  late final double _discount;
  late final double _tax;
  late final double _total;
  late final String _orderType;
  late final ConfettiController _confettiLeft;
  late final ConfettiController _confettiRight;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    _dateTime = '${now.day} ${months[now.month - 1]} ${now.year}  ·  $h:$m $ampm';

    _orderNumber = (1000 + Random().nextInt(8999)).toString();
    _snapshot = List.from(widget.cart.items);
    _subtotal = widget.cart.subtotal;
    _discount = widget.cart.discount;
    _tax = widget.cart.tax;
    _total = widget.cart.total;
    _orderType = widget.cart.orderType == OrderType.dineIn ? 'Dine In' : 'Take Away';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _tickAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );
    _animController.forward();

    _confettiLeft = ConfettiController(duration: const Duration(seconds: 3));
    _confettiRight = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.cart.clear();
      if (mounted) {
        _confettiLeft.play();
        _confettiRight.play();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _confettiLeft.dispose();
    _confettiRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Order placed ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 480, 24, 64),
                    child: Column(
                      children: [
                        ClipRect(
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedBuilder(
                                animation: _tickAnim,
                                builder: (context, _) => CustomPaint(
                                  size: const Size(120, 120),
                                  painter: _CheckPainter(
                                    progress: _tickAnim.value,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Order Placed!',
                          style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your order is being prepared · 10–15 min',
                          style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                (route) => false,
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('New Order'),
                              style: FilledButton.styleFrom(
                                fixedSize: const Size(164, 52),
                                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.tonal(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                (route) => false,
                              ),
                              style: FilledButton.styleFrom(
                                fixedSize: const Size(164, 52),
                                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              child: const Text('End Session'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Receipt ───────────────────────────────────────────────
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: _ReceiptCard(
                        orderNumber: _orderNumber,
                        dateTime: _dateTime,
                        orderType: _orderType,
                        items: _snapshot,
                        subtotal: _subtotal,
                        discount: _discount,
                        tax: _tax,
                        total: _total,
                        paymentMethod: widget.paymentMethod,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti — left
          Positioned(
            top: 0,
            left: 0,
            child: ConfettiWidget(
              confettiController: _confettiLeft,
              blastDirection: -pi / 6,
              emissionFrequency: 0.03,
              numberOfParticles: 40,
              maxBlastForce: 50,
              minBlastForce: 25,
              gravity: 0.2,
              colors: [
                cs.primary, cs.secondary, cs.tertiary,
                cs.primaryContainer, cs.secondaryContainer,
              ],
            ),
          ),
          // Confetti — right
          Positioned(
            top: 0,
            right: 0,
            child: ConfettiWidget(
              confettiController: _confettiRight,
              blastDirection: pi + pi / 6,
              emissionFrequency: 0.03,
              numberOfParticles: 40,
              maxBlastForce: 50,
              minBlastForce: 25,
              gravity: 0.2,
              colors: [
                cs.primary, cs.secondary, cs.tertiary,
                cs.primaryContainer, cs.secondaryContainer,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Receipt card ────────────────────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.orderNumber,
    required this.dateTime,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
  });

  final String orderNumber;
  final String dateTime;
  final String orderType;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final muted = tt.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final dash = _DashedDivider(color: cs.outlineVariant.withAlpha(140));

    return ClipPath(
      clipper: const _ReceiptClipper(toothWidth: 10.0, toothHeight: 6.0),
      child: Container(
        color: cs.surfaceContainerLow,
        child: Column(
        children: [

          // ── Restaurant header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                Text(
                  'TASTY BITES',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text('Food Court · Pine Labs Plaza, Sector 5', style: muted, textAlign: TextAlign.center),
                Text('GSTIN: 27AABCT1332L1ZK', style: muted),
              ],
            ),
          ),
          dash,

          // ── Order meta ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #$orderNumber',
                          style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(orderType, style: muted),
                      const SizedBox(height: 2),
                      Text(
                        '$paymentMethod · tastybites@pinelabs',
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(dateTime, style: muted, textAlign: TextAlign.right),
              ],
            ),
          ),
          dash,

          // ── Items ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                // Column header
                Row(
                  children: [
                    Expanded(child: Text('ITEM', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8))),
                    SizedBox(width: 36, child: Text('QTY', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8), textAlign: TextAlign.center)),
                    SizedBox(width: 72, child: Text('AMOUNT', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8), textAlign: TextAlign.right)),
                  ],
                ),
                const SizedBox(height: 8),
                ...items.map((ci) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(ci.item.name, style: tt.bodyMedium),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text('${ci.quantity}', style: tt.bodyMedium, textAlign: TextAlign.center),
                          ),
                          SizedBox(
                            width: 72,
                            child: Text('₹${ci.subtotal.round()}',
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      if (ci.size != null || ci.addOns.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            [if (ci.size != null) ci.size!, ...ci.addOns].join(' · '),
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          dash,

          // ── Subtotals ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                _ReceiptRow('Subtotal', '₹${subtotal.round()}', tt),
                if (discount > 0) ...[
                  const SizedBox(height: 4),
                  _ReceiptRow('Discount', '−₹${discount.round()}', tt, color: Colors.green.shade600),
                ],
                const SizedBox(height: 4),
                _ReceiptRow('GST (5%)', '₹${tax.round()}', tt),
              ],
            ),
          ),

          // Solid divider before total
          Divider(height: 1, thickness: 1, color: cs.outlineVariant.withAlpha(160)),

          // ── Total ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                Text('₹${total.round()}', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
              ],
            ),
          ),

        ],
      ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, this.tt, {this.color});
  final String label;
  final String value;
  final TextTheme tt;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = tt.bodyMedium?.copyWith(color: color);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

// ── Receipt sawtooth clipper ──────────────────────────────────────────────────

class _ReceiptClipper extends CustomClipper<Path> {
  const _ReceiptClipper({this.toothWidth = 10.0, this.toothHeight = 6.0});

  final double toothWidth;
  final double toothHeight;

  @override
  Path getClip(Size size) {
    final n = (size.width / toothWidth).floor();
    final w = size.width / n;
    final h = toothHeight;
    final path = Path();

    // Top edge — teeth point upward (into the page above)
    path.moveTo(0, h);
    for (int i = 0; i < n; i++) {
      path.lineTo(i * w + w / 2, 0);
      path.lineTo((i + 1) * w, h);
    }
    // Right side
    path.lineTo(size.width, size.height - h);
    // Bottom edge — teeth point downward (into the page below), going left
    for (int i = n; i > 0; i--) {
      path.lineTo(i * w - w / 2, size.height);
      path.lineTo((i - 1) * w, size.height - h);
    }
    // Left side
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ReceiptClipper old) =>
      old.toothWidth != toothWidth || old.toothHeight != toothHeight;
}

// ── Dashed divider ────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, 1),
        painter: _DashPainter(
          color: color ?? Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 5, 0), paint);
      x += 9;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

// ── Animated checkmark painter ────────────────────────────────────────────────

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.048
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.30, size.height * 0.52)
      ..lineTo(size.width * 0.45, size.height * 0.66)
      ..lineTo(size.width * 0.70, size.height * 0.36);

    final metrics = path.computeMetrics().toList();
    final total = metrics.fold(0.0, (s, m) => s + m.length);
    double remaining = total * progress;

    for (final metric in metrics) {
      if (remaining <= 0) break;
      canvas.drawPath(
        metric.extractPath(0, remaining.clamp(0.0, metric.length)),
        paint,
      );
      remaining -= metric.length;
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color;
}
