import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/data/repositories/product_repository_impl.dart';
import 'package:kiosko_v2/data/repositories/cart_repository_impl.dart';
import 'package:kiosko_v2/data/repositories/order_repository_impl.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/usecases/place_order.dart';

/// Integration test: complete order flow using real DB
void main() {
  group('Complete order flow', () {
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

    test('browse products, add to cart, place order', () async {
      // 1. Browse categories
      final categories = await productRepo.getAllCategories();
      expect(categories.isNotEmpty, true);

      // 2. Browse products by category
      final cafeProducts =
          await productRepo.getProductsByCategory('cafe');
      expect(cafeProducts.isNotEmpty, true);

      // 3. Add products to cart
      final cappuccino = cafeProducts.firstWhere((p) => p.name == 'Cappuccino');
      cartRepo.addToCart(cappuccino);
      cartRepo.addToCart(cappuccino); // qty = 2

      final latte = cafeProducts.firstWhere((p) => p.name == 'Latte');
      cartRepo.addToCart(latte);

      // 4. Verify cart
      final cart = cartRepo.getCart();
      expect(cart.items.length, 2);
      expect(cart.totalItems, 3);
      // 2 * 350000 + 1 * 380000 = 1080000
      expect(cart.totalInCents, 1080000);

      // 5. Place order
      final placeOrder = PlaceOrder(orderRepo, cartRepo);
      final order = await placeOrder(PaymentMethod.cash);

      expect(order.status, OrderStatus.pending);
      expect(order.totalInCents, 1080000);
      expect(order.queueNumber, 1);
      expect(order.items.length, 2);

      // 6. Cart should be empty after ordering
      expect(cartRepo.getCart().isEmpty, true);

      // 7. Order should be persisted in DB
      final retrieved = await orderRepo.getOrderById(order.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.totalInCents, 1080000);
      expect(retrieved.items.length, 2);
    });

    test('search products', () async {
      final results = await productRepo.searchProducts('Latte');
      expect(results.length, 1);
      expect(results.first.name, 'Latte');
    });

    test('cart management operations', () async {
      final products = await productRepo.getAllProducts();
      final product = products.first;

      // Add
      cartRepo.addToCart(product);
      expect(cartRepo.getCart().totalItems, 1);

      // Increment
      cartRepo.incrementItem(product.id);
      expect(cartRepo.getCart().quantityOf(product.id), 2);

      // Decrement
      cartRepo.decrementItem(product.id);
      expect(cartRepo.getCart().quantityOf(product.id), 1);

      // Remove
      cartRepo.removeFromCart(product.id);
      expect(cartRepo.getCart().isEmpty, true);
    });

    test('multiple orders get sequential queue numbers', () async {
      final products = await productRepo.getAllProducts();

      // Order 1
      cartRepo.addToCart(products.first);
      final placeOrder = PlaceOrder(orderRepo, cartRepo);
      final order1 = await placeOrder(PaymentMethod.cash);

      // Order 2 - small delay to ensure unique ID
      await Future.delayed(const Duration(milliseconds: 1));
      cartRepo.addToCart(products[1]);
      final order2 = await placeOrder(PaymentMethod.card);

      expect(order1.queueNumber, 1);
      expect(order2.queueNumber, 2);

      // All orders persist
      final allOrders = await orderRepo.getAllOrders();
      expect(allOrders.length, 2);
    });

    test('order status can be updated', () async {
      final products = await productRepo.getAllProducts();
      cartRepo.addToCart(products.first);
      final placeOrder = PlaceOrder(orderRepo, cartRepo);
      final order = await placeOrder(PaymentMethod.cash);

      await orderRepo.updateOrderStatus(order.id, OrderStatus.preparing);
      final updated = await orderRepo.getOrderById(order.id);
      expect(updated!.status, OrderStatus.preparing);

      await orderRepo.updateOrderStatus(order.id, OrderStatus.ready);
      final ready = await orderRepo.getOrderById(order.id);
      expect(ready!.status, OrderStatus.ready);
    });
  });
}
