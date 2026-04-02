import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/presentation/widgets/cash_ticket.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/entities/product.dart';
import 'package:kiosko_v2/domain/entities/cart_item.dart';

void main() {
  final testOrder = Order(
    id: '1',
    items: [
      CartItem(
        product: Product(
          id: 'cap',
          name: 'Cappuccino',
          imageUrl: '',
          priceInCents: 350000,
          categoryId: 'cafe',
        ),
        quantity: 2,
      ),
      CartItem(
        product: Product(
          id: 'lat',
          name: 'Latte',
          imageUrl: '',
          priceInCents: 380000,
          categoryId: 'cafe',
        ),
        quantity: 1,
      ),
    ],
    totalInCents: 1080000,
    status: OrderStatus.pending,
    paymentMethod: PaymentMethod.cash,
    queueNumber: 5,
    createdAt: DateTime(2024, 6, 15, 14, 30),
  );

  group('CashTicket', () {
    testWidgets('shows queue number', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CashTicket(order: testOrder))),
      );
      expect(find.text('TURNO #5'), findsOneWidget);
    });

    testWidgets('shows PAGO EN CAJA badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CashTicket(order: testOrder))),
      );
      expect(find.text('PAGO EN CAJA - EFECTIVO'), findsOneWidget);
    });

    testWidgets('shows all items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CashTicket(order: testOrder),
            ),
          ),
        ),
      );
      expect(find.text('2x Cappuccino'), findsOneWidget);
      expect(find.text('1x Latte'), findsOneWidget);
    });

    testWidgets('shows total', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CashTicket(order: testOrder),
            ),
          ),
        ),
      );
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('\$10.800'), findsOneWidget);
    });

    testWidgets('shows footer text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CashTicket(order: testOrder),
            ),
          ),
        ),
      );
      expect(find.text('Presente este ticket en caja'), findsOneWidget);
    });

    testWidgets('shows KIOSKO POS header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CashTicket(order: testOrder))),
      );
      expect(find.text('KIOSKO POS'), findsOneWidget);
    });
  });
}
