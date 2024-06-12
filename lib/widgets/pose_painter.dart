import 'dart:ui';

import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<Offset> points;

  PosePainter({
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isNotEmpty) {
      var pointPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 8;
      var headPaint = Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 2;
      var leftPaint = Paint()
        ..color = Colors.lightBlue
        ..strokeWidth = 2;
      var rightPaint = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 2;
      var bodyPaint = Paint()
        ..color = Colors.pink
        ..strokeWidth = 2;

      canvas.drawPoints(
        PointMode.points,
        points.sublist(0, 33).toList(),
        pointPaint,
      );

      canvas.drawPoints(
        PointMode.polygon,
        [
          points[8],
          points[6],
          points[5],
          points[4],
          points[0],
          points[1],
          points[2],
          points[3],
          points[7],
        ].toList(),
        headPaint,
      );

      canvas.drawPoints(
        PointMode.polygon,
        [
          points[10],
          points[9],
        ].toList(),
        headPaint,
      );

      canvas.drawPoints(
        PointMode.polygon,
        [
          points[12],
          points[14],
          points[16],
          points[18],
          points[20],
          points[16],
        ].toList(),
        leftPaint,
      );

      canvas.drawPoints(
        PointMode.polygon,
        [
          points[16],
          points[22],
        ].toList(),
        leftPaint,
      );

      canvas.drawPoints(
        PointMode.polygon,
        [
          points[24],
          points[26],
          points[28],
          points[32],
          points[30],
          points[28],
        ].toList(),
        leftPaint,
      );

      canvas.drawPoints(
        PointMode.polygon,
        [
          points[11],
          points[13],
          points[15],
          points[17],
          points[19],
          points[15],
        ].toList(),
        rightPaint,
      );
      canvas.drawPoints(
        PointMode.polygon,
        [
          points[15],
          points[21],
        ].toList(),
        rightPaint,
      );
      canvas.drawPoints(
        PointMode.polygon,
        [
          points[23],
          points[25],
          points[27],
          points[29],
          points[31],
          points[27],
        ],
        rightPaint,
      );

      canvas.drawPoints(
        PointMode.polygon,
        [
          points[11],
          points[12],
          points[24],
          points[23],
          points[11],
        ],
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}