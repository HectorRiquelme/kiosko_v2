import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get pin => text()();
  TextColumn get role => text()(); // 'admin' or 'worker'

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
  TextColumn get productIds => text().withDefault(const Constant(''))(); // comma-separated
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

@DriftDatabase(tables: [Users, Categories, Products, Promos, Orders, OrderItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

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
      },
    );
  }

  Future<void> _seedUsers() async {
    await batch((b) {
      b.insertAll(users, [
        UsersCompanion.insert(
          id: 'admin1',
          name: 'Administrador',
          pin: '1234',
          role: 'admin',
        ),
        UsersCompanion.insert(
          id: 'worker1',
          name: 'Cocina 1',
          pin: '0000',
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
            id: 'cafe', name: 'Cafe', imageUrl: 'https://placehold.co/100'),
        CategoriesCompanion.insert(
            id: 'bebidas',
            name: 'Bebidas',
            imageUrl: 'https://placehold.co/100',
            sortOrder: const Value(1)),
        CategoriesCompanion.insert(
            id: 'pasteles',
            name: 'Pasteles',
            imageUrl: 'https://placehold.co/100',
            sortOrder: const Value(2)),
        CategoriesCompanion.insert(
            id: 'snacks',
            name: 'Snacks',
            imageUrl: 'https://placehold.co/100',
            sortOrder: const Value(3)),
        CategoriesCompanion.insert(
            id: 'combos',
            name: 'Combos',
            imageUrl: 'https://placehold.co/100',
            sortOrder: const Value(4)),
      ]);

      b.insertAll(products, [
        ProductsCompanion.insert(
            id: 'cap', name: 'Cappuccino', imageUrl: 'https://placehold.co/150',
            priceInCents: 350000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'lat', name: 'Latte', imageUrl: 'https://placehold.co/150',
            priceInCents: 380000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'ame', name: 'Americano', imageUrl: 'https://placehold.co/150',
            priceInCents: 280000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'moc', name: 'Mocha', imageUrl: 'https://placehold.co/150',
            priceInCents: 420000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'esp', name: 'Espresso', imageUrl: 'https://placehold.co/150',
            priceInCents: 250000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'fla', name: 'Flat White', imageUrl: 'https://placehold.co/150',
            priceInCents: 390000, categoryId: 'cafe'),
        ProductsCompanion.insert(
            id: 'jug', name: 'Jugo Natural', imageUrl: 'https://placehold.co/150',
            priceInCents: 320000, categoryId: 'bebidas'),
        ProductsCompanion.insert(
            id: 'lim', name: 'Limonada', imageUrl: 'https://placehold.co/150',
            priceInCents: 280000, categoryId: 'bebidas'),
        ProductsCompanion.insert(
            id: 'tor', name: 'Torta Chocolate', imageUrl: 'https://placehold.co/150',
            priceInCents: 450000, categoryId: 'pasteles'),
        ProductsCompanion.insert(
            id: 'cro', name: 'Croissant', imageUrl: 'https://placehold.co/150',
            priceInCents: 280000, categoryId: 'snacks'),
        ProductsCompanion.insert(
            id: 'com1', name: 'Combo Cafe + Torta', imageUrl: 'https://placehold.co/150',
            priceInCents: 650000, categoryId: 'combos'),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'kiosko_v2.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
