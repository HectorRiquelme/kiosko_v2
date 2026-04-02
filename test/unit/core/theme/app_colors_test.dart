import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('primary color has correct hex value', () {
      expect(AppColors.primary.toARGB32(), equals(0xFFFF9B17));
    });

    test('primaryDark color has correct hex value', () {
      expect(AppColors.primaryDark.toARGB32(), equals(0xFFFF4D03));
    });

    test('all solid colors have full opacity', () {
      expect(AppColors.primary.a, equals(1.0));
      expect(AppColors.textPrimary.a, equals(1.0));
      expect(AppColors.backgroundWhite.a, equals(1.0));
      expect(AppColors.error.a, equals(1.0));
      expect(AppColors.success.a, equals(1.0));
    });

    test('shadow color has 25% opacity', () {
      expect(AppColors.shadow.a, closeTo(0.25, 0.01));
    });

    test('promo colors are distinct', () {
      expect(AppColors.promoRed, isNot(equals(AppColors.promoBrown)));
      expect(AppColors.promoRed, isNot(equals(AppColors.promoOrange)));
    });

    test('text on primary is white for contrast', () {
      expect(AppColors.textOnPrimary, equals(const Color(0xFFFFFFFF)));
      expect(AppColors.textOnDark, equals(const Color(0xFFFFFFFF)));
    });
  });
}
