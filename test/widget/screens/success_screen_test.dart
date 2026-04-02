import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/presentation/screens/success_screen.dart';
import 'package:kiosko_v2/presentation/widgets/cash_ticket.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/entities/product.dart';
import 'package:kiosko_v2/domain/entities/cart_item.dart';

void main() {
  final cashOrder = Order(
    id: '1',
    items: [
      CartItem(
        product: Product(
          id: 'cap', name: 'Cappuccino', imageUrl: '',
          priceInCents: 350000, categoryId: 'cafe',
        ),
        quantity: 1,
      ),
    ],
    totalInCents: 350000,
    status: OrderStatus.pending,
    paymentMethod: PaymentMethod.cash,
    queueNumber: 42,
    createdAt: DateTime(2024, 1, 1),
  );

  final cardOrder = Order(
    id: '2',
    items: [],
    totalInCents: 350000,
    status: OrderStatus.pending,
    paymentMethod: PaymentMethod.card,
    queueNumber: 43,
    createdAt: DateTime(2024, 1, 1),
  );

  group('SuccessScreen', () {
    testWidgets('shows confirmation message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: cardOrder)),
      );
      expect(find.text('Pedido confirmado!'), findsOneWidget);
    });

    testWidgets('shows queue number for card payment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: cardOrder)),
      );
      expect(find.text('#43'), findsOneWidget);
    });

    testWidgets('shows new order button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: cardOrder)),
      );
      expect(find.text('Nuevo pedido'), findsOneWidget);
    });

    testWidgets('shows success icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: cardOrder)),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows CashTicket for cash payment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: cashOrder)),
      );
      expect(find.byType(CashTicket), findsOneWidget);
      expect(find.text('Acercate a caja con este ticket para pagar'),
          findsOneWidget);
    });

    testWidgets('does NOT show CashTicket for card payment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SuccessScreen(order: cardOrder)),
      );
      expect(find.byType(CashTicket), findsNothing);
    });

    testWidgets('shows Transbank info when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SuccessScreen(
            order: cardOrder,
            transbankAuth: 'AUTH123',
            cardLast4: '4242',
          ),
        ),
      );
      expect(find.text('Tarjeta: ****4242'), findsOneWidget);
      expect(find.text('Auth: AUTH123'), findsOneWidget);
    });
  });
}
