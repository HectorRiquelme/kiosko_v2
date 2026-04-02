import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/l10n/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('all strings are non-empty', () {
      expect(AppStrings.appName.isNotEmpty, true);
      expect(AppStrings.continueButton.isNotEmpty, true);
      expect(AppStrings.cart.isNotEmpty, true);
      expect(AppStrings.emptyCart.isNotEmpty, true);
      expect(AppStrings.orderConfirmed.isNotEmpty, true);
      expect(AppStrings.newOrder.isNotEmpty, true);
    });

    test('payment method strings are correct', () {
      expect(AppStrings.cash, 'Efectivo');
      expect(AppStrings.card, 'Tarjeta');
      expect(AppStrings.transfer, 'Transferencia');
    });
  });
}
