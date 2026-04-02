import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/modifier.dart';
import '../../domain/entities/product.dart';
import 'database_provider.dart';

class CartNotifier extends StateNotifier<Cart> {
  final Ref _ref;

  CartNotifier(this._ref) : super(const Cart());

  void addToCart(Product product,
      {List<SelectedModifier> modifiers = const [],
      int modifierPriceAdjustCents = 0}) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.addToCart(product,
        modifiers: modifiers,
        modifierPriceAdjustCents: modifierPriceAdjustCents);
  }

  void removeFromCart(String cartKey) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.removeFromCart(cartKey);
  }

  void incrementItem(String cartKey) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.incrementItem(cartKey);
  }

  void decrementItem(String cartKey) {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.decrementItem(cartKey);
  }

  void clearCart() {
    final repo = _ref.read(cartRepositoryProvider);
    state = repo.clearCart();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier(ref);
});
