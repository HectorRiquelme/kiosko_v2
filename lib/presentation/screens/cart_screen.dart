import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

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
        title: Text('Carrito', style: AppTypography.headline2.copyWith(
          color: AppColors.textOnPrimary,
        )),
        elevation: 0,
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 80, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.gapM),
                  Text('Tu carrito esta vacio',
                      style: AppTypography.bodyLarge),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.paddingS),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.gapS),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusM),
                        ),
                        child: Row(
                          children: [
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatPrice(item.product.priceInCents),
                                    style: AppTypography.price,
                                  ),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.primary),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .decrementItem(item.cartKey);
                                  },
                                ),
                                Text('${item.quantity}',
                                    style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: AppColors.primary),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .incrementItem(item.cartKey);
                                  },
                                ),
                              ],
                            ),
                            // Item total
                            SizedBox(
                              width: 100,
                              child: Text(
                                formatPrice(item.totalInCents),
                                style: AppTypography.price.copyWith(
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom total bar
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total', style: AppTypography.bodyMedium),
                            Text(
                              formatPrice(cart.totalInCents),
                              style: AppTypography.headline2,
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.paddingXL,
                              vertical: AppSpacing.paddingS,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXL),
                            ),
                          ),
                          child: const Text(
                            'Pagar',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
