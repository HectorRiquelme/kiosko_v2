import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/services/receipt_printer.dart';
import 'package:kiosko_v2/domain/entities/order.dart';
import 'package:kiosko_v2/domain/entities/product.dart';
import 'package:kiosko_v2/domain/entities/cart_item.dart';

void main() {
  group('ReceiptPrinter', () {
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
      ],
      totalInCents: 700000,
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.cash,
      queueNumber: 42,
      createdAt: DateTime(2024, 6, 15, 14, 30),
    );

    test('generates receipt with order details', () {
      final receipt = ReceiptPrinter.generateReceipt(testOrder);

      expect(receipt, contains('KIOSKO POS'));
      expect(receipt, contains('#42'));
      expect(receipt, contains('15/06/2024 14:30'));
      expect(receipt, contains('Efectivo'));
      expect(receipt, contains('2x Cappuccino'));
      expect(receipt, contains('\$7.000'));
      expect(receipt, contains('Gracias por su compra'));
    });

    test('generates receipt with card payment', () {
      final cardOrder = Order(
        id: '2',
        items: [],
        totalInCents: 0,
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.card,
        queueNumber: 1,
        createdAt: DateTime(2024, 1, 1),
      );
      final receipt = ReceiptPrinter.generateReceipt(cardOrder);
      expect(receipt, contains('Tarjeta'));
    });

    test('generates receipt with transfer payment', () {
      final transferOrder = Order(
        id: '3',
        items: [],
        totalInCents: 0,
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.transfer,
        queueNumber: 1,
        createdAt: DateTime(2024, 1, 1),
      );
      final receipt = ReceiptPrinter.generateReceipt(transferOrder);
      expect(receipt, contains('Transferencia'));
    });
  });
}
