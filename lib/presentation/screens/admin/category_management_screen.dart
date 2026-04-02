import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/category.dart' as domain;
import '../../providers/database_provider.dart';
import '../../providers/categories_provider.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Gestion de categorias',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 24)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No hay categorias'));
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            itemCount: categories.length,
            onReorder: (oldIdx, newIdx) async {
              if (newIdx > oldIdx) newIdx--;
              final repo = ref.read(productRepositoryProvider);
              final reordered = List<domain.Category>.from(categories);
              final item = reordered.removeAt(oldIdx);
              reordered.insert(newIdx, item);

              for (int i = 0; i < reordered.length; i++) {
                await repo.updateCategory(domain.Category(
                  id: reordered[i].id,
                  name: reordered[i].name,
                  imageUrl: reordered[i].imageUrl,
                  sortOrder: i,
                ));
              }
              ref.invalidate(categoriesProvider);
            },
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                key: ValueKey(cat.id),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(AppSpacing.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_handle,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant,
                          color: AppColors.textOnPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(cat.name,
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () =>
                          _showCategoryDialog(context, ref, category: cat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar categoria'),
                            content: Text(
                                'Eliminar "${cat.name}"? Los productos de esta categoria quedaran sin categoria.'),
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
                                    style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(productRepositoryProvider)
                              .deleteCategory(cat.id);
                          ref.invalidate(categoriesProvider);
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
        error: (_, _) =>
            const Center(child: Text('Error al cargar categorias')),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref,
      {domain.Category? category}) {
    final controller = TextEditingController(text: category?.name ?? '');
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Editar categoria' : 'Nueva categoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final repo = ref.read(productRepositoryProvider);
              if (isEdit) {
                await repo.updateCategory(domain.Category(
                  id: category.id,
                  name: name,
                  imageUrl: category.imageUrl,
                  sortOrder: category.sortOrder,
                ));
              } else {
                await repo.insertCategory(domain.Category(
                  id: 'cat_${DateTime.now().microsecondsSinceEpoch}',
                  name: name,
                  imageUrl: 'https://placehold.co/100',
                ));
              }
              ref.invalidate(categoriesProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(isEdit ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }
}
