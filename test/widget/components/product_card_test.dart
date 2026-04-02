import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/widgets/product_card.dart';

void main() {
  group('ProductCard', () {
    testWidgets('formats price correctly in CLP', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                name: 'Latte',
                imageUrl: 'https://example.com/latte.png',
                priceInCents: 350000,
                onAddToCart: () {},
              ),
            ),
          ),
        );
        expect(find.text('\$3.500'), findsOneWidget);
      });
    });

    testWidgets('displays product name', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                name: 'Cappuccino',
                imageUrl: 'https://example.com/cap.png',
                priceInCents: 280000,
                onAddToCart: () {},
              ),
            ),
          ),
        );
        expect(find.text('Cappuccino'), findsOneWidget);
      });
    });

    testWidgets('calls onAddToCart when + button tapped', (tester) async {
      bool added = false;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                name: 'Test',
                imageUrl: 'https://example.com/test.png',
                priceInCents: 100000,
                onAddToCart: () => added = true,
              ),
            ),
          ),
        );
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(added, isTrue);
      });
    });

    testWidgets('shows quantity badge when in cart', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                name: 'Latte',
                imageUrl: 'https://example.com/latte.png',
                priceInCents: 350000,
                onAddToCart: () {},
                isInCart: true,
                quantityInCart: 2,
              ),
            ),
          ),
        );
        expect(find.text('2'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });
  });
}
