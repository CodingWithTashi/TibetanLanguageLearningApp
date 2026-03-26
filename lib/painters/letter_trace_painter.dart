import 'dart:math';
import 'package:flutter/material.dart';
import '../model/letter_trace_data.dart';
import '../util/trace_geometry.dart';

/// Painter for the ghost letter (guide letter in background)
class GhostLetterPainter extends CustomPainter {
  final Letter letter;
  final double canvasSize;
  final double opacity;

  GhostLetterPainter({
    required this.letter,
    required this.canvasSize,
    this.opacity = TraceConstants.ghostLetterOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = TraceConstants.strokeWidth * 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw each stroke
    for (final stroke in letter.strokes) {
      _drawStroke(canvas, stroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.isEmpty) return;

    final path = Path();
    final firstPoint = stroke.points.first.toOffset(canvasSize);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      final point = stroke.points[i].toOffset(canvasSize);
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GhostLetterPainter oldDelegate) {
    return oldDelegate.letter != letter ||
        oldDelegate.canvasSize != canvasSize ||
        oldDelegate.opacity != opacity;
  }
}

/// Painter for stroke guide (dotted lines showing direction)
class StrokeGuidePainter extends CustomPainter {
  final Letter letter;
  final double canvasSize;
  final int currentStrokeIndex;
  final List<bool> completedStrokes;

  StrokeGuidePainter({
    required this.letter,
    required this.canvasSize,
    required this.currentStrokeIndex,
    required this.completedStrokes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guide for current incomplete stroke
    if (currentStrokeIndex >= 0 && currentStrokeIndex < letter.strokes.length) {
      _drawStrokeGuide(
        canvas,
        letter.strokes[currentStrokeIndex],
        isCurrent: true,
      );
    }

    // Draw dim guides for upcoming strokes
    for (int i = currentStrokeIndex + 1; i < letter.strokes.length; i++) {
      _drawStrokeGuide(
        canvas,
        letter.strokes[i],
        isCurrent: false,
      );
    }
  }

  void _drawStrokeGuide(Canvas canvas, Stroke stroke, {required bool isCurrent}) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = isCurrent
          ? Colors.blue.withOpacity(0.5)
          : Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCurrent ? TraceConstants.guideStrokeWidth : 1.0;

    // Create dotted effect
    final path = Path();
    final firstPoint = stroke.points.first.toOffset(canvasSize);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      final point = stroke.points[i].toOffset(canvasSize);
      path.lineTo(point.dx, point.dy);
    }

    final dashPath = _createDashedPath(path, isCurrent ? 8.0 : 4.0, isCurrent ? 4.0 : 2.0);
    canvas.drawPath(dashPath, paint);

    // Draw arrow at end for current stroke
    if (isCurrent && stroke.points.length >= 2) {
      _drawDirectionArrow(canvas, stroke);
    }
  }

  void _drawDirectionArrow(Canvas canvas, Stroke stroke) {
    if (stroke.points.length < 2) return;

    // Get last two points to determine direction
    final lastPoint = stroke.points.last.toOffset(canvasSize);
    final secondLastPoint = stroke.points[stroke.points.length - 2].toOffset(canvasSize);

    // Calculate angle
    final dx = lastPoint.dx - secondLastPoint.dx;
    final dy = lastPoint.dy - secondLastPoint.dy;
    final angle = atan2(dy, dx);

    // Draw arrow
    final arrowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final arrowSize = 10.0;
    final arrowPath = Path();

    // Arrow tip at last point
    arrowPath.moveTo(lastPoint.dx, lastPoint.dy);

    // Arrow wings
    arrowPath.lineTo(
      lastPoint.dx - arrowSize * cos(angle - pi / 6),
      lastPoint.dy - arrowSize * sin(angle - pi / 6),
    );
    arrowPath.lineTo(
      lastPoint.dx - arrowSize * cos(angle + pi / 6),
      lastPoint.dy - arrowSize * sin(angle + pi / 6),
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;

      while (distance < metric.length) {
        final double len = draw ? dashWidth : dashSpace;
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(StrokeGuidePainter oldDelegate) {
    return oldDelegate.currentStrokeIndex != currentStrokeIndex ||
        oldDelegate.completedStrokes.length != completedStrokes.length;
  }
}

/// Painter for waypoints (numbered indicators)
class WaypointPainter extends CustomPainter {
  final List<Waypoint> waypoints;
  final double canvasSize;
  final int currentStrokeIndex;
  final int currentWaypointIndex;

  WaypointPainter({
    required this.waypoints,
    required this.canvasSize,
    this.currentStrokeIndex = 0,
    this.currentWaypointIndex = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final waypoint in waypoints) {
      _drawWaypoint(canvas, waypoint);
    }
  }

  void _drawWaypoint(Canvas canvas, Waypoint waypoint) {
    final offset = waypoint.toOffset(canvasSize);
    final isCurrent = waypoint.number <= currentWaypointIndex + 1;

    // Outer circle
    final outerPaint = Paint()
      ..color = isCurrent ? Colors.blue : Colors.grey
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      offset,
      TraceConstants.waypointRadius * (isCurrent ? 1.0 : 0.8),
      outerPaint,
    );

    // Inner circle
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      offset,
      TraceConstants.waypointRadius * 0.7,
      innerPaint,
    );

    // Number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: waypoint.number.toString(),
        style: TextStyle(
          color: isCurrent ? Colors.blue : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );

    // Special indicators for start/end
    if (waypoint.isStart) {
      _drawStartIndicator(canvas, offset);
    } else if (waypoint.isEnd) {
      _drawEndIndicator(canvas, offset);
    }
  }

  void _drawStartIndicator(Canvas canvas, Offset offset) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      offset,
      TraceConstants.waypointRadius + 4,
      paint,
    );
  }

