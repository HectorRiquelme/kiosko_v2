import 'package:flutter/services.dart';

enum TransbankResult { approved, rejected, error, cancelled }

class TransbankResponse {
  final TransbankResult result;
  final String? authorizationCode;
  final String? transactionId;
  final int amountInCents;
  final String? cardLast4;
  final String? message;
  final String? voucherText;

  const TransbankResponse({
    required this.result,
    this.authorizationCode,
    this.transactionId,
    required this.amountInCents,
    this.cardLast4,
    this.message,
    this.voucherText,
  });

  bool get isApproved => result == TransbankResult.approved;
}

/// Service to communicate with Transbank POS terminals on Android.
///
/// Transbank POS terminals run their own app on Android. This service
/// communicates via a MethodChannel to native Android code that launches
/// the Transbank payment intent.
///
/// On non-Android platforms, it simulates a successful payment for development.
class TransbankService {
  static const _channel = MethodChannel('com.kiosko.transbank');

  /// Process a card payment through the connected Transbank terminal.
  ///
  /// [amountInCents] - Amount to charge (e.g., 350000 = $3.500 CLP)
  /// [orderId] - Reference ID for this transaction
  static Future<TransbankResponse> processPayment({
    required int amountInCents,
    required String orderId,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('processPayment', {
        'amount': amountInCents ~/ 100, // Transbank uses CLP, not cents
        'orderId': orderId,
      });

      if (result == null) {
        return TransbankResponse(
          result: TransbankResult.error,
          amountInCents: amountInCents,
          message: 'Sin respuesta del terminal',
        );
      }

      final responseCode = result['responseCode'] as int? ?? -1;
      return TransbankResponse(
        result: responseCode == 0
            ? TransbankResult.approved
            : TransbankResult.rejected,
        authorizationCode: result['authorizationCode'] as String?,
        transactionId: result['transactionId'] as String?,
        amountInCents: amountInCents,
        cardLast4: result['cardLast4'] as String?,
        message: result['message'] as String?,
        voucherText: result['voucherText'] as String?,
      );
    } on MissingPluginException {
      // Platform channel not available (iOS, desktop, or testing)
      // Simulate approved payment for development
      return _simulatePayment(amountInCents, orderId);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELLED') {
        return TransbankResponse(
          result: TransbankResult.cancelled,
          amountInCents: amountInCents,
          message: 'Pago cancelado por el usuario',
        );
      }
      return TransbankResponse(
        result: TransbankResult.error,
        amountInCents: amountInCents,
        message: e.message ?? 'Error de comunicacion con terminal',
      );
    }
  }

  /// Check if Transbank terminal app is available on this device.
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Request the last transaction result from the terminal.
  static Future<TransbankResponse?> getLastTransaction() async {
    try {
      final result = await _channel.invokeMethod<Map>('getLastTransaction');
      if (result == null) return null;

      return TransbankResponse(
        result: (result['responseCode'] as int? ?? -1) == 0
            ? TransbankResult.approved
            : TransbankResult.rejected,
        authorizationCode: result['authorizationCode'] as String?,
        transactionId: result['transactionId'] as String?,
        amountInCents: ((result['amount'] as int?) ?? 0) * 100,
        cardLast4: result['cardLast4'] as String?,
        voucherText: result['voucherText'] as String?,
      );
    } on MissingPluginException {
      return null;
    }
  }

  /// Simulated payment for development/testing on non-Android platforms.
  static Future<TransbankResponse> _simulatePayment(
      int amountInCents, String orderId) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    return TransbankResponse(
      result: TransbankResult.approved,
      authorizationCode: 'SIM${DateTime.now().millisecondsSinceEpoch % 100000}',
      transactionId: 'TX_$orderId',
      amountInCents: amountInCents,
      cardLast4: '4242',
      message: 'Pago simulado aprobado',
    );
  }
}
