import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart' hide Order;
import 'package:kiosko_v2/data/repositories/order_repository_impl.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/entities/product.dart' as domain;
import 'package:kiosko_v2/domain/entities/cart_item.dart';

void main() {
  late AppDatabase db;
  late OrderRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = OrderRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  final testProduct = domain.Product(
    id: 'cap',
    name: 'Cappuccino',
    imageUrl: 'https://placehold.co/100',
    priceInCents: 350000,
    categoryId: 'cafe',
  );

  int orderCounter = 0;
  Order createTestOrder({int queueNumber = 1}) {
    orderCounter++;
    return Order(
      id: 'order_${orderCounter}_${DateTime.now().microsecondsSinceEpoch}',
      items: [CartItem(product: testProduct, quantity: 2)],
      totalInCents: 700000,
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.cash,
      queueNumber: queueNumber,
      createdAt: DateTime.now(),
    );
  }

  group('OrderRepositoryImpl', () {
    test('placeOrder saves to database', () async {
      final order = createTestOrder();
      final result = await repo.placeOrder(order);
      expect(result.id, order.id);

      final retrieved = await repo.getOrderById(order.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.totalInCents, 700000);
    });

    test('getAllOrders returns all', () async {
      await repo.placeOrder(createTestOrder(queueNumber: 1));
      await Future.delayed(const Duration(milliseconds: 10));
      await repo.placeOrder(createTestOrder(queueNumber: 2));

      final orders = await repo.getAllOrders();
      expect(orders.length, 2);
    });

    test('getNextQueueNumber increments', () async {
      final n1 = await repo.getNextQueueNumber();
      expect(n1, 1);

      await repo.placeOrder(createTestOrder(queueNumber: 1));
      final n2 = await repo.getNextQueueNumber();
      expect(n2, 2);
    });

    test('updateOrderStatus changes status', () async {
      final order = createTestOrder();
      await repo.placeOrder(order);

      await repo.updateOrderStatus(order.id, OrderStatus.preparing);
      final updated = await repo.getOrderById(order.id);
      expect(updated!.status, OrderStatus.preparing);
    });

    test('getOrderById returns null for non-existent', () async {
      final result = await repo.getOrderById('nonexistent');
      expect(result, isNull);
    });
  });
}
