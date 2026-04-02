# Kiosko POS v2

Self-service kiosk application for food ordering, built with Flutter.

## Design System

Based on the **Quickbite** Figma design, featuring:

- **Colors**: Orange primary (#FF9B17), dark/light variants, promo colors
- **Typography**: Outfit + Poppins via Google Fonts
- **Spacing**: Consistent 8px grid system
- **Shadows**: Search bar, product card, and elevated variants

## Architecture

```
lib/
├── core/
│   ├── theme/          # Design tokens (colors, typography, spacing, shadows)
│   └── animations/     # Reusable animation system (curves, durations, widgets)
├── presentation/
│   ├── widgets/        # UI components (CategoryCard, ProductCard, PromoCard, etc.)
│   └── screens/        # Screen layouts (HomeScreen with portrait/landscape)
```

## Components

| Component | Size | Description |
|-----------|------|-------------|
| CategoryCard | 195x195 | Category selection with tap animation |
| ProductCard | 260x240 | Product display with add-to-cart |
| PromoCard | 453x195 | Promotional banner card |
| HeroBanner | full x 377 | Main promotional banner |
| KioskSearchBar | full x 125 | Search input with button |
| CartBottomBar | full x 183 | Floating cart summary bar |

## Features

- Responsive layout (portrait + landscape)
- Tap animations with scale effects
- Fly-to-cart animation overlay
- Staggered grid animations
- CLP currency formatting ($X.XXX)
- CachedNetworkImage with placeholders
- Accessibility semantics

## Getting Started

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test              # Run all tests
flutter test --coverage   # Run with coverage
```

## Test Results

- 41 tests passing
- 73.5% line coverage
- 0 analysis issues

## Tech Stack

- Flutter 3.41.6
- Google Fonts (Outfit, Poppins)
- CachedNetworkImage
- intl (CLP formatting)
- Riverpod-ready architecture
