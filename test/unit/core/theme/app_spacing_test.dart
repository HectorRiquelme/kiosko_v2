import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/core/theme/app_spacing.dart';

void main() {
  group('AppSpacing', () {
    test('padding values are in ascending order', () {
      expect(AppSpacing.paddingXS, lessThan(AppSpacing.paddingS));
      expect(AppSpacing.paddingS, lessThan(AppSpacing.paddingM));
      expect(AppSpacing.paddingM, lessThan(AppSpacing.paddingL));
      expect(AppSpacing.paddingL, lessThan(AppSpacing.paddingXL));
    });

    test('gap values are in ascending order', () {
      expect(AppSpacing.gapXS, lessThan(AppSpacing.gapS));
      expect(AppSpacing.gapS, lessThan(AppSpacing.gapM));
      expect(AppSpacing.gapM, lessThan(AppSpacing.gapL));
      expect(AppSpacing.gapL, lessThan(AppSpacing.gapXL));
    });

    test('radius values are in ascending order', () {
      expect(AppSpacing.radiusS, lessThan(AppSpacing.radiusM));
      expect(AppSpacing.radiusM, lessThan(AppSpacing.radiusL));
      expect(AppSpacing.radiusL, lessThan(AppSpacing.radiusXL));
    });

    test('category card size is 110', () {
      expect(AppSpacing.categoryCardSize, equals(110.0));
    });

    test('product card dimensions are correct', () {
      expect(AppSpacing.productCardWidth, equals(170.0));
      expect(AppSpacing.productCardHeight, equals(200.0));
    });

    test('promo card dimensions are correct', () {
      expect(AppSpacing.promoCardWidth, equals(300.0));
      expect(AppSpacing.promoCardHeight, equals(120.0));
    });

    test('all values are positive', () {
      expect(AppSpacing.paddingXS, greaterThan(0));
      expect(AppSpacing.gapXS, greaterThan(0));
      expect(AppSpacing.radiusS, greaterThan(0));
      expect(AppSpacing.iconS, greaterThan(0));
    });
  });
}
