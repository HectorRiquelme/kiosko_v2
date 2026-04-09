# Kiosko POS v2 - Full Project Context

> **Para retomar este proyecto en cualquier herramienta (Claude Code, OpenCode, Codex, Cursor, otro PC):**
> Lee este archivo completo. Contiene TODO el contexto necesario.

## Project Overview
Self-service kiosk POS for food ordering (cafeteria, restaurant, etc.). Based on Figma "Quickbite Kiosk UI/UX" design. Works on tablets (portrait + landscape), fully offline via LAN.

- **Repo:** https://github.com/HectorRiquelme/kiosko_v2
- **Figma:** https://www.figma.com/design/io500FRrfpJbvshdnotfF4/kiosk-UI-UX-case-study
- **Tech:** Flutter 3.41.6 | Riverpod 2.6.1 | Drift/SQLite (schema v4) | Google Fonts (Outfit, Poppins)
- **Tests:** 195 passing | 0 analysis issues
- **Target:** Android tablets (primary), Web (secondary)
- **Files:** 91 source files | 39 test files
- **Tablet:** MNP1095 device ID XCD1101AC825207271 (1920x1200)

## Conventions
- **Currency:** CLP (pesos chilenos), format `$3.500`, stored as `int` cents (350000 = $3.500)
- **UI language:** Spanish
- **Code language:** English
- **PIN hashing:** SHA-256 + salt via `lib/core/utils/pin_hasher.dart`
- **DB:** Drift with conditional imports (native FFI for Android, WASM for web)
- **Images:** `SmartImage` widget handles `asset:`, file paths, and HTTP URLs

## App Flow
```
LoginScreen (PIN numpad)
├── PIN 1234 → AdminPanelScreen
│   ├── Gestion de productos (CRUD + images)
│   ├── Gestion de categorias (drag-to-reorder)
│   ├── Gestion de ofertas (promos with discounts)
│   ├── Historial de pedidos
│   ├── Gestion de usuarios (CRUD + PIN validation)
│   ├── Registro de actividad (audit log)
│   ├── Reporte de ventas (daily/weekly/monthly)
│   ├── Configurar impresora (Bluetooth/USB thermal)
│   ├── Backup / Restaurar (DB export/import)
│   └── Sincronizacion LAN (multi-tablet)
├── PIN 0000 → KitchenScreen (Kanban: Pendientes → Preparando → Listos)
├── "Kiosko" → HomeScreen → Cart → Checkout → Payment → Success
├── "Pedidos" → OrderDisplayScreen (public queue board)
└── "Menu" → MenuBoardScreen (digital signage carousel)
```

