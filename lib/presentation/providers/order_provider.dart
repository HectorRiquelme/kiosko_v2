import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/place_order.dart';
import 'database_provider.dart';
import 'cart_provider.dart';

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<Order?>>((ref) {
  return OrderNotifier(ref);
});

class OrderNotifier extends StateNotifier<AsyncValue<Order?>> {
  final Ref _ref;

  OrderNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<Order> placeOrder(PaymentMethod paymentMethod) async {
    state = const AsyncValue.loading();
    try {
      final useCase = PlaceOrder(
        _ref.read(orderRepositoryProvider),
        _ref.read(cartRepositoryProvider),
      );
      final order = await useCase(paymentMethod);
      // Sync cart state after clearing
      _ref.read(cartProvider.notifier).clearCart();
      state = AsyncValue.data(order);
      return order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
