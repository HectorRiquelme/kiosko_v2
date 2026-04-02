import 'package:flutter/animation.dart';

abstract class AppCurves {
  static const Curve defaultEase = Curves.easeOutCubic;
  static const Curve bounce = Curves.easeOutBack;
  static const Curve sharp = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
}
