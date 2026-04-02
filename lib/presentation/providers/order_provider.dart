import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/audit_log_entry.dart';
import '../../domain/usecases/place_order.dart';
import '../../data/services/audit_logger.dart';
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
      _ref.read(cartProvider.notifier).clearCart();
      state = AsyncValue.data(order);

      // Audit log the sale
      final formatter = NumberFormat('#,###', 'es_CL');
      final total = formatter.format(order.totalInCents ~/ 100);
      await AuditLogger.log(
        _ref,
        action: AuditAction.sale,
        entityType: AuditEntityType.order,
        entityId: order.id,
        entityName: 'Pedido #${order.queueNumber}',
        details: '\$$total - ${paymentMethod.name} - ${order.items.length} items',
      );

      return order;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
