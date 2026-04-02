import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/animations/app_curves.dart';
import '../../core/animations/app_durations.dart';

class ProductCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int priceInCents;
  final String currencySymbol;
  final VoidCallback onAddToCart;
  final bool isInCart;
  final int quantityInCart;

  const ProductCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.priceInCents,
    this.currencySymbol = '\$',
    required this.onAddToCart,
    this.isInCart = false,
    this.quantityInCart = 0,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _scale = 1.0;

  String get _formattedPrice {
    final formatter = NumberFormat('#,###', 'es_CL');
    final price = widget.priceInCents ~/ 100;
    return '${widget.currencySymbol}${formatter.format(price)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: AppDurations.fast,
      curve: AppCurves.bounce,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 1.03),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            boxShadow: AppShadows.productCard,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.paddingS),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.fastfood,
                            color: AppColors.textSecondary,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.paddingS,
                    ),
                    child: Text(
                      widget.name,
                      style: AppTypography.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.paddingS,
                      right: AppSpacing.paddingS,
                      bottom: AppSpacing.paddingS,
                    ),
                    child: Text(
                      _formattedPrice,
                      style: AppTypography.price,
                    ),
                  ),
                ],
              ),
              Positioned(
                right: AppSpacing.paddingS,
                bottom: AppSpacing.paddingS,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onAddToCart();
                  },
                  child: Container(
                    width: AppSpacing.iconM,
                    height: AppSpacing.iconM,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isInCart ? Icons.check : Icons.add,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (widget.isInCart && widget.quantityInCart > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.quantityInCart}',
                      style: AppTypography.buttonSmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
