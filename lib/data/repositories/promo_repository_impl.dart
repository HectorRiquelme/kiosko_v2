import 'package:drift/drift.dart';
import '../../domain/entities/promo.dart' as domain;
import '../../domain/repositories/promo_repository.dart';
import '../datasources/app_database.dart';

class PromoRepositoryImpl implements PromoRepository {
  final AppDatabase _db;

  PromoRepositoryImpl(this._db);

  @override
  Future<List<domain.Promo>> getAllPromos() async {
    final rows = await _db.select(_db.promos).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<domain.Promo>> getActivePromos() async {
    final rows = await (_db.select(_db.promos)
          ..where((p) => p.active.equals(true)))
        .get();
    return rows.map(_toEntity).where((p) => p.isCurrentlyActive).toList();
  }

  @override
  Future<domain.Promo?> getPromoById(String id) async {
    final row = await (_db.select(_db.promos)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> insertPromo(domain.Promo promo) async {
    await _db.into(_db.promos).insert(_toCompanion(promo));
  }

  @override
  Future<void> updatePromo(domain.Promo promo) async {
    await (_db.update(_db.promos)..where((p) => p.id.equals(promo.id)))
        .write(_toCompanion(promo));
  }

  @override
  Future<void> deletePromo(String id) async {
    await (_db.delete(_db.promos)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<void> togglePromoActive(String id, bool active) async {
    await (_db.update(_db.promos)..where((p) => p.id.equals(id)))
        .write(PromosCompanion(active: Value(active)));
  }

  domain.Promo _toEntity(Promo row) {
    return domain.Promo(
      id: row.id,
      title: row.title,
      subtitle: row.subtitle,
      imageUrl: row.imageUrl,
      backgroundColor: row.backgroundColor,
      discountPercent: row.discountPercent,
      discountAmountCents: row.discountAmountCents,
      productIds: row.productIds.isEmpty
          ? []
          : row.productIds.split(','),
      startDate: row.startDate,
      endDate: row.endDate,
      active: row.active,
    );
  }

  PromosCompanion _toCompanion(domain.Promo promo) {
    return PromosCompanion(
      id: Value(promo.id),
      title: Value(promo.title),
      subtitle: Value(promo.subtitle),
      imageUrl: Value(promo.imageUrl),
      backgroundColor: Value(promo.backgroundColor),
      discountPercent: Value(promo.discountPercent),
      discountAmountCents: Value(promo.discountAmountCents),
      productIds: Value(promo.productIds.join(',')),
      startDate: Value(promo.startDate),
      endDate: Value(promo.endDate),
      active: Value(promo.active),
    );
  }
}
