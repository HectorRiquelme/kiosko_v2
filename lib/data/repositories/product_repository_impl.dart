import 'package:drift/drift.dart';
import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/product_repository.dart';
import '../datasources/app_database.dart';
import '../models/db_mappers.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  @override
  Future<List<domain.Product>> getAllProducts() async {
    final rows = await (_db.select(_db.products)
          ..where((p) => p.available.equals(true)))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<domain.Product>> getProductsByCategory(String categoryId) async {
    final rows = await (_db.select(_db.products)
          ..where(
              (p) => p.categoryId.equals(categoryId) & p.available.equals(true)))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<domain.Product>> searchProducts(String query) async {
    // Escape special LIKE characters to prevent injection
    final escaped = query
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final rows = await (_db.select(_db.products)
          ..where((p) =>
              p.name.like('%$escaped%') & p.available.equals(true)))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<domain.Product?> getProductById(String id) async {
    final row = await (_db.select(_db.products)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  @override
  Future<List<domain.Category>> getAllCategories() async {
    final rows = await (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> insertProduct(domain.Product product) async {
    await _db.into(_db.products).insertOnConflictUpdate(product.toCompanion());
  }

  @override
  Future<void> updateProduct(domain.Product product) async {
    await (_db.update(_db.products)..where((p) => p.id.equals(product.id)))
        .write(product.toCompanion());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await (_db.delete(_db.products)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<void> toggleProductAvailability(String id, bool available) async {
    await (_db.update(_db.products)..where((p) => p.id.equals(id)))
        .write(ProductsCompanion(available: Value(available)));
  }

  @override
  Future<void> insertCategory(domain.Category category) async {
    await _db
        .into(_db.categories)
        .insertOnConflictUpdate(category.toCompanion());
  }

  @override
  Future<void> updateCategory(domain.Category category) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id)))
        .write(category.toCompanion());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }
}
