import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import 'database_provider.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isNotEmpty) {
    return repo.searchProducts(query);
  }
  if (categoryId != null) {
    return repo.getProductsByCategory(categoryId);
  }
  return repo.getAllProducts();
});
