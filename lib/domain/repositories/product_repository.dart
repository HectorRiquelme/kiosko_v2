import '../entities/product.dart';
import '../entities/category.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> searchProducts(String query);
  Future<Product?> getProductById(String id);
  Future<List<Category>> getAllCategories();
  Future<void> insertProduct(Product product);
  Future<void> insertCategory(Category category);
}
