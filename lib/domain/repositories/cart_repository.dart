import '../entities/cart.dart';
import '../entities/product.dart';
import '../entities/modifier.dart';

abstract class CartRepository {
  Cart getCart();
  Cart addToCart(Product product, {List<SelectedModifier> modifiers, int modifierPriceAdjustCents});
  Cart removeFromCart(String cartKey);
  Cart incrementItem(String cartKey);
  Cart decrementItem(String cartKey);
  Cart clearCart();
}
