import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart' hide Promo;
import 'package:kiosko_v2/data/repositories/promo_repository_impl.dart';
import 'package:kiosko_v2/domain/entities/promo.dart';

void main() {
  late AppDatabase db;
  late PromoRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PromoRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PromoRepositoryImpl', () {
    test('starts with seeded promos', () async {
      final promos = await repo.getAllPromos();
      expect(promos.length, 4);
    });

    test('insertPromo and getAll', () async {
      final before = await repo.getAllPromos();
      await repo.insertPromo(const Promo(
        id: 'p1',
        title: 'Verano',
        discountPercent: 20,
      ));
      final promos = await repo.getAllPromos();
      expect(promos.length, before.length + 1);
      expect(promos.any((p) => p.title == 'Verano' && p.discountPercent == 20), true);
    });

    test('getActivePromos filters inactive', () async {
      final activeBefore = await repo.getActivePromos();
      await repo.insertPromo(const Promo(
        id: 'p1',
        title: 'Active',
        active: true,
      ));
      await repo.insertPromo(const Promo(
        id: 'p2',
        title: 'Inactive',
        active: false,
      ));
      final active = await repo.getActivePromos();
      expect(active.length, activeBefore.length + 1);
      expect(active.any((p) => p.title == 'Active'), true);
    });

    test('updatePromo modifies promo', () async {
      await repo.insertPromo(const Promo(
        id: 'p1',
        title: 'Original',
        discountPercent: 10,
      ));
      await repo.updatePromo(const Promo(
        id: 'p1',
        title: 'Updated',
        discountPercent: 30,
      ));
      final promo = await repo.getPromoById('p1');
      expect(promo!.title, 'Updated');
      expect(promo.discountPercent, 30);
    });

    test('deletePromo removes promo', () async {
      await repo.insertPromo(const Promo(id: 'p1', title: 'Test'));
      await repo.deletePromo('p1');
      final promo = await repo.getPromoById('p1');
      expect(promo, isNull);
    });

    test('togglePromoActive', () async {
      await repo.insertPromo(const Promo(id: 'p1', title: 'Test'));
      await repo.togglePromoActive('p1', false);
      final promo = await repo.getPromoById('p1');
      expect(promo!.active, false);
    });

    test('handles productIds comma-separated', () async {
      await repo.insertPromo(const Promo(
        id: 'p1',
        title: 'Multi',
        productIds: ['cap', 'lat', 'moc'],
      ));
      final promo = await repo.getPromoById('p1');
      expect(promo!.productIds, ['cap', 'lat', 'moc']);
    });
  });
}
