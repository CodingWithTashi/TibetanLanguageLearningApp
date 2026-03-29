import 'dart:math';
import 'package:flutter/material.dart';
import '../model/letter_trace_data.dart';

/// Geometry utilities for letter tracing
class TraceGeometry {
  /// Calculate squared distance from point to line segment
  static double distanceToSegment(
    TracePoint point,
    TracePoint segmentStart,
    TracePoint segmentEnd,
  ) {
    final x = point.x;
    final y = point.y;
    final x1 = segmentStart.x;
    final y1 = segmentStart.y;
    final x2 = segmentEnd.x;
    final y2 = segmentEnd.y;

    final dx = x2 - x1;
    final dy = y2 - y1;

    if (dx == 0 && dy == 0) {
      // Segment is a point
      final dpx = x - x1;
      final dpy = y - y1;
      return dpx * dpx + dpy * dpy;
    }

    // Calculate projection of point onto line (parameter t)
    final t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);

    // Check if projection falls within the segment
    if (t >= 0 && t <= 1) {
      // Closest point is on the segment
      final closestX = x1 + t * dx;
      final closestY = y1 + t * dy;
      final dpx = x - closestX;
      final dpy = y - closestY;
      return dpx * dpx + dpy * dpy;
    } else {
      // Closest point is one of the endpoints
      final d1 = (x - x1) * (x - x1) + (y - y1) * (y - y1);
      final d2 = (x - x2) * (x - x2) + (y - y2) * (y - y2);
      return min(d1, d2);
    }
  }

  /// Find the closest point on a stroke to a given point
  static ClosestPointResult findClosestPointOnStroke(
    TracePoint point,
    Stroke stroke,
  ) {
    if (stroke.points.isEmpty) {
      return ClosestPointResult(
        point: point,
        distance: double.infinity,
        segmentIndex: -1,
        t: 0.0,
      );
    }

    if (stroke.points.length == 1) {
      final dist = point.distanceTo(stroke.points.first);
      return ClosestPointResult(
        point: stroke.points.first,
        distance: dist,
        segmentIndex: 0,
        t: 0.0,
      );
    }

    double minDistance = double.infinity;
    TracePoint closestPoint = stroke.points.first;
    int closestSegment = 0;
    double closestT = 0.0;

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final start = stroke.points[i];
      final end = stroke.points[i + 1];

      final x = point.x;
      final y = point.y;
      final x1 = start.x;
      final y1 = start.y;
      final x2 = end.x;
      final y2 = end.y;

      final dx = x2 - x1;
      final dy = y2 - y1;

      double t = 0.0;
      TracePoint candidate;

      if (dx == 0 && dy == 0) {
        // Segment is a point
        t = 0.0;
        candidate = start;
      } else {
        t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);
        t = t.clamp(0.0, 1.0);

        candidate = TracePoint(
          x: x1 + t * dx,
          y: y1 + t * dy,
        );
      }

      final dist = point.distanceTo(candidate);
      if (dist < minDistance) {
        minDistance = dist;
        closestPoint = candidate;
        closestSegment = i;
        closestT = t;
      }
    }

    return ClosestPointResult(
      point: closestPoint,
      distance: minDistance,
      segmentIndex: closestSegment,
      t: closestT,
    );
  }

  /// Find the closest point on any stroke to a given point
  static ClosestPointResult findClosestPointOnLetter(
    TracePoint point,
    Letter letter,
  ) {
    if (letter.strokes.isEmpty) {
      return ClosestPointResult(
        point: point,
        distance: double.infinity,
        segmentIndex: -1,
        t: 0.0,
      );
    }

    ClosestPointResult? closest;

    for (int strokeIndex = 0; strokeIndex < letter.strokes.length; strokeIndex++) {
      final result = findClosestPointOnStroke(point, letter.strokes[strokeIndex]);
      if (closest == null || result.distance < closest.distance) {
        closest = result;
        closest.strokeIndex = strokeIndex;
      }
    }

    return closest ?? ClosestPointResult(
      point: point,
      distance: double.infinity,
      segmentIndex: -1,
      t: 0.0,
    );
  }

  /// Calculate angle between three points (in degrees)
  static double calculateAngle(
    TracePoint p1,
    TracePoint p2,
    TracePoint p3,
  ) {
    final v1x = p1.x - p2.x;
    final v1y = p1.y - p2.y;
    final v2x = p3.x - p2.x;
    final v2y = p3.y - p2.y;

    final dot = v1x * v2x + v1y * v2y;
    final mag1 = sqrt(v1x * v1x + v1y * v1y);
    final mag2 = sqrt(v2x * v2x + v2y * v2y);

    if (mag1 == 0 || mag2 == 0) return 0.0;

    final cosAngle = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    final angle = acos(cosAngle) * 180 / pi;
    return angle;
  }

  /// Check if a point is a key point (corner)
  static bool isKeyPoint(
    List<TracePoint> points,
    int index,
    double angleThreshold,
  ) {
    if (index <= 0 || index >= points.length - 1) return true;

    final angle = calculateAngle(
      points[index - 1],
      points[index],
      points[index + 1],
    );

    return angle >= angleThreshold;
  }

  /// Generate waypoints along a stroke
  static List<Waypoint> generateWaypoints(
    Stroke stroke,
    int strokeIndex,
    double spacing,
    double angleThreshold,
  ) {
    final waypoints = <Waypoint>[];

    if (stroke.points.isEmpty) return waypoints;

    // Add start point
    waypoints.add(Waypoint(
      point: stroke.points.first,
      strokeIndex: strokeIndex,
      pointIndex: 0,
      isStart: true,
    ));

    // Add key points (corners)
    for (int i = 1; i < stroke.points.length - 1; i++) {
      if (isKeyPoint(stroke.points, i, angleThreshold)) {
        waypoints.add(Waypoint(
          point: stroke.points[i],
          strokeIndex: strokeIndex,
          pointIndex: i,
          isCorner: true,
        ));
      }
    }

    // Add intermediate waypoints along smooth segments
    final double pathLength = stroke.length;
    final int numWaypoints = (pathLength / spacing).round();

    if (numWaypoints > 0 && stroke.points.length > 1) {
      double accumulatedLength = 0.0;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final segmentLength = sqrt(
          pow(stroke.points[i + 1].x - stroke.points[i].x, 2) +
          pow(stroke.points[i + 1].y - stroke.points[i].y, 2),
        );

        while (accumulatedLength + segmentLength >= (waypoints.length) * spacing) {
          final targetLength = (waypoints.length) * spacing - accumulatedLength;
          final t = targetLength / segmentLength;

          final newPoint = TracePoint(
            x: stroke.points[i].x + t * (stroke.points[i + 1].x - stroke.points[i].x),
            y: stroke.points[i].y + t * (stroke.points[i + 1].y - stroke.points[i].y),
          );

          // Only add if not too close to existing waypoints
          bool tooClose = false;
          for (final wp in waypoints) {
            final dist = sqrt(newPoint.distanceTo(wp.point));
            if (dist < spacing / 2) {
              tooClose = true;
              break;
            }
          }

          if (!tooClose) {
            waypoints.add(Waypoint(
              point: newPoint,
              strokeIndex: strokeIndex,
              pointIndex: i,
            ));
          } else {
            break;
          }
        }

        accumulatedLength += segmentLength;
      }
    }

    // Add end point
    waypoints.add(Waypoint(
      point: stroke.points.last,
      strokeIndex: strokeIndex,
      pointIndex: stroke.points.length - 1,
      isEnd: true,
    ));

    // Sort waypoints by position along stroke
    waypoints.sort((a, b) => a.pointIndex.compareTo(b.pointIndex));

    // Renumber
    for (int i = 0; i < waypoints.length; i++) {
      waypoints[i].number = i + 1;
    }

    return waypoints;
  }

  /// Simplify a stroke using Douglas-Peucker algorithm
  static List<TracePoint> simplifyPoints(
    List<TracePoint> points,
    double epsilon,
  ) {
    if (points.length <= 2) return points;

    // Find the point with maximum distance
    double maxDistance = 0.0;
    int maxIndex = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final dist = distanceToSegment(points[i], points.first, points.last);
      if (dist > maxDistance) {
        maxDistance = dist;
        maxIndex = i;
      }
    }

    // If max distance is greater than epsilon, recursively simplify
    if (maxDistance > epsilon) {
      final left = simplifyPoints(points.sublist(0, maxIndex + 1), epsilon);
      final right = simplifyPoints(points.sublist(maxIndex), epsilon);

      // Remove duplicate point
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [points.first, points.last];
    }
  }

  /// Calculate path progress along a stroke
  static double calculateStrokeProgress(
    List<Offset> drawnPoints,
    Stroke stroke,
    double canvasSize,
  ) {
    if (stroke.points.isEmpty || drawnPoints.isEmpty) return 0.0;

    // Convert drawn points to normalized coordinates
    final normalizedDrawnPoints = drawnPoints
        .map((p) => TracePoint.fromOffset(p, canvasSize))
        .toList();

    int coveredPoints = 0;
    final totalPoints = stroke.points.length;

    for (final point in stroke.points) {
      bool isCovered = false;

      for (final drawnPoint in normalizedDrawnPoints) {
        if (point.distanceTo(drawnPoint) < TraceConstants.tolerance * TraceConstants.tolerance) {
          isCovered = true;
          break;
        }
      }

      if (isCovered) coveredPoints++;
    }

    return coveredPoints / totalPoints;
  }

  /// Calculate overall letter completion percentage
  static double calculateLetterProgress(
    List<List<Offset>> drawnStrokes,
    Letter letter,
    double canvasSize,
  ) {
    if (letter.strokes.isEmpty) return 0.0;

    double totalProgress = 0.0;

    for (int i = 0; i < letter.strokes.length; i++) {
      final drawnPoints = i < drawnStrokes.length ? drawnStrokes[i] : <Offset>[];
      final progress = calculateStrokeProgress(drawnPoints, letter.strokes[i], canvasSize);
      totalProgress += progress;
    }

    return totalProgress / letter.strokes.length;
  }

  /// Check if a point is off-path (outside tolerance)
  static bool isOffPath(
    TracePoint point,
    Letter letter,
    int currentStrokeIndex,
    double tolerance,
  ) {
    if (currentStrokeIndex >= letter.strokes.length) return false;

    final stroke = letter.strokes[currentStrokeIndex];
    final result = findClosestPointOnStroke(point, stroke);

    return result.distance > tolerance * tolerance;
  }

  /// Check if stroke order is correct
  static bool isCorrectStrokeOrder(
    int drawnStrokeIndex,
    int expectedStrokeIndex,
  ) {
    return drawnStrokeIndex == expectedStrokeIndex;
  }

  /// Get stroke start point for visual indicator
  static TracePoint? getStrokeStartPoint(Letter letter, int strokeIndex) {
    if (strokeIndex < 0 || strokeIndex >= letter.strokes.length) return null;
    return letter.strokes[strokeIndex].startPoint;
  }

  /// Get stroke end point for visual indicator
  static TracePoint? getStrokeEndPoint(Letter letter, int strokeIndex) {
    if (strokeIndex < 0 || strokeIndex >= letter.strokes.length) return null;
    return letter.strokes[strokeIndex].endPoint;
  }
}

/// Result of finding closest point
class ClosestPointResult {
  final TracePoint point;
  final double distance; // Squared distance
  final int segmentIndex;
  final double t; // Parameter along segment (0-1)
  int strokeIndex;

  ClosestPointResult({
    required this.point,
    required this.distance,
    required this.segmentIndex,
    required this.t,
    this.strokeIndex = 0,
  });

  /// Get actual (non-squared) distance
  double get actualDistance => sqrt(distance);
}

/// Waypoint for visual guidance
class Waypoint {
  final TracePoint point;
  final int strokeIndex;
  final int pointIndex;
  int number;
  final bool isStart;
  final bool isEnd;
  final bool isCorner;

  Waypoint({
    required this.point,
    required this.strokeIndex,
    required this.pointIndex,
    this.number = 0,
    this.isStart = false,
    this.isEnd = false,
    this.isCorner = false,
  });

  /// Convert to offset for rendering
  Offset toOffset(double canvasSize) {
    return point.toOffset(canvasSize);
  }
}
