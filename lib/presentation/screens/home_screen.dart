import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart' as domain;
import '../providers/cart_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/smart_image.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/modifier_dialog.dart';
import '../providers/database_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(searchQueryProvider.notifier).state =
        _searchController.text.trim();
  }

  void _onCategoryTap(String categoryId) {
    final current = ref.read(selectedCategoryProvider);
    ref.read(selectedCategoryProvider.notifier).state =
        current == categoryId ? null : categoryId;
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos dias';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Header with greeting
                SliverToBoxAdapter(child: _buildHeader()),
                // Search
                SliverToBoxAdapter(child: _buildSearchBar()),
                // Hero promo banner
                SliverToBoxAdapter(child: _buildHeroBanner()),
                // Category chips
                SliverToBoxAdapter(child: _buildCategoryChips()),
                // Products section title
                SliverToBoxAdapter(child: _buildProductsHeader()),
                // Products grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.paddingM),
                  sliver: _buildProductsGrid(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: cart.isEmpty ? 20 : AppSpacing.bottomCartBarHeight + 20),
                ),
              ],
            ),
            if (!cart.isEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildCartBar(cart),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting,
                  style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text('Que vas a pedir hoy?',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9B17), Color(0xFFFF7B00)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.coffee_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => _onSearch(),
          style: AppTypography.bodyMedium.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.search,
                color: AppColors.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFF9B17), Color(0xFFFF6B00)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Oferta del dia',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500)),
                  Text('Hasta 30% OFF',
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                  Text('en cafes seleccionados',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9))),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Ver ofertas',
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) => SizedBox(
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length + 1, // +1 for "Todos"
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = selectedCategory == null;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                  child: _CategoryChip(
                    label: 'Todos',
                    isSelected: isSelected,
                  ),
                ),
              );
            }

            final cat = categories[index - 1];
            final isSelected = selectedCategory == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _onCategoryTap(cat.id),
                child: _CategoryChip(
                  label: cat.name,
                  isSelected: isSelected,
                  imageUrl: cat.imageUrl,
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 42),
      error: (_, _) => const SizedBox(height: 42),
    );
  }

  Widget _buildProductsHeader() {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);

    String title = 'Populares';
    if (selectedCategory != null) {
      categoriesAsync.whenData((cats) {
        final match = cats.where((c) => c.id == selectedCategory);
        if (match.isNotEmpty) title = match.first.name;
      });
    }

    final count = productsAsync.whenOrNull(data: (p) => p.length) ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text('$count productos',
              style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  SliverGrid _buildProductsGrid() {
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return productsAsync.when(
      data: (products) => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            final inCart = cart.containsProduct(product.id);
            final qty = cart.quantityOf(product.id);
            return ProductCard(
              name: product.name,
              imageUrl: product.imageUrl,
              priceInCents: product.priceInCents,
              onAddToCart: () async {
                final modRepo = ref.read(modifierRepositoryProvider);
                final groups =
                    await modRepo.getModifiersForProduct(product.id);

                if (groups.isEmpty) {
                  ref.read(cartProvider.notifier).addToCart(product);
                  return;
                }

                if (!context.mounted) return;
                final result = await showDialog(
                  context: context,
                  builder: (_) => ModifierDialog(
                    productName: product.name,
                    basePriceCents: product.priceInCents,
                    groups: groups,
                  ),
                );

                if (result != null) {
                  ref.read(cartProvider.notifier).addToCart(
                        product,
                        modifiers: result.modifiers,
                        modifierPriceAdjustCents: result.priceAdjust,
                      );
                }
              },
              isInCart: inCart,
              quantityInCart: qty,
            );
          },
          childCount: products.length,
        ),
      ),
      loading: () => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          childCount: 1,
        ),
      ),
      error: (_, _) => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => const Center(child: Text('Error al cargar productos')),
          childCount: 1,
        ),
      ),
    );
  }

  Widget _buildCartBar(Cart cart) {
    return CartBottomBar(
      items: cart.items,
      totalInCents: cart.totalInCents,
      onContinue: () {
        Navigator.of(context).pushNamed('/cart');
      },
      onIncrement: (domain.CartItem item) {
        ref.read(cartProvider.notifier).incrementItem(item.cartKey);
      },
      onDecrement: (domain.CartItem item) {
        ref.read(cartProvider.notifier).decrementItem(item.cartKey);
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final String? imageUrl;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 22,
                height: 22,
                child: SmartImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.restaurant,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
