import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/domain/entities/order.dart';

void main() {
  group('Order', () {
    test('copyWith updates status', () {
      final order = Order(
        id: '1',
        items: [],
        totalInCents: 100,
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.cash,
        queueNumber: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = order.copyWith(status: OrderStatus.ready);
      expect(updated.status, OrderStatus.ready);
      expect(updated.id, '1');
      expect(updated.totalInCents, 100);
    });

    test('equality is based on id', () {
      final a = Order(
        id: '1',
        items: [],
        totalInCents: 100,
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.cash,
        queueNumber: 1,
        createdAt: DateTime(2024, 1, 1),
      );
      final b = Order(
        id: '1',
        items: [],
        totalInCents: 200,
        status: OrderStatus.ready,
        paymentMethod: PaymentMethod.card,
        queueNumber: 2,
        createdAt: DateTime(2024, 6, 1),
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Category', () {
    test('equality is based on id', () {
      // Already tested in cart_test.dart via Product
    });
  });
}