  void _drawEndIndicator(Canvas canvas, Offset offset) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      offset,
      TraceConstants.waypointRadius + 4,
      paint,
    );
  }

  @override
  bool shouldRepaint(WaypointPainter oldDelegate) {
    return oldDelegate.waypoints.length != waypoints.length ||
        oldDelegate.currentWaypointIndex != currentWaypointIndex;
  }
}

/// Painter for user's tracing with fog-of-war effect
class UserTracePainter extends CustomPainter {
  final List<List<Offset>> drawnStrokes;
  final List<Offset> currentDrawing;
  final List<bool> completedStrokes;
  final bool isOffPath;
  final double canvasSize;

  UserTracePainter({
    required this.drawnStrokes,
    required this.currentDrawing,
    required this.completedStrokes,
    this.isOffPath = false,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (int i = 0; i < drawnStrokes.length; i++) {
      if (completedStrokes[i] && drawnStrokes[i].isNotEmpty) {
        _drawStroke(
          canvas,
          drawnStrokes[i],
          Colors.green,
          TraceConstants.strokeWidth,
        );
      }
    }

    // Draw current stroke
    if (currentDrawing.isNotEmpty) {
      _drawStroke(
        canvas,
        currentDrawing,
        isOffPath ? Colors.red : Colors.blue,
        TraceConstants.strokeWidth,
      );
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Color color, double width) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Draw smooth curve through points
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
    } else if (points.length > 2) {
      // Use quadratic bezier for smooth curves
      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midPoint = Offset(
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
        path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
      }
      // Connect to last point
      path.lineTo(points.last.dx, points.last.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(UserTracePainter oldDelegate) {
    return true; // Always repaint for smooth drawing
  }
}

/// Painter for start/end point indicators
class StartEndIndicatorPainter extends CustomPainter {
  final Offset? startPoint;
  final Offset? endPoint;
  final double radius;

  StartEndIndicatorPainter({
    this.startPoint,
    this.endPoint,
    this.radius = 15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw start indicator (green)
    if (startPoint != null) {
      _drawIndicator(canvas, startPoint!, Colors.green, 'START');
    }

    // Draw end indicator (red)
    if (endPoint != null) {
      _drawIndicator(canvas, endPoint!, Colors.red, 'END');
    }
  }

  void _drawIndicator(Canvas canvas, Offset offset, Color color, String label) {
    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(offset, radius + 5, glowPaint);

    // Main circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offset, radius, paint);

    // Inner white circle
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offset, radius - 3, innerPaint);

    // Label (only for longer labels)
    if (label.length > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label[0],
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(StartEndIndicatorPainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint;
  }
}

/// Painter for grid background
class GridBackgroundPainter extends CustomPainter {
  final double gridSize;
  final Color lineColor;
  final double lineWidth;

  GridBackgroundPainter({
    this.gridSize = 40,
    this.lineColor = const Color(0xFFEEEEEE),
    this.lineWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridBackgroundPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.lineColor != lineColor;
  }
}

/// Painter for progress ring
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    this.color = Colors.blue,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
