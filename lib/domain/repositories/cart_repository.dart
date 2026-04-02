import '../entities/cart.dart';
import '../entities/product.dart';

abstract class CartRepository {
  Cart getCart();
  Cart addToCart(Product product);
  Cart removeFromCart(String productId);
  Cart incrementItem(String productId);
  Cart decrementItem(String productId);
  Cart clearCart();
}
