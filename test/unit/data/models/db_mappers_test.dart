import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/models/db_mappers.dart';
import 'package:kiosko_v2/domain/entities/order.dart';

void main() {
  group('db_mappers', () {
    test('parseOrderStatus returns correct enum values', () {
      expect(parseOrderStatus('pending'), OrderStatus.pending);
      expect(parseOrderStatus('preparing'), OrderStatus.preparing);
      expect(parseOrderStatus('ready'), OrderStatus.ready);
      expect(parseOrderStatus('delivered'), OrderStatus.delivered);
      expect(parseOrderStatus('cancelled'), OrderStatus.cancelled);
      expect(parseOrderStatus('unknown'), OrderStatus.pending);
    });

    test('parsePaymentMethod returns correct enum values', () {
      expect(parsePaymentMethod('cash'), PaymentMethod.cash);
      expect(parsePaymentMethod('card'), PaymentMethod.card);
      expect(parsePaymentMethod('transfer'), PaymentMethod.transfer);
      expect(parsePaymentMethod('unknown'), PaymentMethod.cash);
    });
  });
}
