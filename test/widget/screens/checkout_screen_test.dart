import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/screens/checkout_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/presentation/providers/cart_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/domain/entities/product.dart' as domain;

void main() {
  group('CheckoutScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('shows order summary', (tester) async {
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
            child: const MaterialApp(home: CheckoutScreen()),
          ),
        );
        await tester.pump();

        expect(find.text('Productos'), findsOneWidget);
        expect(find.text('1x Cappuccino'), findsOneWidget);
      });
    });

    testWidgets('shows payment method buttons', (tester) async {
      await mockNetworkImagesFor(() async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: CheckoutScreen()),
          ),
        );
        await tester.pump();

        expect(find.text('Efectivo'), findsOneWidget);
        expect(find.text('Tarjeta'), findsOneWidget);
        expect(find.text('Transferencia'), findsOneWidget);
      });
    });
  });
}
