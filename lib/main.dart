import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'screens/kiosk/menu_screen_left.dart';
import 'screens/kiosk/welcome_screen.dart';
import 'screens/m3_showcase_screen.dart';
import 'theme/app_theme.dart';

/// Global theme notifier — readable and writable from any screen.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  runApp(const SokApp());
}

class SokApp extends StatelessWidget {
  const SokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp(
              title: 'Tasty Bites',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              home: const WelcomeScreen(),
              routes: {
                '/m3':   (_) => const M3ShowcaseScreen(),
                '/left': (_) => const LeftNavMenuRoute(),
              },
            );
          },
        );
      },
    );
  }
}
