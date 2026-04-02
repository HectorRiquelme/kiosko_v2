import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/order.dart';

/// Visual ticket widget that displays order details for cash payment.
/// The customer shows this on screen when approaching the cashier.
class CashTicket extends StatelessWidget {
  final Order order;

  const CashTicket({super.key, required this.order});

  static String _formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text('KIOSKO POS',
              style: AppTypography.headline2.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          const Divider(thickness: 2),
          const SizedBox(height: 8),

          // Queue number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TURNO #${order.queueNumber}',
              style: AppTypography.headline2.copyWith(
                color: AppColors.textOnPrimary,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date
          Text(
            dateFormat.format(order.createdAt),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          // Payment badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.warning),
            ),
            child: Text(
              'PAGO EN CAJA - EFECTIVO',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Items
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: AppTypography.bodyMedium.copyWith(fontSize: 15),
                      ),
                    ),
                    Text(
                      _formatPrice(item.totalInCents),
                      style: AppTypography.bodyMedium.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              )),

          const Divider(),
          const SizedBox(height: 4),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL',
                  style: AppTypography.headline2.copyWith(fontSize: 22)),
              Text(
                _formatPrice(order.totalInCents),
                style: AppTypography.headline2.copyWith(fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 2),
          const SizedBox(height: 8),

          // Footer
          Text(
            'Presente este ticket en caja',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Gracias por su preferencia',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
