import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Pine Labs brand colors — use these in any screen that renders on the branded dark background
  static const brandGreen = Color(0xFF003323);
  static const brandMint  = Color(0xFF50D387);

  static const _pinelabsGreen = brandGreen;
  static const _pinelabsMint  = brandMint;

  static ThemeData light({ColorScheme? dynamicScheme}) {
    final scheme = dynamicScheme ?? _lightScheme;
    return _base(scheme);
  }

  static ThemeData dark({ColorScheme? dynamicScheme}) {
    final scheme = dynamicScheme ?? _darkScheme;
    return _base(scheme);
  }

  static final _lightScheme = ColorScheme.fromSeed(
    seedColor: _pinelabsGreen,
    brightness: Brightness.light,
  ).copyWith(
    primary: _pinelabsGreen,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF8FF5C0),
    onPrimaryContainer: const Color(0xFF00200F),
    secondary: _pinelabsMint,
    onSecondary: const Color(0xFF003822),
    secondaryContainer: const Color(0xFFB7F5D5),
    onSecondaryContainer: const Color(0xFF00391F),
    tertiary: const Color(0xFF006B42),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFF8DF5BE),
    onTertiaryContainer: const Color(0xFF002112),
  );

  static final _darkScheme = ColorScheme.fromSeed(
    seedColor: _pinelabsGreen,
    brightness: Brightness.dark,
  ).copyWith(
    primary: _pinelabsMint,
    onPrimary: const Color(0xFF003822),
    primaryContainer: _pinelabsGreen,
    onPrimaryContainer: const Color(0xFF8FF5C0),
    secondary: const Color(0xFF6DD9A0),
    onSecondary: const Color(0xFF003820),
    secondaryContainer: const Color(0xFF00522F),
    onSecondaryContainer: const Color(0xFF8FF5BB),
  );

  static const _rond = [FontVariation('ROND', 100.0)];

  static TextStyle _gs(TextStyle? base) => (base ?? const TextStyle()).copyWith(
    fontFamily: 'GoogleSansFlex',
    fontVariations: _rond,
  );

  static TextTheme _roundedTextTheme(ColorScheme scheme) {
    final base = GoogleFonts.googleSansFlexTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return base.copyWith(
      displayLarge:   _gs(base.displayLarge),
      displayMedium:  _gs(base.displayMedium),
      displaySmall:   _gs(base.displaySmall),
      headlineLarge:  _gs(base.headlineLarge),
      headlineMedium: _gs(base.headlineMedium),
      headlineSmall:  _gs(base.headlineSmall),
      titleLarge:     _gs(base.titleLarge),
      titleMedium:    _gs(base.titleMedium),
      titleSmall:     _gs(base.titleSmall),
      bodyLarge:      _gs(base.bodyLarge),
      bodyMedium:     _gs(base.bodyMedium),
      bodySmall:      _gs(base.bodySmall),
      labelLarge:     _gs(base.labelLarge),
      labelMedium:    _gs(base.labelMedium),
      labelSmall:     _gs(base.labelSmall),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: CardThemeData(
        color: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
      ),
      textTheme: _roundedTextTheme(scheme),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
