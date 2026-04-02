import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:kiosko_v2/presentation/screens/kitchen/kitchen_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';

void main() {
  group('KitchenScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('shows column headers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: KitchenScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // With seeded orders, shows column headers
      expect(find.text('Pendientes'), findsOneWidget);
      expect(find.text('Preparando'), findsOneWidget);
      expect(find.text('Listos'), findsOneWidget);
    });

    testWidgets('shows Cocina title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: KitchenScreen()),
        ),
      );
      await tester.pump();
      expect(find.text('Cocina'), findsOneWidget);
    });

    testWidgets('has refresh button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: KitchenScreen()),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('has logout button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: KitchenScreen()),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });
}
