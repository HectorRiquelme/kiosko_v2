import 'package:flutter/material.dart';

abstract class AppColors {
  // === PRIMARY ===
  static const Color primary = Color(0xFFFF9B17);
  static const Color primaryDark = Color(0xFFFF4D03);
  static const Color primaryLight = Color(0xFFFFF3E0);

  // === BACKGROUNDS ===
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  // === PROMO CARDS ===
  static const Color promoRed = Color(0xFFAC0E02);
  static const Color promoBrown = Color(0xFFA33310);
  static const Color promoOrange = Color(0xFFFF4D03);

  // === TEXT ===
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF949191);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // === BORDERS & SHADOWS ===
  static const Color border = Color(0xFFAA9696);
  static const Color shadow = Color(0x40000000);

  // === STATES ===
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9B17);
}
