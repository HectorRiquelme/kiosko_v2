import 'package:drift/drift.dart';
import '../../domain/entities/modifier.dart';
import '../datasources/app_database.dart';

class ModifierRepository {
  final AppDatabase _db;

  ModifierRepository(this._db);

  Future<List<ModifierGroup>> getModifiersForProduct(String productId) async {
    final rows = await (_db.select(_db.productModifiers)
          ..where((m) => m.productId.equals(productId))
          ..orderBy([
            (m) => OrderingTerm.asc(m.group),
            (m) => OrderingTerm.asc(m.sortOrder),
          ]))
        .get();

    final groups = <String, List<ProductModifierOption>>{};
    for (final row in rows) {
      final option = ProductModifierOption(
        id: row.id,
        productId: row.productId,
        group: row.group,
        name: row.name,
        priceAdjustCents: row.priceAdjustCents,
        sortOrder: row.sortOrder,
        isDefault: row.isDefault,
      );
      groups.putIfAbsent(row.group, () => []).add(option);
    }

    return groups.entries
        .map((e) => ModifierGroup(name: e.key, options: e.value))
        .toList();
  }

  Future<void> saveOrderItemModifiers(
      int orderItemId, List<SelectedModifier> modifiers) async {
    for (final mod in modifiers) {
      await _db.into(_db.orderItemModifiers).insert(
            OrderItemModifiersCompanion(
              orderItemId: Value(orderItemId),
              modifierName: Value(mod.name),
              modifierGroup: Value(mod.group),
              priceAdjustCents: Value(mod.priceAdjustCents),
            ),
          );
    }
  }

  Future<List<SelectedModifier>> getOrderItemModifiers(int orderItemId) async {
    final rows = await (_db.select(_db.orderItemModifiers)
          ..where((m) => m.orderItemId.equals(orderItemId)))
        .get();
    return rows
        .map((r) => SelectedModifier(
              group: r.modifierGroup,
              name: r.modifierName,
              priceAdjustCents: r.priceAdjustCents,
            ))
        .toList();
  }
}
