import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/screens/home_screen.dart';
import 'package:kiosko_v2/presentation/providers/database_provider.dart';
import 'package:kiosko_v2/data/datasources/app_database.dart';

void main() {
  group('HomeScreen', () {
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
        child: const MaterialApp(home: HomeScreen()),
      );
    }

    testWidgets('shows greeting and question', (tester) async {
      await mockNetworkImagesFor(() async {
        tester.view.physicalSize = const Size(1600, 2400);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Que vas a pedir hoy?'), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('shows category chips with Todos', (tester) async {
      await mockNetworkImagesFor(() async {
        tester.view.physicalSize = const Size(1600, 2400);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Todos'), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('shows hero banner', (tester) async {
      await mockNetworkImagesFor(() async {
        tester.view.physicalSize = const Size(1600, 2400);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Hasta 30% OFF'), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
