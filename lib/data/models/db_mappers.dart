import '../../domain/entities/category.dart' as domain;
import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/order.dart' as domain;
import '../datasources/app_database.dart';
import 'package:drift/drift.dart';

extension CategoryMapper on Category {
  domain.Category toEntity() {
    return domain.Category(
      id: id,
      name: name,
      imageUrl: imageUrl,
      sortOrder: sortOrder,
    );
  }
}

extension ProductMapper on Product {
  domain.Product toEntity() {
    return domain.Product(
      id: id,
      name: name,
      imageUrl: imageUrl,
      priceInCents: priceInCents,
      categoryId: categoryId,
      description: description,
      available: available,
    );
  }
}

extension DomainProductMapper on domain.Product {
  ProductsCompanion toCompanion() {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: Value(imageUrl),
      priceInCents: Value(priceInCents),
      categoryId: Value(categoryId),
      description: Value(description),
      available: Value(available),
    );
  }
}

extension DomainCategoryMapper on domain.Category {
  CategoriesCompanion toCompanion() {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: Value(imageUrl),
      sortOrder: Value(sortOrder),
    );
  }
}

domain.OrderStatus parseOrderStatus(String s) {
  return domain.OrderStatus.values.firstWhere(
    (e) => e.name == s,
    orElse: () => domain.OrderStatus.pending,
  );
}

domain.PaymentMethod parsePaymentMethod(String s) {
  return domain.PaymentMethod.values.firstWhere(
    (e) => e.name == s,
    orElse: () => domain.PaymentMethod.cash,
  );
}
