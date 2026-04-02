import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/order.dart';
import '../widgets/cash_ticket.dart';

class SuccessScreen extends StatelessWidget {
  final Order order;
  final String? transbankAuth;
  final String? cardLast4;

  const SuccessScreen({
    super.key,
    required this.order,
    this.transbankAuth,
    this.cardLast4,
  });

  bool get _isCash => order.paymentMethod == PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.gapS),
              Text(
                'Pedido confirmado!',
                style: AppTypography.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.gapM),

              if (_isCash) ...[
                // Cash payment: show ticket to take to cashier
                CashTicket(order: order),
                const SizedBox(height: AppSpacing.gapM),
                Text(
                  'Acercate a caja con este ticket para pagar',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // Card/transfer: show queue number
                Text(
                  'Tu numero de turno',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.gapS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.paddingXL,
                    vertical: AppSpacing.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  ),
                  child: Text(
                    '#${order.queueNumber}',
                    style: AppTypography.headline1.copyWith(fontSize: 80),
                  ),
                ),
                if (transbankAuth != null) ...[
                  const SizedBox(height: AppSpacing.gapM),
                  Text(
                    'Tarjeta: ****${cardLast4 ?? ''}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Auth: $transbankAuth',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.gapXL),
                Text(
                  'Por favor espera a que tu numero sea llamado',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppSpacing.gapXL),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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
                  'Nuevo pedido',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
