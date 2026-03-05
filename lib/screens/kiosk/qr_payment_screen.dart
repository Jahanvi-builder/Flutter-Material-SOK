import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/cart_controller.dart';
import '../../services/haptic_service.dart';
import 'confirmation_screen.dart';

class QrPaymentScreen extends StatefulWidget {
  const QrPaymentScreen({super.key, required this.cart});

  final CartController cart;

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  late final String _qrData;
  late final Timer _expiryTimer;
  late final Timer _paymentTimer; // demo: simulates payment webhook after 10 s
  int _secondsLeft = 300;

  @override
  void initState() {
    super.initState();
    final amount = widget.cart.total.round();
    _qrData =
        'upi://pay?pa=tastybites@pinelabs&pn=Tasty+Bites&am=$amount&cu=INR&tn=KioskOrder';

    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });

    // Auto-navigate when payment is detected (10-second demo simulation)
    _paymentTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        HapticService.paymentSuccess();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmationScreen(cart: widget.cart, paymentMethod: 'UPI'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _expiryTimer.cancel();
    _paymentTimer.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final expired = _secondsLeft == 0;
    final dotColor = cs.primary;
    final qrBg = cs.surfaceContainerLow;

    return Scaffold(
      appBar: AppBar(title: const Text('Pay by QR')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Text(
                  'Scan with any UPI app to pay',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (!expired) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Awaiting payment…',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // QR code — normal rounded rectangle, lighter palette
                AnimatedOpacity(
                  opacity: expired ? 0.3 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      color: qrBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 248,
                          backgroundColor: qrBg,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.circle,
                            color: dotColor,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: dotColor,
                          ),
                        ),
                        // Centre logo — same colour as QR dots
                        Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: qrBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            'images/UPI Logos/Pine.svg',
                            colorFilter:
                                ColorFilter.mode(dotColor, BlendMode.srcIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Amount — no fill, plain text
                Text(
                  '₹${widget.cart.total.round()}',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Timer row / expired state
                if (expired)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Regenerate QR'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: _secondsLeft < 60 ? cs.error : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Expires in $_timerLabel',
                        style: tt.bodySmall?.copyWith(
                          color: _secondsLeft < 60 ? cs.error : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Supported apps
                Text(
                  'Accepted by',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _AppLogo('images/UPI Logos/googlepay-circle.svg', 'GPay'),
                    SizedBox(width: 16),
                    _AppLogo(
                        'images/UPI Logos/phonepe-circle.svg', 'PhonePe'),
                    SizedBox(width: 16),
                    _AppLogo('images/UPI Logos/paytm-circle.svg', 'Paytm'),
                    SizedBox(width: 16),
                    _AppLogo('images/UPI Logos/bhim-circle.svg', 'BHIM'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo(this.assetPath, this.label);
  final String assetPath;
  final String label;

  static String _fix(String svg) =>
      svg.replaceAll(RegExp(r';?fill:color\([^)]+\)'), '');

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString(assetPath),
          builder: (context, snap) => SizedBox(
            width: 40,
            height: 40,
            child: snap.hasData
                ? SvgPicture.string(_fix(snap.data!), width: 40, height: 40)
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
