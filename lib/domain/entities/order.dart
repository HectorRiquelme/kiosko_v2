import 'cart_item.dart';

enum OrderStatus { pending, preparing, ready, delivered, cancelled }

enum PaymentMethod { cash, card, transfer }

class Order {
  final String id;
  final List<CartItem> items;
  final int totalInCents;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final int queueNumber;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    required this.totalInCents,
    required this.status,
    required this.paymentMethod,
    required this.queueNumber,
    required this.createdAt,
  });

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      items: items,
      totalInCents: totalInCents,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      queueNumber: queueNumber,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
