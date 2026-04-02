import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/screens/home_screen.dart';
import 'package:kiosko_v2/presentation/widgets/category_card.dart';
import 'package:kiosko_v2/presentation/widgets/hero_banner.dart';
import 'package:kiosko_v2/presentation/widgets/kiosk_search_bar.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders in portrait layout', (tester) async {
      await mockNetworkImagesFor(() async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(home: HomeScreen()),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(KioskSearchBar), findsOneWidget);
        expect(find.byType(HeroBanner), findsOneWidget);
        expect(find.byType(CategoryCard), findsWidgets);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('shows header with title', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          const MaterialApp(home: HomeScreen()),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Kiosko'), findsOneWidget);
      });
    });

    testWidgets('shows section titles', (tester) async {
      await mockNetworkImagesFor(() async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(home: HomeScreen()),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Categorias'), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
