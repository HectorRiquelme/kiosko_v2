import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart' as domain;
import '../providers/cart_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/kiosk_search_bar.dart';
import '../widgets/cart_bottom_bar.dart';

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
    // Clear search when selecting category
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth >= 900;
          if (isLandscape) {
            return _buildLandscapeLayout(cart);
          }
          return _buildPortraitLayout(cart);
        },
      ),
    );
  }

  Widget _buildPortraitLayout(Cart cart) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: KioskSearchBar(
                controller: _searchController,
                onSearch: _onSearch,
              ),
            ),
            SliverToBoxAdapter(child: _buildHeroBanner()),
            SliverToBoxAdapter(child: _buildSectionTitle('Categorias')),
            SliverToBoxAdapter(child: _buildCategoriesRow()),
            SliverToBoxAdapter(child: _buildPromoSection()),
            SliverToBoxAdapter(child: _buildSectionTitle('Productos')),
            _buildProductsGrid(3),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.bottomCartBarHeight + 20),
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
    );
  }

  Widget _buildLandscapeLayout(Cart cart) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: Container(
            color: AppColors.backgroundWhite,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.gapM),
                Expanded(child: _buildCategoriesColumn()),
                if (!cart.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.paddingS),
                    child: Text(
                      'Carrito: ${cart.totalItems} items',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: KioskSearchBar(
                      controller: _searchController,
                      onSearch: _onSearch,
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildHeroBanner()),
                  SliverToBoxAdapter(child: _buildPromoSection()),
                  SliverToBoxAdapter(child: _buildSectionTitle('Productos')),
                  _buildProductsGrid(4),
                  const SliverToBoxAdapter(
                    child:
                        SizedBox(height: AppSpacing.bottomCartBarHeight + 20),
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
      ],
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
        ref.read(cartProvider.notifier).incrementItem(item.product.id);
      },
      onDecrement: (domain.CartItem item) {
        ref.read(cartProvider.notifier).decrementItem(item.product.id);
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Kiosko', style: AppTypography.headline2),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: AppColors.textOnPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingS),
      child: HeroBanner(
        discountText: 'Descuento especial',
        percentageText: 'Hasta 50%',
        buttonText: 'Ordenar',
        imageUrl: 'https://placehold.co/200',
        onButtonTap: () {},
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingM),
      child: Text(title, style: AppTypography.headline2),
    );
  }

  Widget _buildCategoriesRow() {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) => SizedBox(
        height: AppSpacing.categoryCardSize + AppSpacing.paddingS,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.paddingS),
          itemCount: categories.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: AppSpacing.gapL),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Opacity(
              opacity: selectedCategory == null ||
                      selectedCategory == cat.id
                  ? 1.0
                  : 0.5,
              child: CategoryCard(
                name: cat.name,
                imageUrl: cat.imageUrl,
                onTap: () => _onCategoryTap(cat.id),
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(
        height: 195,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, _) => const SizedBox(
        height: 195,
        child: Center(child: Text('Error al cargar categorias')),
      ),
    );
  }

  Widget _buildCategoriesColumn() {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) => ListView.separated(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.paddingS),
        itemCount: categories.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppSpacing.gapM),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Opacity(
            opacity: selectedCategory == null ||
                    selectedCategory == cat.id
                ? 1.0
                : 0.5,
            child: CategoryCard(
              name: cat.name,
              imageUrl: cat.imageUrl,
              onTap: () => _onCategoryTap(cat.id),
            ),
          );
        },
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, _) => const Center(child: Text('Error')),
    );
  }

  Widget _buildPromoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingS,
        vertical: AppSpacing.paddingM,
      ),
      child: Row(
        children: [
          Expanded(
            child: PromoCard(
              titleLine1: 'Primer',
              titleLine2: 'Combo',
              buttonText: 'Ver mas',
              imageUrl: 'https://placehold.co/150',
              backgroundColor: AppColors.promoRed,
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppSpacing.gapM),
          Expanded(
            child: PromoCard(
              titleLine1: 'Bebidas',
              titleLine2: 'Frias',
              buttonText: 'Ver mas',
              imageUrl: 'https://placehold.co/150',
              backgroundColor: AppColors.promoBrown,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  SliverGrid _buildProductsGrid(int crossAxisCount) {
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return productsAsync.when(
      data: (products) => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio:
              AppSpacing.productCardWidth / AppSpacing.productCardHeight,
          crossAxisSpacing: AppSpacing.gapM,
          mainAxisSpacing: AppSpacing.gapM,
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
              onAddToCart: () {
                ref.read(cartProvider.notifier).addToCart(product);
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
          childAspectRatio:
              AppSpacing.productCardWidth / AppSpacing.productCardHeight,
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
          childAspectRatio:
              AppSpacing.productCardWidth / AppSpacing.productCardHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => const Center(child: Text('Error al cargar productos')),
          childCount: 1,
        ),
      ),
    );
  }
}
