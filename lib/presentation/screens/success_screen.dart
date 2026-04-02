import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/order.dart';

class SuccessScreen extends StatelessWidget {
  final Order order;

  const SuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 120,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.gapM),
              Text(
                'Pedido confirmado!',
                style: AppTypography.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.gapM),
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
              const SizedBox(height: AppSpacing.gapXL),
              Text(
                'Por favor espera a que tu numero sea llamado',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
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
