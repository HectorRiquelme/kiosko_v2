import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/product.dart';
import 'database_provider.dart';

class CartNotifier extends StateNotifier<Cart> {
  final Ref _ref;

  CartNotifier(this._ref) : super(const Cart());

  void addToCart(Product product) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.addToCart(product);
  }

  void removeFromCart(String productId) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.removeFromCart(productId);
  }

  void incrementItem(String productId) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.incrementItem(productId);
  }

  void decrementItem(String productId) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.decrementItem(productId);
  }

  void clearCart() {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.clearCart();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier(ref);
});
