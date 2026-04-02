import 'product.dart';
import 'modifier.dart';

class CartItem {
  final Product product;
  final int quantity;
  final List<SelectedModifier> modifiers;
  final int modifierPriceAdjustCents;

  const CartItem({
    required this.product,
    required this.quantity,
    this.modifiers = const [],
    this.modifierPriceAdjustCents = 0,
  });

  int get unitPriceInCents => product.priceInCents + modifierPriceAdjustCents;
  int get totalInCents => unitPriceInCents * quantity;

  String get modifiersLabel {
    if (modifiers.isEmpty) return '';
    return modifiers.map((m) => m.name).join(', ');
  }

  /// Unique key combining product + modifiers for cart grouping
  String get cartKey {
    final modKey = modifiers.map((m) => '${m.group}:${m.name}').join('|');
    return '${product.id}[$modKey]';
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      modifiers: modifiers,
      modifierPriceAdjustCents: modifierPriceAdjustCents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          cartKey == other.cartKey;

  @override
  int get hashCode => cartKey.hashCode;
}
