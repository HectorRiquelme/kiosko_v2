# Kiosko POS v2

Sistema POS de autoservicio para pedidos de comida. Diseñado para tablets, 100% offline.

## Modos de uso

| Modo | Acceso | Descripcion |
|------|--------|-------------|
| **Admin** | PIN 1234 | Gestionar productos, categorias, promos, usuarios, reportes, impresora, backup, LAN |
| **Cocina** | PIN 0000 | Kanban de pedidos: Pendientes → Preparando → Listos |
| **Kiosko** | Sin PIN | Cliente navega menu, personaliza productos, paga |
| **Pedidos** | Sin PIN | Display publico de turnos (para TV) |
| **Menu** | Sin PIN | Carrusel digital de productos y ofertas (pantalla detras del cajero) |

## Quick Start

```bash
git clone https://github.com/HectorRiquelme/kiosko_v2.git
cd kiosko_v2
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test    # 196 tests
flutter run     # Ejecutar
```

## Tech Stack

Flutter 3.41 | Riverpod | Drift/SQLite | Google Fonts | Transbank POS | ESC/POS Printing

## Documentacion completa

Ver **[CLAUDE.md](CLAUDE.md)** — contiene arquitectura, esquema DB, flujos, estado de features, y TODOs pendientes. Ese archivo es la fuente de verdad para retomar el proyecto.
