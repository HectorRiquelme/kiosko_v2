class Promo {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String backgroundColor;
  final int discountPercent;
  final int discountAmountCents;
  final List<String> productIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;

  const Promo({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl = '',
    this.backgroundColor = '#AC0E02',
    this.discountPercent = 0,
    this.discountAmountCents = 0,
    this.productIds = const [],
    this.startDate,
    this.endDate,
    this.active = true,
  });

  bool get isPercentDiscount => discountPercent > 0;
  bool get isAmountDiscount => discountAmountCents > 0;

  bool get isCurrentlyActive {
    if (!active) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  int calculateDiscount(int priceInCents) {
    if (isPercentDiscount) {
      return (priceInCents * discountPercent) ~/ 100;
    }
    if (isAmountDiscount) {
      return discountAmountCents > priceInCents
          ? priceInCents
          : discountAmountCents;
    }
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Promo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
