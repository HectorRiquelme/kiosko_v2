import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/presentation/widgets/cart_bottom_bar.dart';

void main() {
  group('CartBottomBar', () {
    final testItems = [
      const CartItem(
        productId: '1',
        name: 'Cappuccino',
        imageUrl: 'https://example.com/cap.png',
        priceInCents: 350000,
        quantity: 2,
      ),
    ];

    testWidgets('displays continue button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartBottomBar(
              items: testItems,
              totalInCents: 700000,
              onContinue: () {},
              onIncrement: (_) {},
              onDecrement: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('displays formatted total price', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartBottomBar(
              items: testItems,
              totalInCents: 700000,
              onContinue: () {},
              onIncrement: (_) {},
              onDecrement: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('\$7.000'), findsOneWidget);
    });

    testWidgets('displays item name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartBottomBar(
              items: testItems,
              totalInCents: 700000,
              onContinue: () {},
              onIncrement: (_) {},
              onDecrement: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Cappuccino'), findsOneWidget);
    });

    testWidgets('calls onContinue when button pressed', (tester) async {
      bool continued = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartBottomBar(
              items: testItems,
              totalInCents: 700000,
              onContinue: () => continued = true,
              onIncrement: (_) {},
              onDecrement: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      expect(continued, isTrue);
    });

    testWidgets('has increment and decrement icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartBottomBar(
              items: testItems,
              totalInCents: 700000,
              onContinue: () {},
              onIncrement: (_) {},
              onDecrement: (_) {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });
  });
}
