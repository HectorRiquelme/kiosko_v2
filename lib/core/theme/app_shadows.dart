import 'package:flutter/material.dart';

abstract class AppShadows {
  static List<BoxShadow> searchBar = const [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 2,
      spreadRadius: 3,
    ),
  ];

  static List<BoxShadow> productCard = const [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4,
      offset: Offset(0, -4),
    ),
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevated = const [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}
