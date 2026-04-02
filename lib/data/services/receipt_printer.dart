import 'package:intl/intl.dart';
import '../../domain/entities/order.dart';

class ReceiptPrinter {
  static String generateReceipt(Order order) {
    final formatter = NumberFormat('#,###', 'es_CL');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('         KIOSKO POS');
    buffer.writeln('================================');
    buffer.writeln('Turno: #${order.queueNumber}');
    buffer.writeln('Fecha: ${dateFormatter.format(order.createdAt)}');
    buffer.writeln('Pago: ${_paymentLabel(order.paymentMethod)}');
    buffer.writeln('--------------------------------');

    for (final item in order.items) {
      final price = formatter.format(item.totalInCents ~/ 100);
      buffer.writeln('${item.quantity}x ${item.product.name}');
      buffer.writeln('   \$$price');
    }

    buffer.writeln('--------------------------------');
    final total = formatter.format(order.totalInCents ~/ 100);
    buffer.writeln('TOTAL: \$$total');
    buffer.writeln('================================');
    buffer.writeln('       Gracias por su compra!');
    buffer.writeln('================================');

    return buffer.toString();
  }

  static String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }

  // TODO: Implement actual printer connection via platform channel
  static Future<bool> printReceipt(Order order) async {
    final receipt = generateReceipt(order);
    // For now, just log the receipt
    // In production, this would connect to a thermal printer via USB/Bluetooth
    print(receipt); // ignore: avoid_print
    return true;
  }
}
