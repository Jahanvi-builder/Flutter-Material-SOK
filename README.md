# Tasty Bites — SOK Kiosk

A self-ordering kiosk demo app built with Flutter and **Material 3 Expressive**, powered by Pine Labs.

## Overview

Tasty Bites is a food ordering kiosk experience that demonstrates Material 3 design patterns on Android, iOS, macOS, and web. It walks a customer through the full ordering flow — from welcome to payment confirmation — using rich motion, dynamic color, and expressive typography.

## Screens

| Screen | Description |
|---|---|
| **Welcome** | Order type selection — Dine In or Take Away |
| **Phone** | Customer phone number capture for loyalty/receipts |
| **Menu** | Browsable food menu with category chips, search, and a responsive grid (1–3 columns) |
| **Item Detail** | Bottom sheet with item details and quantity picker |
| **Cart** | Order summary with line items and running total |
| **Payment** | Payment method selection (Pine Labs integration point) |
| **Confirmation** | Order placed confirmation with receipt details |
| **M3 Showcase** | `/m3` route — Material 3 component playground |

## Tech Stack

- **Flutter 3** · Dart SDK `^3.11.0`
- **Material 3** (`useMaterial3: true`) with dynamic color on Android 12+
- **Google Sans Flex** — variable font with `ROND` axis for expressive rounded headings
- **Pine Labs brand palette** — `#003323` forest green / `#50D387` mint

## Key Packages

| Package | Purpose |
|---|---|
| `dynamic_color` | Wallpaper-based `ColorScheme` on Android 12+ |
| `google_fonts` | Google Sans Flex variable typeface |
| `flutter_svg` | Pine Labs logo |
| `audioplayers` | Tap sound feedback |
| `flutter_lints` | Lint rules |

## Project Structure

```
lib/
  main.dart                     # App entry — DynamicColorBuilder + routes
  theme/
    app_theme.dart              # Pine Labs color scheme + Google Sans Flex text theme
  screens/
    home_screen.dart            # Dev home / nav hub
    m3_showcase_screen.dart     # Material 3 component showcase
    kiosk/
      welcome_screen.dart       # Order type selection
      phone_screen.dart         # Phone number entry
      menu_screen.dart          # Menu grid with categories & search
      item_detail_sheet.dart    # Item bottom sheet + quantity picker
      cart_screen.dart          # Cart summary
      payment_screen.dart       # Payment flow
      confirmation_screen.dart  # Order confirmation
  models/
    menu_item.dart              # MenuItem data class
    cart_item.dart              # CartItem data class
    cart_controller.dart        # Cart state (ChangeNotifier)
  data/
    mock_menu.dart              # Seed menu data
  services/
    sound_service.dart          # Tap audio feedback
```

## Getting Started

```bash
flutter pub get
flutter run                   # default device
flutter run -d chrome         # web
flutter run -d macos          # macOS desktop
```

Hot reload: `r` · Hot restart: `R`

## Theme Conventions

- Colors always read from `Theme.of(context).colorScheme` — never hard-coded
- Typography via `theme.textTheme.*`
- Prefer `surfaceContainerHigh` / `surfaceContainerLow` over deprecated surface variants
- Light/dark handled automatically via `ThemeMode.system`

## Build

```bash
flutter build apk       # Android
flutter build ios       # iOS (requires Xcode)
flutter build web       # Web
```

## Deploy to Vercel

This repo is set up to deploy the Flutter web build to Vercel.

1. Run local checks:

   ```bash
   flutter analyze
   flutter test
   flutter build web --release
   ```

2. Import the repo into Vercel.
3. In Vercel project settings, use:

   ```text
   Framework Preset: Other
   Build Command: ./scripts/vercel-build.sh
   Output Directory: build/web
   ```

`vercel.json` already includes the Flutter SPA rewrite to `index.html`. The build script bootstraps Flutter in the Vercel environment if it is not preinstalled, then runs `flutter pub get` and `flutter build web --release`.

After the first deploy, validate that images, SVGs, video, fonts, filters, cart flow, and page refreshes all work on the hosted URL.

## Platform Notes

- **Android** — predictive back gesture (`PredictiveBackPageTransitionsBuilder`) + dynamic color
- **iOS** — Cupertino page transitions
- **macOS / Web** — fade transitions; dynamic color falls back to Pine Labs seed
