import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/domain/entities/promo.dart';

void main() {
  group('Promo', () {
    test('isPercentDiscount when discountPercent > 0', () {
      const promo = Promo(id: '1', title: 'Test', discountPercent: 20);
      expect(promo.isPercentDiscount, true);
      expect(promo.isAmountDiscount, false);
    });

    test('isAmountDiscount when discountAmountCents > 0', () {
      const promo = Promo(id: '1', title: 'Test', discountAmountCents: 50000);
      expect(promo.isAmountDiscount, true);
      expect(promo.isPercentDiscount, false);
    });

    test('calculateDiscount with percent', () {
      const promo = Promo(id: '1', title: 'Test', discountPercent: 20);
      expect(promo.calculateDiscount(100000), 20000); // 20% of 1000 CLP
    });

    test('calculateDiscount with fixed amount', () {
      const promo = Promo(id: '1', title: 'Test', discountAmountCents: 50000);
      expect(promo.calculateDiscount(100000), 50000);
    });

    test('calculateDiscount caps at price', () {
      const promo = Promo(id: '1', title: 'Test', discountAmountCents: 200000);
      expect(promo.calculateDiscount(100000), 100000);
    });

    test('isCurrentlyActive checks dates', () {
      final active = Promo(
        id: '1',
        title: 'Test',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(active.isCurrentlyActive, true);

      final expired = Promo(
        id: '2',
        title: 'Test',
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expired.isCurrentlyActive, false);

      final future = Promo(
        id: '3',
        title: 'Test',
        startDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(future.isCurrentlyActive, false);

      const inactive = Promo(id: '4', title: 'Test', active: false);
      expect(inactive.isCurrentlyActive, false);
    });

    test('equality is based on id', () {
      const a = Promo(id: '1', title: 'A');
      const b = Promo(id: '1', title: 'B');
      expect(a, equals(b));
    });
  });
}