## Architecture (Clean Architecture)
```
lib/
├── core/
│   ├── animations/          # Curves, durations, scale_on_tap, fly_to_cart, staggered_grid, animated_counter
│   ├── theme/               # Colors, typography, spacing, shadows, theme, responsive
│   └── utils/               # PinHasher (SHA-256)
├── data/
│   ├── datasources/
│   │   ├── app_database.dart       # Drift DB: 9 tables, schema v4, seed data
│   │   ├── app_database.g.dart     # Generated (dart run build_runner build)
│   │   └── connection/             # Conditional: native.dart, web.dart, unsupported.dart
│   ├── models/
│   │   └── db_mappers.dart         # Entity ↔ DB conversion
│   ├── repositories/
│   │   ├── audit_log_repository.dart
│   │   ├── auth_repository_impl.dart    # PIN hashing + migration from plaintext
│   │   ├── cart_repository_impl.dart    # In-memory, uses cartKey for modifier support
│   │   ├── modifier_repository.dart
│   │   ├── order_repository_impl.dart   # Atomic queue numbers in transaction
│   │   ├── product_repository_impl.dart # SQL injection safe (LIKE escaping)
│   │   ├── promo_repository_impl.dart
│   │   └── sales_report_repository.dart # Daily/weekly/monthly aggregations
│   ├── services/
│   │   ├── audit_logger.dart            # Convenience logger from providers
│   │   ├── backup_service.dart          # DB file copy/restore
│   │   ├── lan_sync_service.dart        # HTTP server on port 8090
│   │   ├── receipt_printer.dart         # Text receipt generation
│   │   ├── session_manager.dart         # SharedPreferences session
│   │   ├── thermal_printer_service.dart # ESC/POS byte generation
│   │   └── transbank/
│   │       └── transbank_service.dart   # MethodChannel to Android native
│   └── sync/
│       └── offline_sync_queue.dart      # Queue with retry logic
├── domain/
│   ├── entities/
│   │   ├── audit_log_entry.dart   # AuditAction enum, AuditEntityType enum
│   │   ├── cart.dart              # totalInCents, totalItems, containsProduct, quantityOf
│   │   ├── cart_item.dart         # cartKey = product+modifiers, modifiersLabel
│   │   ├── category.dart
│   │   ├── modifier.dart          # ProductModifierOption, SelectedModifier, ModifierGroup
│   │   ├── order.dart             # OrderStatus, PaymentMethod enums
│   │   ├── product.dart
│   │   ├── promo.dart             # isCurrentlyActive, calculateDiscount
│   │   └── user.dart              # AppUser, UserRole enum
│   ├── repositories/              # Abstract interfaces
│   │   ├── auth_repository.dart   # isPinAvailable for uniqueness
│   │   ├── cart_repository.dart   # Uses cartKey, supports modifiers
│   │   ├── order_repository.dart
│   │   ├── product_repository.dart # Full CRUD + toggleAvailability
│   │   └── promo_repository.dart
│   └── usecases/
│       ├── add_to_cart.dart
│       ├── calculate_total.dart
│       ├── place_order.dart       # Validates cart not empty, clears after
│       └── remove_from_cart.dart
├── l10n/
│   └── app_strings.dart           # Centralized Spanish strings
├── main.dart                      # ProviderScope → LoginScreen
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart         # AuthNotifier + session restore
    │   ├── cart_provider.dart         # CartNotifier with modifier support
    │   ├── categories_provider.dart
    │   ├── database_provider.dart     # All repository providers
    │   ├── order_provider.dart        # Audit logs on sale
    │   └── products_provider.dart     # Search + category filter
    ├── screens/
    │   ├── admin/
    │   │   ├── admin_panel_screen.dart
    │   │   ├── audit_log_screen.dart
    │   │   ├── backup_screen.dart
    │   │   ├── category_management_screen.dart
    │   │   ├── lan_sync_screen.dart
    │   │   ├── printer_settings_screen.dart
    │   │   ├── product_form_screen.dart
    │   │   ├── product_list_screen.dart
    │   │   ├── promo_management_screen.dart
    │   │   ├── sales_report_screen.dart
    │   │   └── user_management_screen.dart
    │   ├── kitchen/
    │   │   └── kitchen_screen.dart     # 3-column Kanban, auto-refresh 5s, haptic+sound
    │   ├── cart_screen.dart
    │   ├── category_screen.dart
    │   ├── checkout_screen.dart
    │   ├── home_screen.dart            # Responsive portrait/landscape, modifier dialog
    │   ├── login_screen.dart           # PIN numpad, session restore, kiosk/menu/display modes
    │   ├── menu_board_screen.dart      # Auto-rotating carousel, paginated slides
    │   ├── order_display_screen.dart   # Public queue board, pulse animation
    │   ├── payment_screen.dart         # Transbank card, cash ticket, confirmation dialog
    │   └── success_screen.dart         # Cash ticket widget, Transbank auth display
    └── widgets/
        ├── cart_bottom_bar.dart
        ├── cash_ticket.dart            # Visual receipt for cash payments
        ├── category_card.dart
        ├── hero_banner.dart
        ├── kiosk_search_bar.dart
        ├── modifier_dialog.dart        # Grouped ChoiceChips with live price
        ├── product_card.dart
        ├── promo_card.dart
        └── smart_image.dart            # Handles asset:/file/http images
```

## Database Schema (v4)
| Table | Key Fields |
|-------|-----------|
| Users | id, name, pin (SHA-256 hashed), role (admin/worker) |
| Categories | id, name, imageUrl, sortOrder |
| Products | id, name, imageUrl, priceInCents, categoryId, description, available |
| ProductModifiers | id, productId, group, name, priceAdjustCents, sortOrder, isDefault |
| Promos | id, title, subtitle, backgroundColor, discountPercent, discountAmountCents, productIds, startDate, endDate, active |
| Orders | id, totalInCents, status, paymentMethod, queueNumber, createdAt |
| OrderItems | id, orderId, productId, quantity, priceInCents |
| OrderItemModifiers | id, orderItemId, modifierName, modifierGroup, priceAdjustCents |
| AuditLogs | id, userId, userName, action, targetType, targetId, targetName, details, createdAt |

## Seed Data (created on fresh install)
- **Users:** admin1 (PIN 1234), worker1 (PIN 0000)
- **Categories:** Cafe, Bebidas, Pasteles, Snacks, Combos
- **Products:** 19 total with local asset images and descriptions
- **Modifiers:** Sizes (S/M/L), Milk (Normal/Descremada/Soya/Almendra), Extras (Shot/Crema/Caramelo), Sugar (Normal/Sin/Stevia) — for coffee/beverage products
- **Promos:** 4 active (Happy Hour 30%, 2x1 Pasteles, Combo Desayuno -$1000, Chai 20%)
- **Orders:** 4 demo (2 pending, 1 preparing, 1 ready)
- **Audit Logs:** 7 demo entries

## Android Native Code
`android/app/src/main/kotlin/com/kiosko/kiosko_v2/MainActivity.kt`:
- **Transbank channel** (`com.kiosko.transbank`): processPayment, isAvailable, getLastTransaction
- **Printer channel** (`com.kiosko.printer`): discoverPrinters, printRaw (stubs, need real implementation)

