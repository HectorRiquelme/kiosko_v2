import 'cart_item.dart';

class Cart {
  final List<CartItem> items;

  const Cart({this.items = const []});

  int get totalInCents =>
      items.fold(0, (sum, item) => sum + item.totalInCents);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool containsProduct(String productId) =>
      items.any((item) => item.product.id == productId);

  int quantityOf(String productId) {
    final item = items.where((i) => i.product.id == productId);
    return item.isEmpty ? 0 : item.first.quantity;
  }

  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }
}
