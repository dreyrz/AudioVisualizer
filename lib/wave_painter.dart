import 'dart:ui';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final BuildContext context;

  final List<int> samples;

  WavePainter(
    this.context, {
    required this.samples,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (samples.isEmpty) {
      return;
    }
    canvas.translate(0, size.height / 2);
    final points = toPoints(samples, size);
    // final path = Path();
    // path.addPolygon(points, false);

    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  // Maps a list of ints and their indices to a list of points on a cartesian grid
  List<Offset> toPoints(List<int> samples, Size size) {
    final points = <Offset>[];

    for (int i = 0; i < size.width; i++) {
      if (i % 3 == 0) {
        final dy = size.height * 0.001 * samples[i] / 100;
        final point = Offset(i.toDouble(), dy);
        points.add(point);
      }
    }
    return points;
  }
}
