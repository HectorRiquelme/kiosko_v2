import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/data/repositories/product_repository_impl.dart';
import 'package:kiosko_v2/data/repositories/cart_repository_impl.dart';
import 'package:kiosko_v2/data/repositories/order_repository_impl.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/usecases/place_order.dart';

void main() {
  group('Queue system', () {
    late AppDatabase db;
    late ProductRepositoryImpl productRepo;
    late CartRepositoryImpl cartRepo;
    late OrderRepositoryImpl orderRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      productRepo = ProductRepositoryImpl(db);
      cartRepo = CartRepositoryImpl();
      orderRepo = OrderRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('queue numbers are sequential starting at 1', () async {
      final products = await productRepo.getAllProducts();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      // Place 3 orders
      for (int i = 1; i <= 3; i++) {
        cartRepo.addToCart(products.first);
        await Future.delayed(const Duration(milliseconds: 1));
        final order = await placeOrder(PaymentMethod.cash);
        expect(order.queueNumber, i);
      }
    });

    test('all orders persist with correct status', () async {
      final products = await productRepo.getAllProducts();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      cartRepo.addToCart(products.first);
      final order = await placeOrder(PaymentMethod.cash);
      expect(order.status, OrderStatus.pending);

      // Retrieve and verify
      final retrieved = await orderRepo.getOrderById(order.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.status, OrderStatus.pending);
      expect(retrieved.queueNumber, order.queueNumber);
    });

    test('order status progression: pending -> preparing -> ready -> delivered',
        () async {
      final products = await productRepo.getAllProducts();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      cartRepo.addToCart(products.first);
      final order = await placeOrder(PaymentMethod.cash);

      // Pending -> Preparing
      await orderRepo.updateOrderStatus(order.id, OrderStatus.preparing);
      var updated = await orderRepo.getOrderById(order.id);
      expect(updated!.status, OrderStatus.preparing);

      // Preparing -> Ready
      await orderRepo.updateOrderStatus(order.id, OrderStatus.ready);
      updated = await orderRepo.getOrderById(order.id);
      expect(updated!.status, OrderStatus.ready);

      // Ready -> Delivered
      await orderRepo.updateOrderStatus(order.id, OrderStatus.delivered);
      updated = await orderRepo.getOrderById(order.id);
      expect(updated!.status, OrderStatus.delivered);
    });

    test('kitchen sees only active orders (pending, preparing, ready)',
        () async {
      final products = await productRepo.getAllProducts();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      // Create 4 orders
      for (int i = 0; i < 4; i++) {
        cartRepo.addToCart(products[i % products.length]);
        await Future.delayed(const Duration(milliseconds: 1));
        await placeOrder(PaymentMethod.cash);
      }

      final allOrders = await orderRepo.getAllOrders();
      expect(allOrders.length, 4);

      // Mark one as delivered
      await orderRepo.updateOrderStatus(
          allOrders.first.id, OrderStatus.delivered);

      // Filter like kitchen screen does
      final refreshed = await orderRepo.getAllOrders();
      final active = refreshed
          .where((o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.preparing ||
              o.status == OrderStatus.ready)
          .toList();
      expect(active.length, 3);
    });

    test('cash order has correct payment method', () async {
      final products = await productRepo.getAllProducts();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      cartRepo.addToCart(products.first);
      final cashOrder = await placeOrder(PaymentMethod.cash);
      expect(cashOrder.paymentMethod, PaymentMethod.cash);

      cartRepo.addToCart(products.first);
      await Future.delayed(const Duration(milliseconds: 1));
      final cardOrder = await placeOrder(PaymentMethod.card);
      expect(cardOrder.paymentMethod, PaymentMethod.card);
    });

    test('order items are preserved after retrieval', () async {
      final products = await productRepo.getAllProducts();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      // Add 2 different products
      cartRepo.addToCart(products[0]);
      cartRepo.addToCart(products[0]); // qty 2
      cartRepo.addToCart(products[1]); // qty 1

      final order = await placeOrder(PaymentMethod.cash);

      // Retrieve from DB
      final retrieved = await orderRepo.getOrderById(order.id);
      expect(retrieved!.items.length, 2);
      expect(retrieved.items.first.quantity, 2);
      expect(retrieved.items[1].quantity, 1);
    });

    test('cancelled order does not affect queue', () async {
      final products = await productRepo.getAllProducts();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      cartRepo.addToCart(products.first);
      final order1 = await placeOrder(PaymentMethod.cash);

      cartRepo.addToCart(products.first);
      await Future.delayed(const Duration(milliseconds: 1));
      final order2 = await placeOrder(PaymentMethod.cash);

      // Cancel order 1
      await orderRepo.updateOrderStatus(order1.id, OrderStatus.cancelled);

      // Order 3 should get next number
      cartRepo.addToCart(products.first);
      await Future.delayed(const Duration(milliseconds: 1));
      final order3 = await placeOrder(PaymentMethod.cash);

      expect(order1.queueNumber, 1);
      expect(order2.queueNumber, 2);
      expect(order3.queueNumber, 3);
    });
  });
}
