import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/domain/entities/product.dart';
import 'package:kiosko_v2/domain/entities/cart_item.dart';
import 'package:kiosko_v2/domain/entities/cart.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/repositories/cart_repository.dart';
import 'package:kiosko_v2/domain/repositories/order_repository.dart';
import 'package:kiosko_v2/domain/usecases/place_order.dart';
import 'package:kiosko_v2/domain/usecases/add_to_cart.dart';
import 'package:kiosko_v2/domain/usecases/remove_from_cart.dart';
import 'package:kiosko_v2/domain/usecases/calculate_total.dart';

// Simple in-memory implementations for testing
class InMemoryCartRepository implements CartRepository {
  Cart _cart = const Cart();

  @override
  Cart getCart() => _cart;

  @override
  Cart addToCart(Product product) {
    final existing = _cart.items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      final items = List<CartItem>.from(_cart.items);
      items[existing] = items[existing].copyWith(
        quantity: items[existing].quantity + 1,
      );
      _cart = _cart.copyWith(items: items);
    } else {
      _cart = _cart.copyWith(
        items: [..._cart.items, CartItem(product: product, quantity: 1)],
      );
    }
    return _cart;
  }

  @override
  Cart removeFromCart(String productId) {
    _cart = _cart.copyWith(
      items: _cart.items.where((i) => i.product.id != productId).toList(),
    );
    return _cart;
  }

  @override
  Cart incrementItem(String productId) {
    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
      _cart = _cart.copyWith(items: items);
    }
    return _cart;
  }

  @override
  Cart decrementItem(String productId) {
    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (items[idx].quantity <= 1) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: items[idx].quantity - 1);
      }
      _cart = _cart.copyWith(items: items);
    }
    return _cart;
  }

  @override
  Cart clearCart() {
    _cart = const Cart();
    return _cart;
  }
}

class InMemoryOrderRepository implements OrderRepository {
  final List<Order> _orders = [];
  int _queueCounter = 0;

  @override
  Future<Order> placeOrder(Order order) async {
    _orders.add(order);
    return order;
  }

  @override
  Future<List<Order>> getAllOrders() async => List.unmodifiable(_orders);

  @override
  Future<Order?> getOrderById(String id) async {
    final matches = _orders.where((o) => o.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<int> getNextQueueNumber() async => ++_queueCounter;

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(status: status);
    }
  }
}

void main() {
  final product = Product(
    id: '1',
    name: 'Cappuccino',
    imageUrl: 'https://placehold.co/100',
    priceInCents: 350000,
    categoryId: 'cafe',
  );

  group('AddToCart', () {
    test('adds product to cart', () {
      final repo = InMemoryCartRepository();
      final addToCart = AddToCart(repo);
      final cart = addToCart(product);
      expect(cart.items.length, 1);
      expect(cart.items.first.product, product);
      expect(cart.items.first.quantity, 1);
    });

    test('increments quantity for existing product', () {
      final repo = InMemoryCartRepository();
      final addToCart = AddToCart(repo);
      addToCart(product);
      final cart = addToCart(product);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
    });
  });

  group('RemoveFromCart', () {
    test('removes product from cart', () {
      final repo = InMemoryCartRepository();
      repo.addToCart(product);
      final removeFromCart = RemoveFromCart(repo);
      final cart = removeFromCart(product.id);
      expect(cart.isEmpty, true);
    });
  });

  group('CalculateTotal', () {
    test('returns total of cart', () {
      final repo = InMemoryCartRepository();
      repo.addToCart(product);
      repo.addToCart(product);
      final calculateTotal = CalculateTotal(repo);
      expect(calculateTotal(), 700000);
    });
  });

  group('PlaceOrder', () {
    test('places order and clears cart', () async {
      final cartRepo = InMemoryCartRepository();
      final orderRepo = InMemoryOrderRepository();
      cartRepo.addToCart(product);

      final placeOrder = PlaceOrder(orderRepo, cartRepo);
      final order = await placeOrder(PaymentMethod.cash);

      expect(order.status, OrderStatus.pending);
      expect(order.totalInCents, 350000);
      expect(order.queueNumber, 1);
      expect(cartRepo.getCart().isEmpty, true);
    });

    test('throws on empty cart', () async {
      final cartRepo = InMemoryCartRepository();
      final orderRepo = InMemoryOrderRepository();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      expect(() => placeOrder(PaymentMethod.cash), throwsStateError);
    });

    test('queue numbers increment', () async {
      final cartRepo = InMemoryCartRepository();
      final orderRepo = InMemoryOrderRepository();
      final placeOrder = PlaceOrder(orderRepo, cartRepo);

      cartRepo.addToCart(product);
      final order1 = await placeOrder(PaymentMethod.cash);

      cartRepo.addToCart(product);
      final order2 = await placeOrder(PaymentMethod.card);

      expect(order1.queueNumber, 1);
      expect(order2.queueNumber, 2);
    });
  });
}
