import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/screens/category_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';
import 'package:kiosko_v2/domain/entities/category.dart' as domain;

void main() {
  group('CategoryScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('shows category name in app bar', (tester) async {
      await mockNetworkImagesFor(() async {
        final category = domain.Category(
          id: 'cafe',
          name: 'Cafe',
          imageUrl: 'https://placehold.co/100',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: MaterialApp(
              home: CategoryScreen(category: category),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Cafe'), findsOneWidget);
      });
    });

    testWidgets('shows empty message for unknown category', (tester) async {
      await mockNetworkImagesFor(() async {
        final category = domain.Category(
          id: 'nonexistent',
          name: 'Desconocido',
          imageUrl: 'https://placehold.co/100',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: MaterialApp(
              home: CategoryScreen(category: category),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('No hay productos en esta categoria'),
            findsOneWidget);
      });
    });
  });
}
