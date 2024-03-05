import 'package:flutter/material.dart';

import '../model/color_palette.dart';
import 'colors.dart';

final huePalette = ColorPalette(
  paletteId: 'hue000',
  name: 'Hue Palette',
  colors: [customPurple, customAzure, customYellow, customLilac, customWhite],
  price: 0,
);

final springPalette = ColorPalette(
  paletteId: 'spring001',
  name: 'Spring Palette',
  colors: [
    Colors.pink,
    Colors.orange,
    Colors.green,
    Colors.blue[300]!,
    Colors.yellow[500]!,
  ],
  price: 20,
);

final autumnPalette = ColorPalette(
  paletteId: 'autumn002',
  name: 'Autumn Palette',
  colors: [
    Colors.amber,
    Colors.brown,
    Colors.red[800]!,
    Colors.deepOrange,
    Colors.green[900]!,
  ],
  price: 20,
);

final serenityPalette = ColorPalette(
  paletteId: 'serenity003',
  name: 'Serenity Palette',
  colors: [
    const Color(0xffF7CAC9),
    const Color(0xffffdcdb),
    Colors.white,
    const Color(0xffb4c8ea),
    const Color(0xff91a8d0),
  ],
  price: 25,
);

final calmPalette = ColorPalette(
  paletteId: 'calm004',
  name: 'Calm Palette',
  colors: [
    const Color(0xff9ab69d),
    const Color(0xff564f6d),
    const Color(0xff8bc5c9),
    const Color(0xffd0d6ad),
    const Color(0xffc1bf8a),
  ],
  price: 25,
);

final wildflowerPalette = ColorPalette(
  paletteId: 'wildflower005',
  name: 'Wildflower Palette',
  colors: [
    const Color(0xff243127),
    const Color(0xffa46379),
    const Color(0xfffeb640),
    const Color(0xffffdf7c),
    const Color(0xfffdefc0),
  ],
  price: 30,
);

final earthPalette = ColorPalette(
  paletteId: 'earth004',
  name: 'Earth Palette',
  colors: [
    const Color(0xff4e4d49),
    const Color(0xff725e45),
    const Color(0xffb7946a),
    const Color(0xffe2c58d),
    const Color(0xffd6cfbf),
  ],
  price: 30,
);

final List<ColorPalette> colorPalettes = [
  huePalette,
  springPalette,
  autumnPalette,
  serenityPalette,
  calmPalette,
  wildflowerPalette,
  earthPalette
];
