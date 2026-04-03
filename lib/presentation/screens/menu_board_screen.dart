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
  Timer? _clockTimer;
  Timer? _slideTimer;
  final PageController _pageController = PageController();
  String _timeString = '';
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(categoriesProvider);
      ref.invalidate(productsProvider);
      ref.invalidate(menuBoardPromosProvider);
    });
    // Auto-slide every 6 seconds
    _slideTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _nextSlide();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  void _nextSlide() {
    if (!mounted || _totalPages <= 1) return;
    _currentPage = (_currentPage + 1) % _totalPages;
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _clockTimer?.cancel();
    _slideTimer?.cancel();
    _pageController.dispose();
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
      backgroundColor: AppColors.backgroundWarm,
      body: Column(
        children: [
          // Header - warm gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingM,
              vertical: AppSpacing.paddingS,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF9B17), Color(0xFFFF7B00)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('☕ KIOSKO',
                    style: AppTypography.headline2.copyWith(
                        color: AppColors.textOnPrimary, fontSize: 20)),
                Text('NUESTRO MENU',
                    style: AppTypography.headline2.copyWith(
                        color: AppColors.textOnPrimary, fontSize: 18)),
                Text(_timeString,
                    style: AppTypography.headline2.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.8), fontSize: 16)),
              ],
            ),
          ),

          // Slides content
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => productsAsync.when(
                data: (allProducts) => promosAsync.when(
                  data: (promos) =>
                      _buildSlideShow(categories, allProducts, promos),
                  loading: () => _buildLoading(),
                  error: (_, _) =>
                      _buildSlideShow(categories, allProducts, []),
                ),
                loading: () => _buildLoading(),
                error: (_, _) => _buildLoading(),
              ),
              loading: () => _buildLoading(),
              error: (_, _) => _buildLoading(),
            ),
          ),

          // Page indicator dots
          if (_totalPages > 1)
            Container(
              color: AppColors.backgroundCream,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentPage
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlideShow(
    List<domain_cat.Category> categories,
    List<domain.Product> allProducts,
    List<Promo> promos,
  ) {
    final slides = <Widget>[];

    // Slide 1: Promos highlight (if any)
    if (promos.isNotEmpty) {
      slides.add(_buildPromosSlide(promos));
    }

    // Slides per category
    for (final cat in categories) {
      final products =
          allProducts.where((p) => p.categoryId == cat.id).toList();
      if (products.isNotEmpty) {
        slides.add(_buildCategorySlide(cat, products));
      }
    }

    // Slide: Full menu overview
    slides.add(_buildFullMenuSlide(categories, allProducts));

    _totalPages = slides.length;

    return PageView(
      controller: _pageController,
      onPageChanged: (i) => setState(() => _currentPage = i),
      children: slides,
    );
  }

  Widget _buildPromosSlide(List<Promo> promos) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingM),
      child: Column(
        children: [
          Text('OFERTAS ESPECIALES',
              style: AppTypography.headline2.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              )),
          const SizedBox(height: AppSpacing.gapM),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: promos.length,
              itemBuilder: (_, i) {
                final promo = promos[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.paddingM),
                  decoration: BoxDecoration(
                    color: _parseColor(promo.backgroundColor),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(promo.title,
                          style: AppTypography.headline2.copyWith(
                              color: AppColors.textOnPrimary, fontSize: 20),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (promo.subtitle != null)
                        Text(promo.subtitle!,
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
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
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySlide(
      domain_cat.Category category, List<domain.Product> products) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingM),
      child: Column(
        children: [
          // Category header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingM, vertical: AppSpacing.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(category.name.toUpperCase(),
                style: AppTypography.headline2.copyWith(
                    color: AppColors.textOnPrimary, fontSize: 22),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: AppSpacing.gapM),
          // Products grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: products.length <= 4 ? 2 : 3,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: p.imageUrl.startsWith('asset:')
                              ? Image.asset(p.imageUrl.substring(6),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                      Icons.fastfood,
                                      color: AppColors.textSecondary))
                              : const Icon(Icons.fastfood,
                                  color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p.name,
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            if (p.description != null)
                              Text(p.description!,
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(formatPrice(p.priceInCents),
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMenuSlide(
      List<domain_cat.Category> categories, List<domain.Product> allProducts) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingM),
      child: Column(
        children: [
          Text('MENU COMPLETO',
              style: AppTypography.headline2.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              )),
          const SizedBox(height: AppSpacing.gapS),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (_, catIdx) {
                final cat = categories[catIdx];
                final products =
                    allProducts.where((p) => p.categoryId == cat.id).toList();
                if (products.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(cat.name.toUpperCase(),
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                    ...products.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(p.name,
                                      style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textPrimary,
                                          fontSize: 13))),
                              Expanded(
                                child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 6),
                                    height: 1,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.2)),
                              ),
                              Text(formatPrice(p.priceInCents),
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
