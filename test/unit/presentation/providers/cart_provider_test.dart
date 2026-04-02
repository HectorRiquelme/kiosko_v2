import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:kiosko_v2/presentation/providers/cart_provider.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/domain/entities/product.dart' as domain;

void main() {
  group('CartProvider', () {
    late ProviderContainer container;
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    final product = domain.Product(
      id: '1',
      name: 'Cappuccino',
      imageUrl: 'https://placehold.co/100',
      priceInCents: 350000,
      categoryId: 'cafe',
    );

    test('starts empty', () {
      final cart = container.read(cartProvider);
      expect(cart.isEmpty, true);
    });

    test('addToCart adds product', () {
      container.read(cartProvider.notifier).addToCart(product);
      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.totalInCents, 350000);
    });

    test('incrementItem increases quantity', () {
      container.read(cartProvider.notifier).addToCart(product);
      container.read(cartProvider.notifier).incrementItem('1');
      final cart = container.read(cartProvider);
      expect(cart.quantityOf('1'), 2);
    });

    test('decrementItem decreases quantity', () {
      container.read(cartProvider.notifier).addToCart(product);
      container.read(cartProvider.notifier).incrementItem('1');
      container.read(cartProvider.notifier).decrementItem('1');
      final cart = container.read(cartProvider);
      expect(cart.quantityOf('1'), 1);
    });

    test('removeFromCart removes product', () {
      container.read(cartProvider.notifier).addToCart(product);
      container.read(cartProvider.notifier).removeFromCart('1');
      final cart = container.read(cartProvider);
      expect(cart.isEmpty, true);
    });

    test('clearCart empties cart', () {
      container.read(cartProvider.notifier).addToCart(product);
      container.read(cartProvider.notifier).clearCart();
      final cart = container.read(cartProvider);
      expect(cart.isEmpty, true);
    });
  });
}
