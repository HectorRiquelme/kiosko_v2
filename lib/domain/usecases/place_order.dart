import '../entities/order.dart';
import '../repositories/order_repository.dart';
import '../repositories/cart_repository.dart';

class PlaceOrder {
  final OrderRepository _orderRepository;
  final CartRepository _cartRepository;

  PlaceOrder(this._orderRepository, this._cartRepository);

  Future<Order> call(PaymentMethod paymentMethod) async {
    final cart = _cartRepository.getCart();
    if (cart.isEmpty) {
      throw StateError('Cannot place order with empty cart');
    }

    final queueNumber = await _orderRepository.getNextQueueNumber();
    final order = Order(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      items: List.unmodifiable(cart.items),
      totalInCents: cart.totalInCents,
      status: OrderStatus.pending,
      paymentMethod: paymentMethod,
      queueNumber: queueNumber,
      createdAt: DateTime.now(),
    );

    final placed = await _orderRepository.placeOrder(order);
    _cartRepository.clearCart();
    return placed;
  }
}
