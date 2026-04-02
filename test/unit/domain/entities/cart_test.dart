import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/domain/entities/product.dart';
import 'package:kiosko_v2/domain/entities/cart_item.dart';
import 'package:kiosko_v2/domain/entities/cart.dart';

void main() {
  final product1 = Product(
    id: '1',
    name: 'Cappuccino',
    imageUrl: 'https://placehold.co/100',
    priceInCents: 350000,
    categoryId: 'cafe',
  );

  final product2 = Product(
    id: '2',
    name: 'Latte',
    imageUrl: 'https://placehold.co/100',
    priceInCents: 380000,
    categoryId: 'cafe',
  );

  group('CartItem', () {
    test('totalInCents multiplies price by quantity', () {
      final item = CartItem(product: product1, quantity: 3);
      expect(item.totalInCents, 1050000);
    });

    test('copyWith updates quantity', () {
      final item = CartItem(product: product1, quantity: 1);
      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.product, product1);
    });

    test('equality is based on product', () {
      final a = CartItem(product: product1, quantity: 1);
      final b = CartItem(product: product1, quantity: 3);
      expect(a, equals(b));
    });
  });

  group('Cart', () {
    test('empty cart has zero total', () {
      const cart = Cart();
      expect(cart.totalInCents, 0);
      expect(cart.totalItems, 0);
      expect(cart.isEmpty, true);
    });

    test('totalInCents sums all items', () {
      final cart = Cart(items: [
        CartItem(product: product1, quantity: 2), // 700000
        CartItem(product: product2, quantity: 1), // 380000
      ]);
      expect(cart.totalInCents, 1080000);
    });

    test('totalItems sums quantities', () {
      final cart = Cart(items: [
        CartItem(product: product1, quantity: 2),
        CartItem(product: product2, quantity: 3),
      ]);
      expect(cart.totalItems, 5);
    });

    test('containsProduct finds existing product', () {
      final cart = Cart(items: [
        CartItem(product: product1, quantity: 1),
      ]);
      expect(cart.containsProduct('1'), true);
      expect(cart.containsProduct('99'), false);
    });

    test('quantityOf returns correct amount', () {
      final cart = Cart(items: [
        CartItem(product: product1, quantity: 3),
      ]);
      expect(cart.quantityOf('1'), 3);
      expect(cart.quantityOf('99'), 0);
    });
  });

  group('Product', () {
    test('equality is based on id', () {
      final a = Product(
        id: '1', name: 'A', imageUrl: '', priceInCents: 100, categoryId: 'c');
      final b = Product(
        id: '1', name: 'B', imageUrl: '', priceInCents: 200, categoryId: 'd');
      expect(a, equals(b));
    });
  });
}
