import 'package:cloud_firestore/cloud_firestore.dart';

class ColoringPage {
  // Map<Color, List<Offset>> coloredPoints;
  // double strokeWidth;
  // Timestamp timestamp;

  // ColoringPage(
  //     {required this.coloredPoints,
  //     required this.strokeWidth,
  //     required this.timestamp});

  // factory ColoringPage.fromMap(Map<String, dynamic> map) {
  //   final Map<String, dynamic> coloredPoints = map['coloredPoints'];
  //   final Map<Color, List<Offset>> convertedColoredPoints =
  //       coloredPoints.map((key, value) {
  //     return MapEntry(
  //       Color(int.parse(key)),
  //       (value as List<dynamic>)
  //           .map((offset) => Offset(offset[0], offset[1]))
  //           .toList(),
  //     );
  //   });

  //   return ColoringPage(
  //       coloredPoints: convertedColoredPoints,
  //       strokeWidth: map['strokeWidth'],
  //       timestamp: map['timestamp']);
  // }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'coloredPoints': coloredPoints.map((color, points) {
  //       return MapEntry(
  //         '${color.value}',
  //         points.map((offset) => [offset.dx, offset.dy]).toList(),
  //       );
  //     }),
  //     'strokeWidth': strokeWidth,
  //     'timestamp': timestamp
  //   };
  // }

  String imageURL;
  Timestamp timestamp;

  ColoringPage({required this.imageURL, required this.timestamp});

  factory ColoringPage.fromMap(Map<String, dynamic> map) {
    return ColoringPage(
      imageURL: map['imageURL'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageURL': imageURL,
      'timestamp': timestamp,
    };
  }
}
