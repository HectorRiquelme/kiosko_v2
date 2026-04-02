import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/product.dart' as domain;
import '../../providers/database_provider.dart';
import 'product_form_screen.dart';

final adminProductsProvider = FutureProvider<List<domain.Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  // Get ALL products including unavailable
  return repo.getAllProducts();
});

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  static String formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Gestion de productos',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 24)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductFormScreen(),
                ),
              );
              ref.invalidate(adminProductsProvider);
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No hay productos'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Row(
                  children: [
                    // Product image placeholder
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: product.imageUrl.startsWith('/')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                      Icons.fastfood,
                                      color: AppColors.textSecondary)),
                            )
                          : const Icon(Icons.fastfood,
                              color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: AppTypography.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
                          Text(formatPrice(product.priceInCents),
                              style: AppTypography.price.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                    // Availability toggle
                    Switch(
                      value: product.available,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) async {
                        await ref
                            .read(productRepositoryProvider)
                            .toggleProductAvailability(product.id, val);
                        ref.invalidate(adminProductsProvider);
                      },
                    ),
                    // Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductFormScreen(product: product),
                          ),
                        );
                        ref.invalidate(adminProductsProvider);
                      },
                    ),
                    // Delete
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar producto'),
                            content: Text(
                                'Eliminar "${product.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar',
                                    style: TextStyle(
                                        color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(productRepositoryProvider)
                              .deleteProduct(product.id);
                          ref.invalidate(adminProductsProvider);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => const Center(child: Text('Error al cargar productos')),
      ),
    );
  }
}
