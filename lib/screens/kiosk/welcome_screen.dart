import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import '../../data/coupons.dart';
import '../../models/cart_controller.dart';
import '../../services/haptic_service.dart';
import '../../theme/app_theme.dart';
import 'menu_screen.dart';

typedef MenuScreenBuilder = Widget Function(CartController cart);

extension on OrderType {
  String get label => this == OrderType.dineIn ? 'Start Ordering' : 'Take Away';
  IconData get icon =>
      this == OrderType.dineIn ? Icons.restaurant_rounded : Icons.takeout_dining_rounded;
}

class _OrderTypeButton extends StatelessWidget {
  const _OrderTypeButton({required this.type, this.menuBuilder});

  final OrderType type;
  final MenuScreenBuilder? menuBuilder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        HapticService.tap();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
                final cart = CartController(orderType: type);
                return menuBuilder != null ? menuBuilder!(cart) : MenuScreen(cart: cart);
              },
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

class _VideoPlayer extends StatefulWidget {
  const _VideoPlayer();

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset(
      'Video/chef-prepares-noodles-with-meat-and-vegetables-2025-12-17-14-28-45-utc.mp4',
    );
    await _controller.initialize();
    await _controller.setVolume(0);
    await _controller.setLooping(true);
    if (mounted) {
      setState(() => _initialized = true);
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox.expand(
        child: _initialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : Container(color: Colors.black38),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coupon.shortLabel,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            coupon.title,
            style: tt.bodySmall?.copyWith(color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              coupon.code,
              style: tt.labelSmall?.copyWith(
                color: Colors.white60,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, this.menuBuilder});

  final MenuScreenBuilder? menuBuilder;

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
              // Video with logo overlaid on top
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: Stack(
                    children: [
                      const _VideoPlayer(),
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SvgPicture.asset(
                            'images/Logo/Group 1.svg',
                            height: 56,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Start Ordering button — outside video
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _OrderTypeButton(type: OrderType.dineIn, menuBuilder: menuBuilder),
                  ),
                ),
              ),

              // Powered by Pine Labs
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by',
                      style: tt.labelSmall?.copyWith(color: Colors.white54),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.asset(
                      'images/logo/pinelabs_logo.svg',
                      height: 16,
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
