import '../repositories/cart_repository.dart';

class CalculateTotal {
  final CartRepository _repository;

  CalculateTotal(this._repository);

  int call() => _repository.getCart().totalInCents;
}
