import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:kiosko_v2/presentation/screens/payment_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/presentation/providers/cart_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/entities/product.dart' as domain;

void main() {
  group('PaymentScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('shows cash payment label', (tester) async {
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
          child: const MaterialApp(
            home: PaymentScreen(paymentMethod: PaymentMethod.cash),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pagar con Efectivo'), findsOneWidget);
      expect(find.text('Confirmar pago'), findsOneWidget);
    });

    testWidgets('shows card payment label', (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PaymentScreen(paymentMethod: PaymentMethod.card),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pagar con Tarjeta'), findsOneWidget);
    });

    testWidgets('shows transfer payment label', (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PaymentScreen(paymentMethod: PaymentMethod.transfer),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pagar con Transferencia'), findsOneWidget);
    });
  });
}
