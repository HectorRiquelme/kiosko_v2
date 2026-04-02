import 'package:drift/drift.dart';
import '../../domain/entities/order.dart' as domain;
import '../../domain/entities/product.dart' as domain_product;
import '../../domain/entities/cart_item.dart' as domain_cart;
import '../../domain/repositories/order_repository.dart';
import '../datasources/app_database.dart';
import '../models/db_mappers.dart';

class OrderRepositoryImpl implements OrderRepository {
  final AppDatabase _db;

  OrderRepositoryImpl(this._db);

  @override
  Future<domain.Order> placeOrder(domain.Order order) async {
    await _db.transaction(() async {
      await _db.into(_db.orders).insert(OrdersCompanion(
            id: Value(order.id),
            totalInCents: Value(order.totalInCents),
            status: Value(order.status.name),
            paymentMethod: Value(order.paymentMethod.name),
            queueNumber: Value(order.queueNumber),
            createdAt: Value(order.createdAt),
          ));

      for (final item in order.items) {
        await _db.into(_db.orderItems).insert(OrderItemsCompanion(
              orderId: Value(order.id),
              productId: Value(item.product.id),
              quantity: Value(item.quantity),
              priceInCents: Value(item.product.priceInCents),
            ));
      }
    });
    return order;
  }

  @override
  Future<List<domain.Order>> getAllOrders() async {
    final orderRows = await _db.select(_db.orders).get();
    final result = <domain.Order>[];

    for (final row in orderRows) {
      final items = await _getOrderItems(row.id);
      result.add(domain.Order(
        id: row.id,
        items: items,
        totalInCents: row.totalInCents,
        status: parseOrderStatus(row.status),
        paymentMethod: parsePaymentMethod(row.paymentMethod),
        queueNumber: row.queueNumber,
        createdAt: row.createdAt,
      ));
    }
    return result;
  }

  @override
  Future<domain.Order?> getOrderById(String id) async {
    final row = await (_db.select(_db.orders)
          ..where((o) => o.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;

    final items = await _getOrderItems(row.id);
    return domain.Order(
      id: row.id,
      items: items,
      totalInCents: row.totalInCents,
      status: parseOrderStatus(row.status),
      paymentMethod: parsePaymentMethod(row.paymentMethod),
      queueNumber: row.queueNumber,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<int> getNextQueueNumber() async {
    // Reset queue number daily — only count today's orders
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final startEpoch = startOfDay.millisecondsSinceEpoch ~/ 1000;
    final result = await _db.customSelect(
      'SELECT COALESCE(MAX(queue_number), 0) + 1 AS next FROM orders '
      'WHERE created_at >= ?',
      variables: [Variable.withInt(startEpoch)],
    ).getSingle();
    return result.read<int>('next');
  }

  @override
  Future<void> updateOrderStatus(
      String id, domain.OrderStatus status) async {
    await (_db.update(_db.orders)..where((o) => o.id.equals(id)))
        .write(OrdersCompanion(status: Value(status.name)));
  }

  Future<List<domain_cart.CartItem>> _getOrderItems(String orderId) async {
    final itemRows = await (_db.select(_db.orderItems)
          ..where((i) => i.orderId.equals(orderId)))
        .get();

    final items = <domain_cart.CartItem>[];
    for (final itemRow in itemRows) {
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(itemRow.productId)))
          .getSingleOrNull();

      if (product != null) {
        items.add(domain_cart.CartItem(
          product: product.toEntity(),
          quantity: itemRow.quantity,
        ));
      } else {
        // Product was deleted - reconstruct minimal product
        items.add(domain_cart.CartItem(
          product: domain_product.Product(
            id: itemRow.productId,
            name: 'Producto eliminado',
            imageUrl: '',
            priceInCents: itemRow.priceInCents,
            categoryId: '',
          ),
          quantity: itemRow.quantity,
        ));
      }
    }
    return items;
  }
}
