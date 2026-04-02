import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/category.dart' as domain_cat;
import '../../domain/entities/promo.dart';
import '../providers/database_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/products_provider.dart';

final menuBoardPromosProvider = FutureProvider<List<Promo>>((ref) async {
  try {
    final repo = ref.watch(promoRepositoryProvider);
    return await repo.getActivePromos();
  } catch (_) {
    return <Promo>[];
  }
});

class MenuBoardScreen extends ConsumerStatefulWidget {
  const MenuBoardScreen({super.key});

  @override
  ConsumerState<MenuBoardScreen> createState() => _MenuBoardScreenState();
}

class _MenuBoardScreenState extends ConsumerState<MenuBoardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh every 30 seconds for price/promo updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(categoriesProvider);
      ref.invalidate(productsProvider);
      ref.invalidate(menuBoardPromosProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  static String formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final promosAsync = ref.watch(menuBoardPromosProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingM,
              vertical: AppSpacing.paddingS,
            ),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KIOSKO POS',
                    style: AppTypography.headline2.copyWith(
                        color: AppColors.textOnPrimary, fontSize: 20)),
                Text('MENU',
                    style: AppTypography.headline2.copyWith(
                        color: AppColors.textOnPrimary, fontSize: 20)),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Row(
              children: [
                // Left: Products by category (70%)
                Expanded(
                  flex: 7,
                  child: categoriesAsync.when(
                    data: (categories) => productsAsync.when(
                      data: (allProducts) => _buildMenuGrid(
                          categories, allProducts),
                      loading: () => _buildLoading(),
                      error: (_, _) => _buildLoading(),
                    ),
                    loading: () => _buildLoading(),
                    error: (_, _) => _buildLoading(),
                  ),
                ),

                // Right: Promos sidebar (30%)
                Expanded(
                  flex: 3,
                  child: Container(
                    color: AppColors.backgroundDark,
                    child: promosAsync.when(
                      data: (promos) => _buildPromosSidebar(promos),
                      loading: () => _buildLoading(),
                      error: (_, _) => const SizedBox(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(
      List<domain_cat.Category> categories, List<domain.Product> allProducts) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.paddingS),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final products =
            allProducts.where((p) => p.categoryId == cat.id).toList();
        if (products.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingS,
                vertical: AppSpacing.paddingXS,
              ),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                cat.name.toUpperCase(),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),

            // Products list
            ...products.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textOnDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Dots
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 1,
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      // Price
                      Text(
                        formatPrice(product.priceInCents),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: AppSpacing.gapM),
          ],
        );
      },
    );
  }

  Widget _buildPromosSidebar(List<Promo> promos) {
    if (promos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer, size: 40, color: AppColors.primary),
            const SizedBox(height: 8),
            Text('Ofertas',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.paddingS),
      itemCount: promos.length,
      itemBuilder: (context, index) {
        final promo = promos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.gapS),
          padding: const EdgeInsets.all(AppSpacing.paddingS),
          decoration: BoxDecoration(
            color: _parseColor(promo.backgroundColor),
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promo.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              if (promo.subtitle != null)
                Text(
                  promo.subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  promo.isPercentDiscount
                      ? '${promo.discountPercent}% OFF'
                      : promo.isAmountDiscount
                          ? '-${formatPrice(promo.discountAmountCents)}'
                          : 'OFERTA',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.promoRed;
    }
  }
}
