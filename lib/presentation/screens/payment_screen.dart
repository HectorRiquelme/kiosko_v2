import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/order.dart';
import '../../data/services/transbank/transbank_service.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'success_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final PaymentMethod paymentMethod;

  const PaymentScreen({super.key, required this.paymentMethod});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _processing = false;
  String _statusMessage = '';

  static String _formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  String get _methodLabel {
    switch (widget.paymentMethod) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }

  Future<void> _confirmAndProcess() async {
    // Prevent double tap
    if (_processing) return;

    // Verify cart is not empty before showing confirmation
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El carrito esta vacio'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    final total = _formatPrice(cart.totalInCents);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metodo: $_methodLabel'),
            const SizedBox(height: 8),
            Text('Total: $total',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    if (widget.paymentMethod == PaymentMethod.card) {
      await _processCardPayment();
    } else {
      await _processPayment();
    }
  }

  Future<void> _processCardPayment() async {
    if (_processing) return;
    setState(() {
      _processing = true;
      _statusMessage = 'Conectando con terminal...';
    });

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      _showError('El carrito esta vacio');
      return;
    }

    final totalInCents = cart.totalInCents;
    final tempOrderId = 'pre_${DateTime.now().microsecondsSinceEpoch}';

    setState(() => _statusMessage = 'Esperando pago en terminal...\n${_formatPrice(totalInCents)}');

    try {
      final tbkResponse = await TransbankService.processPayment(
        amountInCents: totalInCents,
        orderId: tempOrderId,
      );

      if (!mounted) return;

      if (!tbkResponse.isApproved) {
        setState(() {
          _processing = false;
          _statusMessage = '';
        });

        final errorMsg = tbkResponse.result == TransbankResult.cancelled
            ? 'Pago cancelado por el usuario'
            : tbkResponse.message ?? 'Pago rechazado por el terminal';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 4),
            backgroundColor: tbkResponse.result == TransbankResult.cancelled
                ? AppColors.warning
                : AppColors.error,
          ),
        );
        return;
      }

      // Card approved — register order
      setState(() => _statusMessage = 'Pago aprobado! Registrando pedido...');
      await _processPayment(
        transbankAuth: tbkResponse.authorizationCode,
        cardLast4: tbkResponse.cardLast4,
      );
    } catch (e) {
      _showError('Error de conexion con terminal: $e');
    }
  }

  Future<void> _processPayment({
    String? transbankAuth,
    String? cardLast4,
  }) async {
    // For non-card, set processing state
    if (widget.paymentMethod != PaymentMethod.card) {
      if (_processing) return;
      setState(() => _processing = true);
    }

    try {
      final order = await ref
          .read(orderProvider.notifier)
          .placeOrder(widget.paymentMethod);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              order: order,
              transbankAuth: transbankAuth,
              cardLast4: cardLast4,
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } on StateError {
      // Empty cart — shouldn't happen but handle gracefully
      _showError('El carrito esta vacio. Vuelve a intentar.');
    } catch (e) {
      _showError('No se pudo registrar el pedido. Intenta de nuevo.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _processing = false;
      _statusMessage = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back navigation while processing
      canPop: !_processing,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: Text('Pago',
              style: AppTypography.headline2
                  .copyWith(color: AppColors.textOnPrimary)),
          elevation: 0,
          automaticallyImplyLeading: !_processing,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _processing ? Icons.hourglass_top : Icons.payment,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.gapM),
                Text(
                  _processing
                      ? (_statusMessage.isEmpty
                          ? 'Procesando pago...'
                          : _statusMessage)
                      : 'Pagar con $_methodLabel',
                  style: AppTypography.headline2,
                  textAlign: TextAlign.center,
                ),
                if (widget.paymentMethod == PaymentMethod.card && !_processing)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Se usara el terminal Transbank conectado',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppSpacing.gapXL),
                if (!_processing)
                  ElevatedButton(
                    onPressed: _confirmAndProcess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.paddingXL,
                        vertical: AppSpacing.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXL),
                      ),
                    ),
                    child: const Text(
                      'Confirmar pago',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (_processing)
                  const CircularProgressIndicator(color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
