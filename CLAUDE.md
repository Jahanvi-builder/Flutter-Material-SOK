# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run (preferred targets)
flutter run -d macos --pid-file=/tmp/flutter.pid   # macOS desktop
flutter run -d chrome --pid-file=/tmp/flutter.pid  # Web / Chrome

# Hot reload without a terminal (after flutter run is backgrounded)
# Send SIGUSR1 to the dartvm process — NOT the shell wrapper
kill -SIGUSR1 $(ps aux | grep "flutter_tools.snapshot run" | grep -v grep | awk '{print $2}')

# Auto hot-reload on file save (run in a second terminal)
find lib -name "*.dart" | entr -np kill -SIGUSR1 $(cat /tmp/flutter.pid)

# Build
flutter build apk        # Android
flutter build web        # Web
flutter build macos      # macOS (requires Xcode + CocoaPods)

# Quality
flutter analyze
flutter test
flutter test test/widget_test.dart
flutter pub get
```

**macOS prerequisites**: Xcode must be installed and selected (`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`), license accepted (`sudo xcodebuild -license accept`), and CocoaPods installed (`brew install cocoapods`). Network access requires `com.apple.security.network.client` in both entitlement files.

## App Overview

**Tasty Bites** — a self-ordering kiosk demo for Pine Labs. Full screen flow:

```
WelcomeScreen → PhoneScreen → MenuScreen → CartScreen → PaymentScreen → ConfirmationScreen
```

Routes in `main.dart`: `/` (WelcomeScreen), `/m3` (M3ShowcaseScreen), `/left` (LeftNavMenuRoute — left-nav menu variant).

## Architecture

```
lib/
  main.dart                        # SokApp — DynamicColorBuilder wrapper (dynamic color intentionally bypassed for brand consistency)
  theme/app_theme.dart             # AppTheme.light() / .dark() — Pine Labs brand colors, Google Sans Flex typography
  data/mock_menu.dart              # menuCategories list + menuItems const list (~50 items)
  models/
    menu_item.dart                 # MenuItem (id, name, price, category, isVeg, spiceLevel, imagePath, rating, …)
    cart_item.dart                 # CartItem wrapper (item + quantity + size + addOns), subtotal getter
    cart_controller.dart           # CartController extends ChangeNotifier — add/increment/decrement/clear, tax 5%
  screens/
    kiosk/
      welcome_screen.dart          # Order type picker (OrderType.dineIn / takeAway)
      phone_screen.dart            # Phone number entry, passes number to MenuScreen
      menu_screen.dart             # Horizontal chip filter + animated search bar + responsive grid (1/2/3 col) + FABs
      menu_screen_left.dart        # NavigationRail variant at /#/left (self-contained, owns its CartController)
      item_detail_sheet.dart       # showItemDetail() — Dialog on wide, DraggableScrollableSheet on narrow
      cart_screen.dart             # Line items + quantity stepper + GST summary + checkout
      payment_screen.dart          # Payment method selection
      confirmation_screen.dart     # Order confirmation + receipt
    home_screen.dart               # Dev launcher (Kiosk / M3 Showcase)
    m3_showcase_screen.dart        # Material 3 component playground
  services/sound_service.dart      # SoundService.playTap() — plays sounds/Click 1.mp3 via audioplayers
```

## Theme & Branding

- **Typeface**: Google Sans Flex variable font with `FontVariation('ROND', 100)` on all display/headline/title/body styles for rounded letterforms.
- **Brand colors** (defined in `AppTheme`):
  - `brandGreen` = `#003323` — primary in light theme, used as WelcomeScreen background
  - `brandMint` = `#50D387` — primary in dark theme, secondary accent
- **Dynamic color is intentionally disabled** — `AppTheme.light()` and `.dark()` are called without arguments so the Pine Labs palette is always used regardless of system accent color. Do not pass `dynamicScheme` arguments.
- Always use `Theme.of(context).colorScheme` and `theme.textTheme.*`; never hard-code colors.
- Prefer `surfaceContainerLow` / `surfaceContainerHigh` over deprecated `background`/`surface` variants.

## Key Patterns

**State management**: `CartController extends ChangeNotifier`. Screens wrap rebuild-sensitive widgets in `ListenableBuilder(listenable: cart, …)`. `CartController` is created at the top of each flow and passed down.

**Responsive menu grid**: Uses `LayoutBuilder` to compute `childAspectRatio` dynamically — `cardWidth / (cardWidth * 3/4 + 160)` — so the 4:3 image + fixed text area stays proportional at 1, 2, or 3 columns.

**Item detail presentation**: `showItemDetail()` in `item_detail_sheet.dart` auto-selects Dialog (≥700px width) or bottom sheet (narrow). Always call this helper rather than `showModalBottomSheet`/`showDialog` directly.

**Toast**: `_showToast()` in `item_detail_sheet.dart` uses `OverlayEntry` (not SnackBar) for content-hugging centered toasts. Capture `Overlay.of(context)` and `colorScheme` *before* `Navigator.pop()`.

**Sound**: Call `SoundService.playTap()` on every tap interaction before navigation or state change.

**Category chip images**: Each non-"All" chip shows a `ClipOval` 32×32 image from the first `MenuItem` in that category, embedded in the chip's `label` (not the `avatar` slot, which is constrained to ~18dp by the chip theme).

## Data

`mock_menu.dart` is the single source of truth. `menuCategories` order controls both the filter chips and the `_railDestinations` list in `menu_screen_left.dart` — keep them in sync when reordering categories.

Food images live in `Images/Food/<Category>/` and are declared per-item via `imagePath`. Items with no image use `imagePath: ''` and fall back to an icon+color `ColoredBox`.

## Key Dependencies

| Package | Purpose |
|---|---|
| `dynamic_color` | Detects system accent (bypassed intentionally) |
| `google_fonts` | Google Sans Flex variable typeface |
| `flutter_svg` | Pine Labs logo rendering |
| `audioplayers` | Tap sound feedback |
| `flutter_lints` | Lint rules |

## Installed Agent Skills

Two skills are installed in `.agents/skills/` (symlinked to `.claude/skills/`):

- **agentation** — Sets up the Agentation visual annotation toolbar (Next.js only; not applicable to this Flutter project)
- **agentation-self-driving** — Autonomous design critique mode; drives a headed browser to add design annotations via the toolbar. Requires `agent-browser` to be available. Invoke with `/agentation-self-driving <url>` if critiquing a web build of this app.
