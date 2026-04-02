import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/animations/animated_counter.dart';

class CartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final int priceInCents;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.priceInCents,
    required this.quantity,
  });
}

class CartBottomBar extends StatelessWidget {
  final List<CartItem> items;
  final int totalInCents;
  final String currencySymbol;
  final VoidCallback onContinue;
  final ValueChanged<CartItem> onIncrement;
  final ValueChanged<CartItem> onDecrement;

  const CartBottomBar({
    super.key,
    required this.items,
    required this.totalInCents,
    this.currencySymbol = '\$',
    required this.onContinue,
    required this.onIncrement,
    required this.onDecrement,
  });

  String _formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '$currencySymbol${formatter.format(cents ~/ 100)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: items.isEmpty ? const Offset(0, 1) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Container(
        height: AppSpacing.bottomCartBarHeight,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusL),
            topRight: Radius.circular(AppSpacing.radiusL),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingM,
          vertical: AppSpacing.paddingS,
        ),
        child: Row(
          children: [
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.gapS),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _CartItemTile(
                    item: item,
                    currencySymbol: currencySymbol,
                    onIncrement: () => onIncrement(item),
                    onDecrement: () => onDecrement(item),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.paddingS),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatPrice(totalInCents),
                  style: AppTypography.headline2
                      .copyWith(color: AppColors.textOnPrimary),
                ),
                const SizedBox(height: AppSpacing.gapXS),
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundWhite,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXL),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.paddingL,
                      vertical: AppSpacing.paddingS,
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final String currencySymbol;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemTile({
    required this.item,
    required this.currencySymbol,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name,
            style: AppTypography.buttonSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onDecrement,
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.textOnPrimary,
                  size: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedCounter(
                  value: item.quantity,
                  style: AppTypography.buttonSmall.copyWith(fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: onIncrement,
                child: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.textOnPrimary,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
