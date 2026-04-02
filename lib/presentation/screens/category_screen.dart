import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/category.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

class CategoryScreen extends ConsumerWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(category.name, style: AppTypography.headline2.copyWith(
          color: AppColors.textOnPrimary,
        )),
        elevation: 0,
      ),
      body: productsAsync.when(
        data: (allProducts) {
          final products = allProducts
              .where((p) => p.categoryId == category.id)
              .toList();

          if (products.isEmpty) {
            return const Center(
              child: Text('No hay productos en esta categoria'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio:
                    AppSpacing.productCardWidth / AppSpacing.productCardHeight,
                crossAxisSpacing: AppSpacing.gapM,
                mainAxisSpacing: AppSpacing.gapM,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
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
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => const Center(
          child: Text('Error al cargar productos'),
        ),
      ),
    );
  }
}
