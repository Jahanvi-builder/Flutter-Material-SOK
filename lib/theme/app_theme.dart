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

  static const _rond = [FontVariation('ROND', 100)];

  static TextTheme _roundedTextTheme(ColorScheme scheme) {
    final base = GoogleFonts.googleSansFlexTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return base.copyWith(
      displayLarge:   base.displayLarge?.copyWith(fontVariations: _rond),
      displayMedium:  base.displayMedium?.copyWith(fontVariations: _rond),
      displaySmall:   base.displaySmall?.copyWith(fontVariations: _rond),
      headlineLarge:  base.headlineLarge?.copyWith(fontVariations: _rond),
      headlineMedium: base.headlineMedium?.copyWith(fontVariations: _rond),
      headlineSmall:  base.headlineSmall?.copyWith(fontVariations: _rond),
      titleLarge:     base.titleLarge?.copyWith(fontVariations: _rond),
      titleMedium:    base.titleMedium?.copyWith(fontVariations: _rond),
      titleSmall:     base.titleSmall?.copyWith(fontVariations: _rond),
      bodyLarge:      base.bodyLarge?.copyWith(fontVariations: _rond),
      bodyMedium:     base.bodyMedium?.copyWith(fontVariations: _rond),
      bodySmall:      base.bodySmall?.copyWith(fontVariations: _rond),
      labelLarge:     base.labelLarge?.copyWith(fontVariations: _rond),
      labelMedium:    base.labelMedium?.copyWith(fontVariations: _rond),
      labelSmall:     base.labelSmall?.copyWith(fontVariations: _rond),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          side: BorderSide(color: scheme.outlineVariant),
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
