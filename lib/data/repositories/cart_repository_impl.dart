import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  Cart _cart = const Cart();

  @override
  Cart getCart() => _cart;

  @override
  Cart addToCart(Product product) {
    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.product.id == product.id);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }

    _cart = _cart.copyWith(items: items);
    return _cart;
  }

  @override
  Cart removeFromCart(String productId) {
    _cart = _cart.copyWith(
      items: _cart.items.where((i) => i.product.id != productId).toList(),
    );
    return _cart;
  }

  @override
  Cart incrementItem(String productId) {
    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
      _cart = _cart.copyWith(items: items);
    }
    return _cart;
  }

  @override
  Cart decrementItem(String productId) {
    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (items[idx].quantity <= 1) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: items[idx].quantity - 1);
      }
      _cart = _cart.copyWith(items: items);
    }
    return _cart;
  }

  @override
  Cart clearCart() {
    _cart = const Cart();
    return _cart;
  }
}
