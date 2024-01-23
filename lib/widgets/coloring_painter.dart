import 'dart:ui';

import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  final Map<Color, List<Offset>> coloredPoints;
  final double strokeWidth;

  MyPainter(this.coloredPoints, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in coloredPoints.entries) {
      final paint = Paint()
        ..color = entry.key
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      final points = entry.value;
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
          canvas.drawLine(points[i], points[i + 1], paint);
        } else if (points[i] == Offset.infinite &&
            points[i + 1] != Offset.infinite) {
          // Move to the start of a new stroke
          canvas.drawPoints(PointMode.points, [points[i + 1]], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
