import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order> placeOrder(Order order);
  Future<List<Order>> getAllOrders();
  Future<Order?> getOrderById(String id);
  Future<int> getNextQueueNumber();
  Future<void> updateOrderStatus(String id, OrderStatus status);
}
