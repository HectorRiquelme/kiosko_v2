import 'package:drift/drift.dart';
import '../../core/utils/pin_hasher.dart';
import 'connection/unsupported.dart'
    if (dart.library.ffi) 'connection/native.dart'
    if (dart.library.js_interop) 'connection/web.dart' as connection;

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get pin => text()();
  TextColumn get role => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  IntColumn get priceInCents => integer()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get description => text().nullable()();
  BoolColumn get available => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Promos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  TextColumn get backgroundColor => text().withDefault(const Constant('#AC0E02'))();
  IntColumn get discountPercent => integer().withDefault(const Constant(0))();
  IntColumn get discountAmountCents => integer().withDefault(const Constant(0))();
  TextColumn get productIds => text().withDefault(const Constant(''))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  IntColumn get totalInCents => integer()();
  TextColumn get status => text()();
  TextColumn get paymentMethod => text()();
  IntColumn get queueNumber => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  IntColumn get priceInCents => integer()();
}

class ProductModifiers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  TextColumn get group => text()(); // 'size', 'extras', 'milk', etc
  TextColumn get name => text()(); // 'Grande', 'Crema extra', 'Leche soya'
  IntColumn get priceAdjustCents => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

class OrderItemModifiers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderItemId => integer()();
  TextColumn get modifierName => text()();
  TextColumn get modifierGroup => text()();
  IntColumn get priceAdjustCents => integer().withDefault(const Constant(0))();
}

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get userName => text()();
  TextColumn get action => text()();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get targetName => text()();
  TextColumn get details => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Users, Categories, Products, Promos, Orders, OrderItems, ProductModifiers, OrderItemModifiers, AuditLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _seedData();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(users);
          await m.createTable(promos);
          await _seedUsers();
        }
        if (from < 3) {
          await m.createTable(auditLogs);
        }
        if (from < 4) {
          await m.createTable(productModifiers);
          await m.createTable(orderItemModifiers);
          await _seedModifiers();
        }
      },
    );
  }

  Future<void> _seedUsers() async {
    await batch((b) {
      b.insertAll(users, [
        UsersCompanion.insert(
          id: 'admin1',
          name: 'Administrador',
          pin: PinHasher.hash('1234'),
          role: 'admin',
        ),
        UsersCompanion.insert(
          id: 'worker1',
          name: 'Cocina 1',
          pin: PinHasher.hash('0000'),
          role: 'worker',
        ),
      ]);
    });
  }

  Future<void> _seedModifiers() async {
    await batch((b) {
      b.insertAll(productModifiers, [
        // Sizes for all coffees
        for (final pid in ['cap', 'lat', 'ame', 'moc', 'esp', 'fla', 'chai']) ...[
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Tamano', name: 'Pequeno',
            isDefault: const Value(true), sortOrder: const Value(0),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Tamano', name: 'Mediano',
            priceAdjustCents: const Value(50000), sortOrder: const Value(1),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Tamano', name: 'Grande',
            priceAdjustCents: const Value(100000), sortOrder: const Value(2),
          ),
        ],
        // Milk options for coffees
        for (final pid in ['cap', 'lat', 'moc', 'fla', 'chai']) ...[
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Leche', name: 'Normal',
            isDefault: const Value(true), sortOrder: const Value(0),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Leche', name: 'Descremada',
            sortOrder: const Value(1),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Leche', name: 'Soya',
            priceAdjustCents: const Value(30000), sortOrder: const Value(2),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Leche', name: 'Almendra',
            priceAdjustCents: const Value(40000), sortOrder: const Value(3),
          ),
        ],
        // Extras for coffees
        for (final pid in ['cap', 'lat', 'ame', 'moc', 'fla']) ...[
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Extras', name: 'Shot extra',
            priceAdjustCents: const Value(50000), sortOrder: const Value(0),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Extras', name: 'Crema batida',
            priceAdjustCents: const Value(30000), sortOrder: const Value(1),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Extras', name: 'Caramelo',
            priceAdjustCents: const Value(30000), sortOrder: const Value(2),
          ),
        ],
        // Sugar for all beverages
        for (final pid in ['cap', 'lat', 'ame', 'moc', 'esp', 'fla', 'chai']) ...[
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Azucar', name: 'Normal',
            isDefault: const Value(true), sortOrder: const Value(0),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Azucar', name: 'Sin azucar',
            sortOrder: const Value(1),
          ),
          ProductModifiersCompanion.insert(
            productId: pid, group: 'Azucar', name: 'Stevia',
            sortOrder: const Value(2),
          ),
        ],
      ]);
    });
  }

  Future<void> _seedData() async {
    await _seedUsers();
    await _seedCatalog();
    await _seedModifiers();
    await _seedPromos();
    await _seedDemoOrders();
    await _seedDemoAuditLogs();
  }

  Future<void> _seedCatalog() async {
    await batch((b) {
      b.insertAll(categories, [
        CategoriesCompanion.insert(
            id: 'cafe', name: 'Cafe', imageUrl: 'asset:assets/categories/cafe.png'),
        CategoriesCompanion.insert(
            id: 'bebidas', name: 'Bebidas',
            imageUrl: 'asset:assets/categories/bebidas.png',
            sortOrder: const Value(1)),
        CategoriesCompanion.insert(
            id: 'pasteles', name: 'Pasteles',
            imageUrl: 'asset:assets/categories/pasteles.png',
            sortOrder: const Value(2)),
        CategoriesCompanion.insert(
            id: 'snacks', name: 'Snacks',
            imageUrl: 'asset:assets/categories/snacks.png',
            sortOrder: const Value(3)),
        CategoriesCompanion.insert(
            id: 'combos', name: 'Combos',
            imageUrl: 'asset:assets/categories/combos.png',
            sortOrder: const Value(4)),
      ]);

      b.insertAll(products, [
        // Cafe (6)
        ProductsCompanion.insert(id: 'cap', name: 'Cappuccino',
            imageUrl: 'asset:assets/products/cappuccino.png',
            priceInCents: 350000, categoryId: 'cafe',
            description: const Value('Espresso con leche vaporizada y espuma')),
        ProductsCompanion.insert(id: 'lat', name: 'Latte',
            imageUrl: 'asset:assets/products/latte.png',
            priceInCents: 380000, categoryId: 'cafe',
            description: const Value('Cafe con leche cremosa')),
        ProductsCompanion.insert(id: 'ame', name: 'Americano',
            imageUrl: 'asset:assets/products/americano.png',
            priceInCents: 280000, categoryId: 'cafe',
            description: const Value('Espresso diluido en agua caliente')),
        ProductsCompanion.insert(id: 'moc', name: 'Mocha',
            imageUrl: 'asset:assets/products/mocha.png',
            priceInCents: 420000, categoryId: 'cafe',
            description: const Value('Cafe con chocolate y crema')),
        ProductsCompanion.insert(id: 'esp', name: 'Espresso',
            imageUrl: 'asset:assets/products/espresso.png',
            priceInCents: 250000, categoryId: 'cafe',
            description: const Value('Shot de cafe concentrado')),
        ProductsCompanion.insert(id: 'fla', name: 'Flat White',
            imageUrl: 'asset:assets/products/flat_white.png',
            priceInCents: 390000, categoryId: 'cafe',
            description: const Value('Doble espresso con leche texturizada')),
        // Bebidas (4)
        ProductsCompanion.insert(id: 'jug', name: 'Jugo Natural',
            imageUrl: 'asset:assets/products/jugo_natural.png',
            priceInCents: 320000, categoryId: 'bebidas',
            description: const Value('Naranja recien exprimida')),
        ProductsCompanion.insert(id: 'lim', name: 'Limonada',
            imageUrl: 'asset:assets/products/limonada.png',
            priceInCents: 280000, categoryId: 'bebidas',
            description: const Value('Limon, agua y un toque de menta')),
        ProductsCompanion.insert(id: 'agua', name: 'Agua Mineral',
            imageUrl: 'asset:assets/products/limonada.png',
            priceInCents: 150000, categoryId: 'bebidas',
            description: const Value('Agua mineral 500ml')),
        ProductsCompanion.insert(id: 'chai', name: 'Chai Latte',
            imageUrl: 'asset:assets/products/latte.png',
            priceInCents: 400000, categoryId: 'bebidas',
            description: const Value('Te chai con leche espumada y canela')),
        // Pasteles (3)
        ProductsCompanion.insert(id: 'tor', name: 'Torta Chocolate',
            imageUrl: 'asset:assets/products/torta_chocolate.png',
            priceInCents: 450000, categoryId: 'pasteles',
            description: const Value('Bizcocho de chocolate con ganache')),
        ProductsCompanion.insert(id: 'cheese', name: 'Cheesecake',
            imageUrl: 'asset:assets/products/torta_chocolate.png',
            priceInCents: 480000, categoryId: 'pasteles',
            description: const Value('Cheesecake con base de galleta')),
        ProductsCompanion.insert(id: 'roll', name: 'Cinnamon Roll',
            imageUrl: 'asset:assets/products/croissant.png',
            priceInCents: 350000, categoryId: 'pasteles',
            description: const Value('Rollo de canela con glaseado')),
        // Snacks (3)
        ProductsCompanion.insert(id: 'cro', name: 'Croissant',
            imageUrl: 'asset:assets/products/croissant.png',
            priceInCents: 280000, categoryId: 'snacks',
            description: const Value('Croissant de mantequilla horneado')),
        ProductsCompanion.insert(id: 'sand', name: 'Sandwich Jamon Queso',
            imageUrl: 'asset:assets/products/croissant.png',
            priceInCents: 420000, categoryId: 'snacks',
            description: const Value('Pan ciabatta, jamon, queso fundido')),
        ProductsCompanion.insert(id: 'muf', name: 'Muffin Arandanos',
            imageUrl: 'asset:assets/products/torta_chocolate.png',
            priceInCents: 320000, categoryId: 'snacks',
            description: const Value('Muffin esponjoso con arandanos frescos')),
        // Combos (3)
        ProductsCompanion.insert(id: 'com1', name: 'Combo Cafe + Torta',
            imageUrl: 'asset:assets/products/combo.png',
            priceInCents: 650000, categoryId: 'combos',
            description: const Value('Cualquier cafe + porcion de torta')),
        ProductsCompanion.insert(id: 'com2', name: 'Combo Desayuno',
            imageUrl: 'asset:assets/products/combo.png',
            priceInCents: 550000, categoryId: 'combos',
            description: const Value('Cafe + croissant + jugo natural')),
        ProductsCompanion.insert(id: 'com3', name: 'Combo Sandwich + Bebida',
            imageUrl: 'asset:assets/products/combo.png',
            priceInCents: 580000, categoryId: 'combos',
            description: const Value('Sandwich + cualquier bebida fria')),
      ]);
    });
  }

  Future<void> _seedPromos() async {
    final now = DateTime.now();
    await batch((b) {
      b.insertAll(promos, [
        PromosCompanion.insert(
          id: 'promo1',
          title: 'Happy Hour Cafe',
          subtitle: const Value('Lunes a Viernes 15:00-17:00'),
          backgroundColor: const Value('#AC0E02'),
          discountPercent: const Value(30),
          productIds: const Value('cap,lat,ame,moc,esp,fla'),
          startDate: Value(now.subtract(const Duration(days: 1))),
          endDate: Value(now.add(const Duration(days: 30))),
        ),
        PromosCompanion.insert(
          id: 'promo2',
          title: '2x1 Pasteles',
          subtitle: const Value('Todos los martes'),
          backgroundColor: const Value('#A33310'),
          discountPercent: const Value(50),
          productIds: const Value('tor,cheese,roll'),
          startDate: Value(now.subtract(const Duration(days: 1))),
          endDate: Value(now.add(const Duration(days: 60))),
        ),
        PromosCompanion.insert(
          id: 'promo3',
          title: 'Combo Desayuno',
          subtitle: const Value('Ahorra \$1.000'),
          backgroundColor: const Value('#FF4D03'),
          discountAmountCents: const Value(100000),
          productIds: const Value('com2'),
          startDate: Value(now.subtract(const Duration(days: 1))),
          endDate: Value(now.add(const Duration(days: 90))),
        ),
        PromosCompanion.insert(
          id: 'promo4',
          title: 'Nuevo: Chai Latte',
          subtitle: const Value('Pruebalo con 20% OFF'),
          backgroundColor: const Value('#2196F3'),
          discountPercent: const Value(20),
          productIds: const Value('chai'),
          startDate: Value(now.subtract(const Duration(days: 1))),
          endDate: Value(now.add(const Duration(days: 14))),
        ),
      ]);
    });
  }

  Future<void> _seedDemoOrders() async {
    final now = DateTime.now();
    await batch((b) {
      // Order 1 - Pending (just placed)
      b.insertAll(orders, [
        OrdersCompanion.insert(
          id: 'demo_ord1', totalInCents: 730000,
          status: 'pending', paymentMethod: 'cash',
          queueNumber: 1,
          createdAt: now.subtract(const Duration(minutes: 12)),
        ),
        // Order 2 - Preparing
        OrdersCompanion.insert(
          id: 'demo_ord2', totalInCents: 550000,
          status: 'preparing', paymentMethod: 'card',
          queueNumber: 2,
          createdAt: now.subtract(const Duration(minutes: 8)),
        ),
        // Order 3 - Ready
        OrdersCompanion.insert(
          id: 'demo_ord3', totalInCents: 350000,
          status: 'ready', paymentMethod: 'cash',
          queueNumber: 3,
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
        // Order 4 - Pending
        OrdersCompanion.insert(
          id: 'demo_ord4', totalInCents: 900000,
          status: 'pending', paymentMethod: 'transfer',
          queueNumber: 4,
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
      ]);

      b.insertAll(orderItems, [
        // Order 1: Cappuccino x2 + Croissant
        OrderItemsCompanion.insert(orderId: 'demo_ord1', productId: 'cap', quantity: 2, priceInCents: 350000),
        OrderItemsCompanion.insert(orderId: 'demo_ord1', productId: 'cro', quantity: 1, priceInCents: 280000),
        // Order 2: Combo Desayuno
        OrderItemsCompanion.insert(orderId: 'demo_ord2', productId: 'com2', quantity: 1, priceInCents: 550000),
        // Order 3: Espresso
        OrderItemsCompanion.insert(orderId: 'demo_ord3', productId: 'esp', quantity: 1, priceInCents: 250000),
        // Order 4: Torta + Mocha + Latte
        OrderItemsCompanion.insert(orderId: 'demo_ord4', productId: 'tor', quantity: 1, priceInCents: 450000),
        OrderItemsCompanion.insert(orderId: 'demo_ord4', productId: 'moc', quantity: 1, priceInCents: 420000),
      ]);
    });
  }

  Future<void> _seedDemoAuditLogs() async {
    final now = DateTime.now();
    await batch((b) {
      b.insertAll(auditLogs, [
        AuditLogsCompanion.insert(
          userId: 'admin1', userName: 'Administrador',
          action: 'login', targetType: 'user',
          targetId: 'admin1', targetName: 'Administrador',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        AuditLogsCompanion.insert(
          userId: 'admin1', userName: 'Administrador',
          action: 'create', targetType: 'product',
          targetId: 'chai', targetName: 'Chai Latte',
          details: const Value('\$4.000'),
          createdAt: now.subtract(const Duration(hours: 1, minutes: 50)),
        ),
        AuditLogsCompanion.insert(
          userId: 'admin1', userName: 'Administrador',
          action: 'create', targetType: 'promo',
          targetId: 'promo4', targetName: 'Nuevo: Chai Latte',
          details: const Value('20% OFF'),
          createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        ),
        AuditLogsCompanion.insert(
          userId: 'system', userName: 'Sistema',
          action: 'sale', targetType: 'order',
          targetId: 'demo_ord1', targetName: 'Pedido #1',
          details: const Value('\$7.300 - cash - 2 items'),
          createdAt: now.subtract(const Duration(minutes: 12)),
        ),
        AuditLogsCompanion.insert(
          userId: 'system', userName: 'Sistema',
          action: 'sale', targetType: 'order',
          targetId: 'demo_ord2', targetName: 'Pedido #2',
          details: const Value('\$5.500 - card - 1 items'),
          createdAt: now.subtract(const Duration(minutes: 8)),
        ),
        AuditLogsCompanion.insert(
          userId: 'system', userName: 'Sistema',
          action: 'sale', targetType: 'order',
          targetId: 'demo_ord3', targetName: 'Pedido #3',
          details: const Value('\$3.500 - cash - 1 items'),
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
        AuditLogsCompanion.insert(
          userId: 'worker1', userName: 'Cocina 1',
          action: 'login', targetType: 'user',
          targetId: 'worker1', targetName: 'Cocina 1',
          createdAt: now.subtract(const Duration(minutes: 15)),
        ),
      ]);
    });
  }
}
