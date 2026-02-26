import 'package:flutter/material.dart';

import 'kiosk/welcome_screen.dart';
import 'm3_showcase_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOK Material'),
        backgroundColor: cs.surfaceContainerHighest,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LaunchCard(
              icon: Icons.storefront_rounded,
              color: cs.primaryContainer,
              iconColor: cs.onPrimaryContainer,
              title: 'Self-Order Kiosk',
              description: 'Food ordering kiosk demo — browse menu, customise items, checkout',
              label: 'Launch Kiosk',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _LaunchCard(
              icon: Icons.palette_outlined,
              color: cs.secondaryContainer,
              iconColor: cs.onSecondaryContainer,
              title: 'M3 Showcase',
              description: 'Material 3 Expressive components — buttons, cards, inputs, selection',
              label: 'View Showcase',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const M3ShowcaseScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final String title;
  final String description;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: tt.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
