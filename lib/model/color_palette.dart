import 'package:flutter/material.dart';

class ColorPalette {
  final String paletteId;
  final String name;
  final List<Color> colors;
  final int price;

  ColorPalette({
    required this.paletteId,
    required this.name,
    required this.colors,
    required this.price,
  });
}