## Security
- PINs hashed with SHA-256 + salt (auto-migrates plaintext PINs on first login)
- SQL injection prevention in product search (LIKE character escaping)
- Queue numbers assigned atomically inside DB transaction
- Failed login attempts logged to audit system
- PINs hidden in admin UI (shows ****)
- Payment flow: double-tap prevention, PopScope blocks back during processing, empty cart guard

## Design Specs
- **Primary:** #FF9B17 | **PrimaryDark:** #FF4D03
- **Warm backgrounds:** #FFF8F0 (backgroundWarm), #FAF6F1 (backgroundCream)
- **Fonts:** Outfit (general), Poppins (promos)
- **Gradient headers:** LinearGradient(#FF9B17 → #FF7B00)

## Auto-run mode (for Claude Code / tmux)
When the user says **"ejecuta todas las fases"** or **"continua con los TODOs"**:
1. Read this CLAUDE.md to recover context
2. Execute ALL pending TODOs sequentially without stopping
3. For each TODO: implement, write tests, run `flutter test`, fix failures, run `flutter analyze`
4. After ALL complete: commit + push to GitHub, update this file
5. Do NOT ask questions — use defaults, fix errors autonomously
6. If blocked after 3 attempts, leave a TODO comment and continue

### Quick resume prompt:
```
cd ~/trabajo/kiosko_v2 && claude "continua con los TODOs pendientes del CLAUDE.md sin detenerte"
```

## Commands
```bash
flutter test                          # Run all 195 tests
flutter test --coverage               # With coverage report
flutter analyze                       # Static analysis (must be 0 issues)
flutter run -d <device>               # Run on device
flutter build apk --debug             # Build debug APK
dart run build_runner build --delete-conflicting-outputs  # Regenerate Drift code
```

## Environment Notes
- **Java:** Required for Android builds. On macOS: `export JAVA_HOME=/opt/homebrew/opt/openjdk@17`
- **ADB path:** `$HOME/Library/Android/sdk/platform-tools`
- **Web:** Needs sqlite3.wasm + drift_worker.dart.js in web/ folder
- **Fresh install:** Use `adb uninstall com.kiosko.kiosko_v2` before install to reset DB seeds

## What's DONE ✓
1. UI Layer — Theme, animations, 9 widgets, responsive HomeScreen
2. Domain Layer — 9 entities, 5 repositories, 4 use cases
3. Data Layer — Drift/SQLite v4, 9 tables, 7 repository implementations, mappers
4. State Management — Riverpod providers for all data flows
5. Screens — Home, Cart, Checkout, Payment, Success, Category, Login, Kitchen, OrderDisplay, MenuBoard
6. Admin Panel — 10 management screens (products, categories, promos, users, orders, audit, reports, printer, backup, LAN sync)
7. Auth — PIN-based with SHA-256 hashing, session persistence, role-based routing
8. Payments — Cash (with visual ticket), Transbank POS (card), Transfer
9. Kitchen — 3-column Kanban, haptic+sound notifications, auto-refresh
10. Menu Board — Auto-rotating digital signage with paginated slides
11. Order Display — Public queue board with pulse animations
12. Product Modifiers — Sizes, milk, extras, sugar with price adjustments
13. Audit Logging — All CRUD + sales + login attempts
14. Sales Reports — Daily/weekly/monthly with top products and payment breakdown
15. Thermal Printing — ESC/POS protocol, Bluetooth/USB discovery
16. Backup/Restore — DB file copy with safety backup
17. LAN Sync — HTTP server for multi-tablet order synchronization
18. Security Audit — Hashed PINs, SQL injection fix, atomic transactions, failed login tracking

## What's PENDING / TODO
- [ ] **Release build** — Signed APK for production deployment
- [ ] **Auto-timeout kiosk** — Return to home after 60s inactivity
- [ ] **Real product images** — Export transparent PNGs from Figma (current: Unsplash photos)
- [ ] **Bluetooth printer native code** — Complete discovery/print in MainActivity.kt
- [ ] **LAN sync integration** — Wire LanSyncService into order providers
- [ ] **Multiple extras selection** — Currently one per group; change Extras to multi-select
- [ ] **Inventory/stock management** — Track quantities, low stock alerts
- [ ] **Customer loyalty** — Points, rewards, frequent buyer discounts
- [ ] **i18n with .arb files** — Currently hardcoded Spanish, prepare for English
- [ ] **End-to-end testing on tablet** — Full order flow, kitchen, display
- [ ] **Performance optimization** — Profile scroll, reduce rebuilds
- [ ] **App icon and splash screen** — Branded launch experience

## Conventions (for AI assistants)
- **Currency:** CLP (pesos chilenos), format `$3.500`, stored as `int` cents (350000 = $3.500)
- **UI language:** Spanish
- **Code language:** English
- **Mode:** Autonomous — execute without asking, fix errors, use defaults
- **After changes:** Run `flutter test` + `flutter analyze` before committing
- **Commit style:** Descriptive message + ` Opus 4.6 (1M context) <noreply@anthropic.com>`
- **If blocked 3 times:** Comment with TODO and continue
