import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/data/repositories/product_repository_impl.dart';
import 'package:kiosko_v2/domain/entities/product.dart' as domain;
import 'package:kiosko_v2/domain/entities/category.dart' as domain;

void main() {
  late AppDatabase db;
  late ProductRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProductRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProductRepositoryImpl', () {
    test('getAllCategories returns seeded categories', () async {
      final categories = await repo.getAllCategories();
      expect(categories.length, 5);
      expect(categories.first.name, 'Cafe');
    });

    test('getAllProducts returns seeded products', () async {
      final products = await repo.getAllProducts();
      expect(products.length, 19);
    });

    test('getProductsByCategory filters correctly', () async {
      final cafeProducts = await repo.getProductsByCategory('cafe');
      expect(cafeProducts.length, 6);
      for (final p in cafeProducts) {
        expect(p.categoryId, 'cafe');
      }
    });

    test('searchProducts finds by name', () async {
      final results = await repo.searchProducts('Cappuccino');
      expect(results.length, 1);
      expect(results.first.name, 'Cappuccino');
    });

    test('getProductById returns correct product', () async {
      final product = await repo.getProductById('cap');
      expect(product, isNotNull);
      expect(product!.name, 'Cappuccino');
    });

    test('getProductById returns null for missing', () async {
      final product = await repo.getProductById('nonexistent');
      expect(product, isNull);
    });

    test('insertProduct adds new product', () async {
      await repo.insertProduct(domain.Product(
        id: 'new1',
        name: 'Nuevo Cafe',
        imageUrl: 'https://placehold.co/100',
        priceInCents: 500000,
        categoryId: 'cafe',
      ));
      final product = await repo.getProductById('new1');
      expect(product, isNotNull);
      expect(product!.name, 'Nuevo Cafe');
    });

    test('insertCategory adds new category', () async {
      await repo.insertCategory(domain.Category(
        id: 'new_cat',
        name: 'Nuevo',
        imageUrl: 'https://placehold.co/100',
        sortOrder: 10,
      ));
      final categories = await repo.getAllCategories();
      expect(categories.any((c) => c.id == 'new_cat'), true);
    });
  });
}
