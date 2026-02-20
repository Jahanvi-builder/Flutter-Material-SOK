import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'screens/kiosk/welcome_screen.dart';
import 'screens/m3_showcase_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SokApp());
}

class SokApp extends StatelessWidget {
  const SokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Tasty Bites',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(dynamicScheme: lightDynamic),
          darkTheme: AppTheme.dark(dynamicScheme: darkDynamic),
          themeMode: ThemeMode.system,
          home: const WelcomeScreen(),
          routes: {
            '/m3': (_) => const M3ShowcaseScreen(),
          },
        );
      },
    );
  }
}
