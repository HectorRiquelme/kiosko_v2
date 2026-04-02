class Product {
  final String id;
  final String name;
  final String imageUrl;
  final int priceInCents;
  final String categoryId;
  final String? description;
  final bool available;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.priceInCents,
    required this.categoryId,
    this.description,
    this.available = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
