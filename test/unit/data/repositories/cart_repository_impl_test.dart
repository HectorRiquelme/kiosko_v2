import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/repositories/cart_repository_impl.dart';
import 'package:kiosko_v2/domain/entities/product.dart';

void main() {
  late CartRepositoryImpl repo;

  final product = Product(
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

  setUp(() {
    repo = CartRepositoryImpl();
  });

  test('starts with empty cart', () {
    expect(repo.getCart().isEmpty, true);
  });

  test('addToCart adds new product', () {
    final cart = repo.addToCart(product);
    expect(cart.items.length, 1);
    expect(cart.items.first.quantity, 1);
  });

  test('addToCart increments existing product', () {
    repo.addToCart(product);
    final cart = repo.addToCart(product);
    expect(cart.items.length, 1);
    expect(cart.items.first.quantity, 2);
  });

  test('removeFromCart removes product', () {
    repo.addToCart(product);
    repo.addToCart(product2);
    final cart = repo.removeFromCart('1[]');
    expect(cart.items.length, 1);
    expect(cart.items.first.product.id, '2');
  });

  test('incrementItem increases quantity', () {
    repo.addToCart(product);
    final cart = repo.incrementItem('1[]');
    expect(cart.items.first.quantity, 2);
  });

  test('decrementItem decreases quantity', () {
    repo.addToCart(product);
    repo.incrementItem('1[]');
    final cart = repo.decrementItem('1[]');
    expect(cart.items.first.quantity, 1);
  });

  test('decrementItem removes item at quantity 1', () {
    repo.addToCart(product);
    final cart = repo.decrementItem('1[]');
    expect(cart.isEmpty, true);
  });

  test('clearCart empties cart', () {
    repo.addToCart(product);
    repo.addToCart(product2);
    final cart = repo.clearCart();
    expect(cart.isEmpty, true);
  });
}
