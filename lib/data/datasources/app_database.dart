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

@DriftDatabase(tables: [Users, Categories, Products, Promos, Orders, OrderItems, AuditLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

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

  Future<void> _seedData() async {
    await _seedUsers();
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
        ProductsCompanion.insert(
            id: 'cap', name: 'Cappuccino', imageUrl: 'asset:assets/products/cappuccino.png',
            priceInCents: 350000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'lat', name: 'Latte', imageUrl: 'asset:assets/products/latte.png',
            priceInCents: 380000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'ame', name: 'Americano', imageUrl: 'asset:assets/products/americano.png',
            priceInCents: 280000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'moc', name: 'Mocha', imageUrl: 'asset:assets/products/mocha.png',
            priceInCents: 420000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'esp', name: 'Espresso', imageUrl: 'asset:assets/products/espresso.png',
            priceInCents: 250000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'fla', name: 'Flat White', imageUrl: 'asset:assets/products/flat_white.png',
            priceInCents: 390000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'jug', name: 'Jugo Natural', imageUrl: 'asset:assets/products/jugo_natural.png',
            priceInCents: 320000, categoryId: 'bebidas'),
        ProductsCompanion.insert(
            id: 'lim', name: 'Limonada', imageUrl: 'asset:assets/products/limonada.png',
            priceInCents: 280000, categoryId: 'bebidas'),
        ProductsCompanion.insert(
            id: 'tor', name: 'Torta Chocolate', imageUrl: 'asset:assets/products/torta_chocolate.png',
            priceInCents: 450000, categoryId: 'pasteles'),
        ProductsCompanion.insert(
            id: 'cro', name: 'Croissant', imageUrl: 'asset:assets/products/croissant.png',
            priceInCents: 280000, categoryId: 'snacks'),
        ProductsCompanion.insert(
            id: 'com1', name: 'Combo Cafe + Torta', imageUrl: 'asset:assets/products/combo.png',
            priceInCents: 650000, categoryId: 'combos'),
      ]);
    });
  }
}
