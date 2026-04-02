import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // === HEADLINES ===
  static TextStyle headline1 = GoogleFonts.outfit(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
  );

  static TextStyle headline2 = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle headline3 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark,
  );

  // === PROMO CARDS (Poppins) ===
  static TextStyle promoTitle = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textOnPrimary,
  );

  static TextStyle promoSubtitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.textOnPrimary,
  );

  // === BODY ===
  static TextStyle bodyLarge = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  // === LABELS ===
  static TextStyle categoryLabel = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle productName = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle price = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // === BUTTONS ===
  static TextStyle buttonSmall = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
  );

  static TextStyle buttonLarge = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}
