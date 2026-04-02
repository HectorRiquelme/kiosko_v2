import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/data/services/transbank/transbank_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TransbankService', () {
    setUp(() {
      // Set up mock channel that throws MissingPluginException (simulating non-Android)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.kiosko.transbank'),
        null, // null handler = MissingPluginException
      );
    });

    test('processPayment returns simulated response on non-Android', () async {
      final response = await TransbankService.processPayment(
        amountInCents: 350000,
        orderId: 'test_123',
      );

      expect(response.isApproved, true);
      expect(response.amountInCents, 350000);
      expect(response.cardLast4, '4242');
      expect(response.authorizationCode, isNotNull);
      expect(response.transactionId, 'TX_test_123');
    });

    test('isAvailable returns false on non-Android', () async {
      final available = await TransbankService.isAvailable();
      expect(available, false);
    });

    test('getLastTransaction returns null on non-Android', () async {
      final result = await TransbankService.getLastTransaction();
      expect(result, isNull);
    });
  });

  group('TransbankResponse', () {
    test('isApproved is true when result is approved', () {
      const response = TransbankResponse(
        result: TransbankResult.approved,
        amountInCents: 100000,
      );
      expect(response.isApproved, true);
    });

    test('isApproved is false when rejected', () {
      const response = TransbankResponse(
        result: TransbankResult.rejected,
        amountInCents: 100000,
      );
      expect(response.isApproved, false);
    });

    test('isApproved is false when cancelled', () {
      const response = TransbankResponse(
        result: TransbankResult.cancelled,
        amountInCents: 100000,
      );
      expect(response.isApproved, false);
    });

    test('isApproved is false when error', () {
      const response = TransbankResponse(
        result: TransbankResult.error,
        amountInCents: 100000,
        message: 'Connection failed',
      );
      expect(response.isApproved, false);
      expect(response.message, 'Connection failed');
    });
  });
}
