import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:kiosko_v2/presentation/screens/login_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';

void main() {
  group('LoginScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: LoginScreen()),
      );
    }

    testWidgets('shows branding', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.text('KIOSKO'), findsOneWidget);
    });

    testWidgets('shows numpad buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        expect(find.text(digit), findsOneWidget);
      }
    });

    testWidgets('shows mode buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.text('Ordenar'), findsOneWidget);
      expect(find.text('Pedidos'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);
    });

    testWidgets('shows error on wrong PIN', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('9'));
      await tester.pump();
      await tester.tap(find.text('9'));
      await tester.pump();
      await tester.tap(find.text('9'));
      await tester.pump();
      await tester.tap(find.text('9'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('PIN incorrecto'), findsOneWidget);
    });
  });
}
