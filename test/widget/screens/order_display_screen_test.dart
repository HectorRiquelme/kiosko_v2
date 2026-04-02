import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:kiosko_v2/presentation/screens/order_display_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';

void main() {
  group('OrderDisplayScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('shows header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: OrderDisplayScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Kiosko POS'), findsOneWidget);
      expect(find.text('Estado de pedidos'), findsOneWidget);
    });

    testWidgets('shows order columns with seeded data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: OrderDisplayScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Seeded data has preparing and ready orders
      expect(find.text('Preparando'), findsOneWidget);
      expect(find.text('Listos para retirar'), findsOneWidget);
    });
  });
}
