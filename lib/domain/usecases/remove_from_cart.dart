import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCart {
  final CartRepository _repository;

  RemoveFromCart(this._repository);

  Cart call(String productId) => _repository.removeFromCart(productId);
}
