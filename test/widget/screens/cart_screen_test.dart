import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/screens/cart_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/presentation/providers/cart_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/domain/entities/product.dart' as domain;

void main() {
  group('CartScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('shows empty cart message', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: const MaterialApp(home: CartScreen()),
          ),
        );
        await tester.pump();
        expect(find.text('Tu carrito esta vacio'), findsOneWidget);
      });
    });

    testWidgets('shows cart items when populated', (tester) async {
      await mockNetworkImagesFor(() async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        // Add a product to cart
        container.read(cartProvider.notifier).addToCart(
              domain.Product(
                id: 'cap',
                name: 'Cappuccino',
                imageUrl: 'https://placehold.co/100',
                priceInCents: 350000,
                categoryId: 'cafe',
              ),
            );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: CartScreen()),
          ),
        );
        await tester.pump();

        expect(find.text('Cappuccino'), findsOneWidget);
        expect(find.text('Pagar'), findsOneWidget);
      });
    });

    testWidgets('shows total price', (tester) async {
      await mockNetworkImagesFor(() async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        container.read(cartProvider.notifier).addToCart(
              domain.Product(
                id: 'cap',
                name: 'Cappuccino',
                imageUrl: 'https://placehold.co/100',
                priceInCents: 350000,
                categoryId: 'cafe',
              ),
            );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: CartScreen()),
          ),
        );
        await tester.pump();

        expect(find.text('\$3.500'), findsWidgets);
      });
    });
  });
}
