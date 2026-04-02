import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/modifier.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  Cart _cart = const Cart();

  @override
  Cart getCart() => _cart;

  @override
  Cart addToCart(Product product,
      {List<SelectedModifier> modifiers = const [],
      int modifierPriceAdjustCents = 0}) {
    final newItem = CartItem(
      product: product,
      quantity: 1,
      modifiers: modifiers,
      modifierPriceAdjustCents: modifierPriceAdjustCents,
    );

    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.cartKey == newItem.cartKey);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(newItem);
    }

    _cart = _cart.copyWith(items: items);
    return _cart;
  }

  @override
  Cart removeFromCart(String cartKey) {
    _cart = _cart.copyWith(
      items: _cart.items.where((i) => i.cartKey != cartKey).toList(),
    );
    return _cart;
  }

  @override
  Cart incrementItem(String cartKey) {
    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.cartKey == cartKey);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
      _cart = _cart.copyWith(items: items);
    }
    return _cart;
  }

  @override
  Cart decrementItem(String cartKey) {
    final items = List<CartItem>.from(_cart.items);
    final idx = items.indexWhere((i) => i.cartKey == cartKey);
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
