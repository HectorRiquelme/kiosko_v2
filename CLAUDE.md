# Kiosko POS v2 - Project Context

## Quick Recovery
If starting a new session, say: "continua con kiosko v2" and Claude will have full context from this file.

### Auto-run mode
When the user says **"ejecuta todas las fases"** or **"continua todas las fases"** or **"fases 2-7"**:
1. Read this CLAUDE.md to recover context
2. Execute ALL pending phases (2 through 7) sequentially without stopping
3. For each phase: implement code, write tests, run `flutter test`, fix failures, run `flutter analyze`
4. After ALL phases complete: commit + push to GitHub, update this CLAUDE.md marking completed phases
5. Do NOT ask questions — use defaults, fix errors autonomously, skip if blocked after 3 attempts (leave TODO comment)
6. Keep a running todo list to track progress across phases

## Project Overview
Self-service kiosk POS for food ordering (cafeteria, restaurant, etc.). Based on Figma "Quickbite Kiosk UI/UX" design. Must work on tablets (portrait + landscape), fully offline via LAN.

**Repo:** https://github.com/HectorRiquelme/kiosko_v2
**Tech:** Flutter 3.41.6 | Riverpod (ready) | Drift/SQLite (pending) | Google Fonts (Outfit, Poppins)

## Conventions
- **Currency:** CLP (pesos chilenos), format `$3.500`, stored as `int` cents (350000 = $3.500)
- **UI language:** Spanish
- **Code language:** English
- **User mode:** Autonomous — execute without asking, fix errors, use defaults
- **Tests:** Run after each component. Target >80% coverage
- **Commit style:** Descriptive message + Co-Authored-By Claude

## What's DONE (Phase 1 - UI Layer) ✓

### Theme System (`lib/core/theme/`)
- `app_colors.dart` — Primary #FF9B17, promos, text, states
- `app_typography.dart` — Outfit + Poppins, headlines/body/labels/buttons
- `app_spacing.dart` — 8px grid, component sizes, border radii
- `app_shadows.dart` — searchBar, productCard, elevated
- `app_theme.dart` — ThemeData combining all tokens

### Animation System (`lib/core/animations/`)
- `app_curves.dart` — defaultEase, bounce, sharp, spring
- `app_durations.dart` — instant(100ms) to slow(500ms)
- `scale_on_tap.dart` — Reusable scale animation widget
- `fly_to_cart_overlay.dart` — Product flies to cart with bezier
- `staggered_grid_animation.dart` — Grid items fade+slide in sequence
- `animated_counter.dart` — Number flip transition

### Components (`lib/presentation/widgets/`)
- `category_card.dart` — 195x195, orange bg, scale 1.05 on tap
- `product_card.dart` — 260x240, CLP format, +/check button, haptic
- `promo_card.dart` — 453x195, two color variants (red/brown)
- `hero_banner.dart` — Full width x 377, dark bg, CTA button
- `kiosk_search_bar.dart` — Full width x 125, input + orange button
- `cart_bottom_bar.dart` — Full width x 183, slide-up, +/- controls

### Screens (`lib/presentation/screens/`)
- `home_screen.dart` — Responsive portrait (single scroll) / landscape (sidebar 25% + content 75%), breakpoint 900px

### Tests (41 passing, 73.5% coverage)
- `test/unit/core/theme/` — 13 tests (colors, spacing)
- `test/widget/components/` — 25 tests (all 6 components)
- `test/widget/screens/` — 3 tests (HomeScreen layout)

### QA
- `flutter analyze` — 0 issues
- `flutter test --coverage` — 73.5% (316/430 lines)

---

## What's PENDING (Next Phases)

### Phase 2 — Domain Layer
- [ ] `lib/domain/entities/` — Product, Category, CartItem, Cart, Order
- [ ] `lib/domain/repositories/` — ProductRepository, CartRepository, OrderRepository (abstracts)
- [ ] `lib/domain/usecases/` — AddToCart, RemoveFromCart, CalculateTotal, PlaceOrder

### Phase 3 — Data Layer
- [ ] `lib/data/datasources/` — Drift/SQLite local database
- [ ] `lib/data/repositories/` — Repository implementations
- [ ] `lib/data/models/` — DB models with toEntity/fromEntity

### Phase 4 — State Management (Riverpod)
- [ ] `lib/presentation/providers/` — cartProvider, productsProvider, categoriesProvider, orderProvider
- [ ] Connect HomeScreen to real data via providers
- [ ] Remove mock data from HomeScreen

### Phase 5 — Additional Screens
- [ ] `category_screen.dart` — Products filtered by category
- [ ] `cart_screen.dart` — Full cart review
- [ ] `checkout_screen.dart` — Order summary + payment selection
- [ ] `payment_screen.dart` — Payment processing
- [ ] `success_screen.dart` — Order confirmation with queue number

### Phase 6 — Integration & QA
- [ ] Integration tests (complete order flow, cart management, offline)
- [ ] Golden tests for visual regression
- [ ] Performance tests (scroll, animations)
- [ ] Coverage target >80%

### Phase 7 — Polish
- [ ] i18n support (flutter_localizations)
- [ ] Offline sync queue for orders
- [ ] Admin panel for product management
- [ ] Receipt printing support

## Key Design Specs (from Figma)
- Primary: #FF9B17 | PrimaryDark: #FF4D03
- PromoRed: #AC0E02 | PromoBrown: #A33310
- Fonts: Outfit (general), Poppins (promos)
- Border radius: 22(pills), 25(cards), 35(inputs/banners), 37(CTAs)
- Component sizes: Category 195x195, Product 260x240, Promo 453x195, Banner fullx377, SearchBar fullx125, CartBar fullx183

## Commands
```bash
flutter test                    # Run all 41 tests
flutter test --coverage         # With coverage report
flutter analyze                 # Static analysis
flutter run                     # Run app
```
