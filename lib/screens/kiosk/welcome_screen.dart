import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/cart_controller.dart';
import '../../theme/app_theme.dart';
import '../../services/sound_service.dart';
import 'menu_screen.dart';

extension on OrderType {
  String get label => this == OrderType.dineIn ? 'Start Ordering' : 'Take Away';
  IconData get icon =>
      this == OrderType.dineIn ? Icons.restaurant_rounded : Icons.takeout_dining_rounded;
}

class _OrderTypeButton extends StatelessWidget {
  const _OrderTypeButton({required this.type});

  final OrderType type;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        SoundService.playTap();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuScreen(cart: CartController(orderType: type)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, size: 28, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type.label,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    type == OrderType.dineIn
                        ? 'Order and enjoy at your table'
                        : 'We\'ll pack it up for you',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios_rounded, size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/splash/c3354750dda02d843caa03b6c1320687.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: AppTheme.brandGreen.withAlpha(210)),
          SafeArea(
          child: Column(
            children: [
              // Top branding area
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppTheme.brandMint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        size: 64,
                        color: AppTheme.brandGreen,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Tasty Bites',
                      style: tt.displaySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fresh • Fast • Delicious',
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Call to action
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tap below to start your order',
                      style: tt.titleLarge?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 580),
                          child: const Column(
                            children: [
                              _OrderTypeButton(type: OrderType.dineIn),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer — Powered by Pine Labs
              Padding(
                padding: const EdgeInsets.only(bottom: 52),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Powered by',
                      style: tt.labelMedium?.copyWith(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    SvgPicture.asset(
                      'images/logo/pinelabs_logo.svg',
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
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
