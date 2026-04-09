# Kiosko POS v2

Sistema POS de autoservicio para pedidos de comida. Diseñado para tablets Android, 100% offline via LAN.

## Modos de uso

| Modo | Acceso | Descripcion |
|------|--------|-------------|
| **Admin** | PIN 1234 | Gestionar productos, categorias, promos, usuarios, reportes, impresora, backup, LAN |
| **Cocina** | PIN 0000 | Kanban de pedidos: Pendientes -> Preparando -> Listos |
| **Kiosko** | Sin PIN | Cliente navega menu, personaliza productos, paga |
| **Pedidos** | Sin PIN | Display publico de turnos (para TV) |
| **Menu** | Sin PIN | Carrusel digital de productos y ofertas |

## Quick Start

```bash
git clone https://github.com/HectorRiquelme/kiosko_v2.git
cd kiosko_v2
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test    # 195 tests
flutter run     # Ejecutar
```

### Requisitos
- Flutter 3.41+
- Java 17 (`export JAVA_HOME=/opt/homebrew/opt/openjdk@17`)
- Android SDK con ADB (`$HOME/Library/Android/sdk/platform-tools`)

## Arquitectura (Clean Architecture)

```
lib/
├── core/
│   ├── animations/          # Curves, durations, scale_on_tap, fly_to_cart, staggered_grid
│   ├── theme/               # Colors, typography, spacing, shadows, responsive
│   └── utils/               # PinHasher (SHA-256 + salt)
├── data/
│   ├── datasources/         # Drift DB: 9 tablas, schema v4, seed data
│   ├── models/              # Entity <-> DB mappers
│   ├── repositories/        # 7 implementaciones (auth, cart, order, product, promo, audit, sales)
│   ├── services/            # Backup, LAN sync, printer, session, Transbank
│   └── sync/                # Cola offline con retry
├── domain/
│   ├── entities/            # Product, Category, Cart, Order, User, Modifier, Promo, AuditLog
│   ├── repositories/        # Interfaces abstractas
│   └── usecases/            # AddToCart, RemoveFromCart, CalculateTotal, PlaceOrder
├── l10n/                    # Strings centralizados (espanol)
├── presentation/
│   ├── providers/           # Riverpod: auth, cart, categories, products, orders, database
│   ├── screens/
│   │   ├── admin/           # 10 pantallas de gestion
│   │   ├── kitchen/         # Kanban 3 columnas
│   │   ├── home_screen      # Responsive portrait/landscape
│   │   ├── login_screen     # PIN numpad + SafeArea
│   │   ├── cart/checkout/payment/success
│   │   ├── menu_board       # Carrusel digital paginado
│   │   └── order_display    # Cola publica con animacion
│   └── widgets/             # 9 widgets reutilizables
└── main.dart                # ProviderScope -> LoginScreen
```

## Base de datos (Drift/SQLite v4)

| Tabla | Campos clave |
|-------|-------------|
| Users | id, name, pin (SHA-256), role (admin/worker) |
| Categories | id, name, imageUrl, sortOrder |
| Products | id, name, imageUrl, priceInCents, categoryId, available |
| ProductModifiers | id, productId, group, name, priceAdjustCents |
| Promos | id, title, discountPercent, productIds, startDate, endDate |
| Orders | id, totalInCents, status, paymentMethod, queueNumber |
| OrderItems | id, orderId, productId, quantity, priceInCents |
| OrderItemModifiers | id, orderItemId, modifierName, priceAdjustCents |
| AuditLogs | id, userId, action, targetType, targetId, details |

## Flujo de la app

```
LoginScreen (PIN numpad)
├── PIN 1234 -> AdminPanelScreen (10 secciones de gestion)
├── PIN 0000 -> KitchenScreen (Kanban: Pendientes/Preparando/Listos)
├── "Kiosko" -> HomeScreen -> Cart -> Checkout -> Payment -> Success
├── "Pedidos" -> OrderDisplayScreen (cola publica)
└── "Menu"   -> MenuBoardScreen (carrusel digital)
```

## Design System

- **Primary:** #FF9B17 | **PrimaryDark:** #FF4D03
- **Backgrounds:** #FFF8F0 (warm), #FAF6F1 (cream), #F5F5F5 (grey)
- **Fonts:** Outfit (general), Poppins (promos)
- **Moneda:** CLP - formato $X.XXX (almacenado como int centavos)

## Testing

```bash
flutter test                    # 195 tests
flutter test --coverage         # Con reporte de coverage
flutter analyze                 # 0 issues
```

## Features implementadas

1. UI completa con design system Quickbite (theme, animations, 9 widgets)
2. Domain layer (9 entidades, 5 repos abstractos, 4 use cases)
3. Data layer (Drift/SQLite v4, 9 tablas, 7 repos, mappers, seed data)
4. State management (Riverpod providers para todos los flujos)
5. 11 pantallas (Home, Cart, Checkout, Payment, Success, Category, Login, Kitchen, OrderDisplay, MenuBoard)
6. Admin panel (10 pantallas de gestion)
7. Auth con PIN SHA-256 + session persistence
8. Pagos: Efectivo (ticket visual), Transbank POS (tarjeta), Transferencia
9. Cocina: Kanban 3 columnas, haptic+sound, auto-refresh
10. Menu Board: Carrusel digital paginado
11. Product Modifiers: Tamanos, leche, extras, azucar con ajuste de precio
12. Audit logging, Sales reports, Thermal printing, Backup/Restore, LAN Sync

## Pendiente

- [ ] Release build (APK firmado)
- [ ] Auto-timeout kiosk (volver a home tras 60s inactividad)
- [ ] Imagenes reales de productos
- [ ] Bluetooth printer native code
- [ ] Multiple extras selection (multi-select)
- [ ] Inventario/stock management
- [ ] i18n con archivos .arb

## Documentacion completa

Ver **[CLAUDE.md](CLAUDE.md)** para contexto completo: arquitectura detallada, esquema DB, instrucciones de continuacion autonoma, y estado de cada feature.
