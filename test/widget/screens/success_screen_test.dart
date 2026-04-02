import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/presentation/screens/success_screen.dart';
import 'package:kiosko_v2/domain/entities/order.dart';

void main() {
  group('SuccessScreen', () {
    final testOrder = Order(
      id: '1',
      items: [],
      totalInCents: 350000,
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.cash,
      queueNumber: 42,
      createdAt: DateTime(2024, 1, 1),
    );

    testWidgets('shows queue number', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: testOrder)),
      );
      expect(find.text('#42'), findsOneWidget);
    });

    testWidgets('shows confirmation message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: testOrder)),
      );
      expect(find.text('Pedido confirmado!'), findsOneWidget);
    });

    testWidgets('shows new order button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: testOrder)),
      );
      expect(find.text('Nuevo pedido'), findsOneWidget);
    });

    testWidgets('shows success icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: testOrder)),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
