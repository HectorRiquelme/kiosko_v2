import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/kiosk_search_bar.dart';
import '../widgets/cart_bottom_bar.dart';

// Mock data for standalone UI
class _MockData {
  static const categories = [
    {'name': 'Cafe', 'imageUrl': 'https://placehold.co/100'},
    {'name': 'Bebidas', 'imageUrl': 'https://placehold.co/100'},
    {'name': 'Pasteles', 'imageUrl': 'https://placehold.co/100'},
    {'name': 'Snacks', 'imageUrl': 'https://placehold.co/100'},
    {'name': 'Combos', 'imageUrl': 'https://placehold.co/100'},
  ];

  static const products = [
    {
      'name': 'Cappuccino',
      'imageUrl': 'https://placehold.co/150',
      'price': 350000
    },
    {
      'name': 'Latte',
      'imageUrl': 'https://placehold.co/150',
      'price': 380000
    },
    {
      'name': 'Americano',
      'imageUrl': 'https://placehold.co/150',
      'price': 280000
    },
    {
      'name': 'Mocha',
      'imageUrl': 'https://placehold.co/150',
      'price': 420000
    },
    {
      'name': 'Espresso',
      'imageUrl': 'https://placehold.co/150',
      'price': 250000
    },
    {
      'name': 'Flat White',
      'imageUrl': 'https://placehold.co/150',
      'price': 390000
    },
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final List<CartItem> _cartItems = [];

  int get _totalInCents =>
      _cartItems.fold(0, (sum, i) => sum + i.priceInCents * i.quantity);

  void _addToCart(String name, int price) {
    setState(() {
      final existing = _cartItems.indexWhere((i) => i.name == name);
      if (existing >= 0) {
        final item = _cartItems[existing];
        _cartItems[existing] = CartItem(
          productId: item.productId,
          name: item.name,
          imageUrl: item.imageUrl,
          priceInCents: item.priceInCents,
          quantity: item.quantity + 1,
        );
      } else {
        _cartItems.add(CartItem(
          productId: name,
          name: name,
          imageUrl: 'https://placehold.co/80',
          priceInCents: price,
          quantity: 1,
        ));
      }
    });
  }

  void _incrementItem(CartItem item) {
    setState(() {
      final idx = _cartItems.indexWhere((i) => i.productId == item.productId);
      if (idx >= 0) {
        _cartItems[idx] = CartItem(
          productId: item.productId,
          name: item.name,
          imageUrl: item.imageUrl,
          priceInCents: item.priceInCents,
          quantity: item.quantity + 1,
        );
      }
    });
  }

  void _decrementItem(CartItem item) {
    setState(() {
      final idx = _cartItems.indexWhere((i) => i.productId == item.productId);
      if (idx >= 0) {
        if (item.quantity <= 1) {
          _cartItems.removeAt(idx);
        } else {
          _cartItems[idx] = CartItem(
            productId: item.productId,
            name: item.name,
            imageUrl: item.imageUrl,
            priceInCents: item.priceInCents,
            quantity: item.quantity - 1,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth >= 900;
          if (isLandscape) {
            return _buildLandscapeLayout();
          }
          return _buildPortraitLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: KioskSearchBar(
                controller: _searchController,
                onSearch: () {},
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
        if (_cartItems.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CartBottomBar(
              items: _cartItems,
              totalInCents: _totalInCents,
              onContinue: () {},
              onIncrement: _incrementItem,
              onDecrement: _decrementItem,
            ),
          ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Sidebar (25%)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: Container(
            color: AppColors.backgroundWhite,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.gapM),
                Expanded(child: _buildCategoriesColumn()),
                if (_cartItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.paddingS),
                    child: Text(
                      'Carrito: ${_cartItems.length} items',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Content (75%)
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: KioskSearchBar(
                      controller: _searchController,
                      onSearch: () {},
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
              if (_cartItems.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CartBottomBar(
                    items: _cartItems,
                    totalInCents: _totalInCents,
                    onContinue: () {},
                    onIncrement: _incrementItem,
                    onDecrement: _decrementItem,
                  ),
                ),
            ],
          ),
        ),
      ],
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
    return SizedBox(
      height: AppSpacing.categoryCardSize + AppSpacing.paddingS,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.paddingS),
        itemCount: _MockData.categories.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppSpacing.gapL),
        itemBuilder: (context, index) {
          final cat = _MockData.categories[index];
          return CategoryCard(
            name: cat['name']!,
            imageUrl: cat['imageUrl']!,
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildCategoriesColumn() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingS),
      itemCount: _MockData.categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gapM),
      itemBuilder: (context, index) {
        final cat = _MockData.categories[index];
        return CategoryCard(
          name: cat['name']!,
          imageUrl: cat['imageUrl']!,
          onTap: () {},
        );
      },
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
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio:
            AppSpacing.productCardWidth / AppSpacing.productCardHeight,
        crossAxisSpacing: AppSpacing.gapM,
        mainAxisSpacing: AppSpacing.gapM,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = _MockData.products[index];
          final name = product['name'] as String;
          final price = product['price'] as int;
          final inCart = _cartItems.any((i) => i.name == name);
          final qty = inCart
              ? _cartItems.firstWhere((i) => i.name == name).quantity
              : 0;
          return ProductCard(
            name: name,
            imageUrl: product['imageUrl'] as String,
            priceInCents: price,
            onAddToCart: () => _addToCart(name, price),
            isInCart: inCart,
            quantityInCart: qty,
          );
        },
        childCount: _MockData.products.length,
      ),
    );
  }
}
