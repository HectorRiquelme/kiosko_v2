import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/order.dart';
import '../providers/cart_provider.dart';
import 'payment_screen.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  static String formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Resumen del pedido',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.paddingS),
              children: [
                // Order items
                Container(
                  padding: const EdgeInsets.all(AppSpacing.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Productos',
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.gapS),
                      ...cart.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.product.name}',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                                Text(
                                  formatPrice(item.totalInCents),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: AppTypography.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w700)),
                          Text(formatPrice(cart.totalInCents),
                              style: AppTypography.headline2),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Payment method selection
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingM),
            decoration: const BoxDecoration(
              color: AppColors.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Selecciona metodo de pago',
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.gapM),
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentMethodButton(
                          icon: Icons.payments_outlined,
                          label: 'Efectivo',
                          onTap: () => _navigateToPayment(
                              context, PaymentMethod.cash),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gapS),
                      Expanded(
                        child: _PaymentMethodButton(
                          icon: Icons.credit_card,
                          label: 'Tarjeta',
                          onTap: () => _navigateToPayment(
                              context, PaymentMethod.card),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gapS),
                      Expanded(
                        child: _PaymentMethodButton(
                          icon: Icons.swap_horiz,
                          label: 'Transferencia',
                          onTap: () => _navigateToPayment(
                              context, PaymentMethod.transfer),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(BuildContext context, PaymentMethod method) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(paymentMethod: method),
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.paddingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textOnPrimary, size: 36),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.buttonSmall.copyWith(
              fontSize: 16,
            )),
          ],
        ),
      ),
    );
  }
}
