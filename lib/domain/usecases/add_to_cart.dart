import '../entities/cart.dart';
import '../entities/product.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  final CartRepository _repository;

  AddToCart(this._repository);

  Cart call(Product product) => _repository.addToCart(product);
}
