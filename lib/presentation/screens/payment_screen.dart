import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text('Confirmar pago con $_methodLabel?'),
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

    if (confirmed != true) return;

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
    final totalInCents = cart.totalInCents;
    final tempOrderId = 'pre_${DateTime.now().microsecondsSinceEpoch}';

    setState(() => _statusMessage = 'Esperando pago en terminal...');

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
          ? 'Pago cancelado'
          : tbkResponse.message ?? 'Pago rechazado';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: tbkResponse.result == TransbankResult.cancelled
              ? AppColors.warning
              : AppColors.error,
        ),
      );
      return;
    }

    // Card payment approved — place order
    setState(() => _statusMessage = 'Pago aprobado! Registrando pedido...');
    await _processPayment(
      transbankAuth: tbkResponse.authorizationCode,
      cardLast4: tbkResponse.cardLast4,
    );
  }

  Future<void> _processPayment({
    String? transbankAuth,
    String? cardLast4,
  }) async {
    if (_processing && widget.paymentMethod != PaymentMethod.card) {
      return;
    }
    if (widget.paymentMethod != PaymentMethod.card) {
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _processing = false;
          _statusMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el pago: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Pago',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary)),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _processing ? Icons.hourglass_top : Icons.payment,
                size: 100,
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
                      fontSize: 16,
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
              if (_processing)
                const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
