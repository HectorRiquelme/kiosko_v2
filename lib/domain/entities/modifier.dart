class ProductModifierOption {
  final int? id;
  final String productId;
  final String group;
  final String name;
  final int priceAdjustCents;
  final int sortOrder;
  final bool isDefault;

  const ProductModifierOption({
    this.id,
    required this.productId,
    required this.group,
    required this.name,
    this.priceAdjustCents = 0,
    this.sortOrder = 0,
    this.isDefault = false,
  });

  bool get hasPriceAdjust => priceAdjustCents != 0;
}

class SelectedModifier {
  final String group;
  final String name;
  final int priceAdjustCents;

  const SelectedModifier({
    required this.group,
    required this.name,
    this.priceAdjustCents = 0,
  });
}

class ModifierGroup {
  final String name;
  final List<ProductModifierOption> options;

  const ModifierGroup({required this.name, required this.options});
}
