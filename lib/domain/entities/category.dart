class Category {
  final String id;
  final String name;
  final String imageUrl;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
