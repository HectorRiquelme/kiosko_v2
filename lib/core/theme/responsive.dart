import 'package:flutter/material.dart';

/// Scales design values from Figma (designed at 1080px width) to actual screen.
/// Usage: context.scaled(65) returns the font size scaled to current screen.
class Responsive {
  static const double _designWidth = 1080.0;

  static double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width / _designWidth;
  }

  static double value(BuildContext context, double designValue) {
    return designValue * scale(context);
  }
}

extension ResponsiveExtension on BuildContext {
  double scaled(double value) => Responsive.value(this, value);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
