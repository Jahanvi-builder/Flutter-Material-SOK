# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device/simulator
flutter run

# Run on a specific device
flutter run -d <device-id>          # e.g. -d chrome, -d macos
flutter devices                     # list available devices

# Build
flutter build apk                   # Android APK
flutter build ios                   # iOS (requires Xcode)
flutter build web                   # Web

# Test
flutter test                        # run all tests
flutter test test/widget_test.dart  # run a single test file

# Code quality
flutter analyze                     # static analysis (lint + type check)
flutter pub get                     # fetch dependencies
flutter pub upgrade                 # upgrade dependencies
```

Hot reload: press `r` in the terminal while `flutter run` is active. Hot restart: `R`.

## Architecture

Single-package Flutter app targeting Android, iOS, and web.

```
lib/
  main.dart           # Entry point — SokApp widget with DynamicColorBuilder
  theme/
    app_theme.dart    # ThemeData factory (AppTheme.light / AppTheme.dark)
  screens/
    home_screen.dart  # Home screen widget
test/
  widget_test.dart    # Widget tests
```

## Material 3 Expressive Setup

The app uses **Material 3** (`useMaterial3: true`) with:

- **Dynamic color** (`dynamic_color` package): on Android 12+, the `ColorScheme` adapts to the user's wallpaper. `DynamicColorBuilder` in `main.dart` passes the dynamic schemes down; `AppTheme.light/dark` falls back to `_seedColor` when dynamic color is unavailable.
- **Google Fonts** (`google_fonts` package): Inter is the default typeface, applied via `GoogleFonts.interTextTheme()` in `app_theme.dart`.
- **Seed color**: `Color(0xFF6750A4)` (M3 default purple). Change `_seedColor` in `app_theme.dart` to retheme the entire app.
- **Page transitions**: `PredictiveBackPageTransitionsBuilder` on Android (M3 Expressive predictive back gesture), `CupertinoPageTransitionsBuilder` on iOS.

## Theme Conventions

- Always read colors from `Theme.of(context).colorScheme` — never hard-code colors.
- Use `theme.textTheme.*` for typography rather than explicit `TextStyle`.
- Prefer `surfaceContainerHighest` / `surfaceContainerLow` over deprecated `background` / `surface` variants.
- Light and dark themes are handled automatically via `ThemeMode.system`; do not add manual theme-switching logic unless explicitly requested.

## Key Dependencies

| Package | Purpose |
|---|---|
| `dynamic_color` | Android wallpaper-based `ColorScheme` |
| `google_fonts` | Inter typeface (and any future font swaps) |
| `flutter_lints` | Lint rules (`analysis_options.yaml`) |
