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
**Tech:** Flutter 3.41.6 | Riverpod | Drift/SQLite | Google Fonts (Outfit, Poppins)

## Conventions
- **Currency:** CLP (pesos chilenos), format `$3.500`, stored as `int` cents (350000 = $3.500)
- **UI language:** Spanish
- **Code language:** English
- **User mode:** Autonomous — execute without asking, fix errors, use defaults
- **Tests:** Run after each component. Target >80% coverage
- **Commit style:** Descriptive message + Co-Authored-By Claude

## What's DONE

### Phase 1 — UI Layer ✓
- Theme system: `lib/core/theme/` (colors, typography, spacing, shadows, theme)
- Animation system: `lib/core/animations/` (curves, durations, scale_on_tap, fly_to_cart, staggered_grid, animated_counter)
- Components: `lib/presentation/widgets/` (category_card, product_card, promo_card, hero_banner, kiosk_search_bar, cart_bottom_bar)
- HomeScreen: Responsive portrait/landscape, breakpoint 900px

### Phase 2 — Domain Layer ✓
- `lib/domain/entities/` — Product, Category, CartItem, Cart, Order (with OrderStatus, PaymentMethod enums)
- `lib/domain/repositories/` — ProductRepository, CartRepository, OrderRepository (abstracts)
- `lib/domain/usecases/` — AddToCart, RemoveFromCart, CalculateTotal, PlaceOrder

### Phase 3 — Data Layer ✓
- `lib/data/datasources/app_database.dart` — Drift/SQLite with Categories, Products, Orders, OrderItems tables + seed data
- `lib/data/repositories/` — ProductRepositoryImpl, CartRepositoryImpl, OrderRepositoryImpl
- `lib/data/models/db_mappers.dart` — Entity ↔ DB model conversion

### Phase 4 — State Management (Riverpod) ✓
- `lib/presentation/providers/` — databaseProvider, productRepositoryProvider, cartRepositoryProvider, orderRepositoryProvider
- categoriesProvider, productsProvider (with search + category filter), cartProvider (StateNotifier), orderProvider
- HomeScreen connected to real data via providers, mock data removed

### Phase 5 — Additional Screens ✓
- `category_screen.dart` — Products filtered by category with grid
- `cart_screen.dart` — Full cart review with +/- controls, total, pay button
- `checkout_screen.dart` — Order summary + payment method selection (cash/card/transfer)
- `payment_screen.dart` — Payment processing with confirmation
- `success_screen.dart` — Order confirmation with queue number display

### Phase 6 — Integration & QA ✓
- Integration tests: complete order flow, search, cart management, queue numbers, order status updates
- Widget tests for all screens (home, cart, checkout, category, payment, success)
- Provider tests (CartProvider)
- 128 tests total, 80% source coverage (excluding generated Drift code)
- `flutter analyze` — 0 issues

### Phase 7 — Polish ✓
- `lib/l10n/app_strings.dart` — Centralized Spanish strings for i18n readiness
- `lib/data/sync/offline_sync_queue.dart` — Queue with retry logic (max 3 retries)
- `lib/presentation/screens/admin/admin_panel_screen.dart` — Admin panel with product management, order history, printer config
- `lib/data/services/receipt_printer.dart` — Receipt generation + print placeholder

### Phase A — Auth + Roles ✓
- `lib/domain/entities/user.dart` — AppUser entity with UserRole enum (admin/worker)
- `lib/data/repositories/auth_repository_impl.dart` — PIN authentication via Drift DB
- `lib/presentation/providers/auth_provider.dart` — AuthNotifier with login/logout
- `lib/presentation/screens/login_screen.dart` — PIN numpad, kiosk mode bypass
- Users table with seed data: admin (PIN 1234), worker (PIN 0000)

### Phase B — CRUD Products + Images ✓
- `lib/presentation/screens/admin/product_list_screen.dart` — Product listing with availability toggle, edit, delete
- `lib/presentation/screens/admin/product_form_screen.dart` — Create/edit product with image picker, price, category
- `lib/presentation/screens/admin/category_management_screen.dart` — Category CRUD with drag-to-reorder
- image_picker integration for local image storage

### Phase C — Offers/Promos ✓
- `lib/domain/entities/promo.dart` — Promo entity with % and fixed discounts, date range validation
- `lib/data/repositories/promo_repository_impl.dart` — Promo CRUD via Drift
- `lib/presentation/screens/admin/promo_management_screen.dart` — Full promo management UI
- Promos table in Drift DB

### Phase D — Kitchen Screen ✓
- `lib/presentation/screens/kitchen/kitchen_screen.dart` — Three-column Kanban board
- Columns: Pendientes → Preparando → Listos (with count badges)
- Auto-refresh every 5 seconds for new orders
- One-tap status progression, order details with items + queue number

### Final Stats
- **158 tests** — all passing
- **0 analysis issues**
- **Architecture:** Clean Architecture (domain/data/presentation layers)
- **Auth:** PIN-based with admin/worker roles
- **App flow:** Login → (Admin Panel | Kitchen | Kiosk mode)

## Key Design Specs (from Figma)
- Primary: #FF9B17 | PrimaryDark: #FF4D03
- PromoRed: #AC0E02 | PromoBrown: #A33310
- Fonts: Outfit (general), Poppins (promos)
- Border radius: 22(pills), 25(cards), 35(inputs/banners), 37(CTAs)
- Component sizes: Category 195x195, Product 260x240, Promo 453x195, Banner fullx377, SearchBar fullx125, CartBar fullx183

## Commands
```bash
flutter test                    # Run all 158 tests
flutter test --coverage         # With coverage report
flutter analyze                 # Static analysis
flutter run                     # Run app
dart run build_runner build     # Regenerate Drift code
```
