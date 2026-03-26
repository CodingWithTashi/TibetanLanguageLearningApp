import 'dart:convert';
import 'package:flutter/material.dart';

/// Models for letter tracing data loaded from JSON files

/// Root model for letter trace data
class LetterTraceData {
  final String version;
  final String coordinateSystem;
  final int canvasSize;
  final Map<String, Letter> letters;

  LetterTraceData({
    required this.version,
    required this.coordinateSystem,
    required this.canvasSize,
    required this.letters,
  });

  factory LetterTraceData.fromJson(Map<String, dynamic> json) {
    final lettersMap = <String, Letter>{};
    if (json['letters'] != null) {
      (json['letters'] as Map<String, dynamic>).forEach((key, value) {
        lettersMap[key] = Letter.fromJson(value);
      });
    }

    return LetterTraceData(
      version: json['version'] ?? '1.0',
      coordinateSystem: json['coordinateSystem'] ?? 'normalized-0-1',
      canvasSize: json['canvasSize'] ?? 1000,
      letters: lettersMap,
    );
  }

  Map<String, dynamic> toJson() {
    final lettersJson = <String, dynamic>{};
    letters.forEach((key, value) {
      lettersJson[key] = value.toJson();
    });

    return {
      'version': version,
      'coordinateSystem': coordinateSystem,
      'canvasSize': canvasSize,
      'letters': lettersJson,
    };
  }

  /// Get letter by character
  Letter? getLetter(String character) {
    return letters[character];
  }

  /// Get list of all letter characters
  List<String> get letterCharacters => letters.keys.toList();

  /// Get first available letter (for single-letter files)
  Letter? get firstLetter {
    if (letters.isEmpty) return null;
    return letters.values.first;
  }

  static LetterTraceData? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LetterTraceData.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing letter trace data: $e');
      return null;
    }
  }
}

/// Individual letter data with strokes and metadata
class Letter {
  final String name;
  final int index;
  final List<Stroke> strokes;
  final BoundingBox boundingBox;

  Letter({
    required this.name,
    required this.index,
    required this.strokes,
    required this.boundingBox,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    final strokesList = <Stroke>[];
    if (json['strokes'] != null) {
      for (var item in (json['strokes'] as List)) {
        strokesList.add(Stroke.fromJson(item));
      }
    }

    return Letter(
      name: json['name'] ?? '',
      index: json['index'] ?? 1,
      strokes: strokesList,
      boundingBox: json['boundingBox'] != null
          ? BoundingBox.fromJson(json['boundingBox'])
          : BoundingBox(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'index': index,
      'strokes': strokes.map((s) => s.toJson()).toList(),
      'boundingBox': boundingBox.toJson(),
    };
  }

  /// Get total number of strokes
  int get strokeCount => strokes.length;

  /// Calculate total path length across all strokes
  double get totalPathLength {
    return strokes.fold(0.0, (sum, stroke) => sum + stroke.length);
  }
}

/// A single stroke consisting of multiple points
class Stroke {
  final List<TracePoint> points;
  final String? type;

  Stroke({required this.points, this.type});

  factory Stroke.fromJson(dynamic json) {
    // Handle both formats:
    // 1. New format: {"type": "path", "points": [...]}
    // 2. Old format: directly a list of points
    if (json is Map<String, dynamic>) {
      final pointsList = <TracePoint>[];
      if (json['points'] != null) {
        for (var item in (json['points'] as List)) {
          pointsList.add(TracePoint.fromJson(item));
        }
      }
      return Stroke(points: pointsList, type: json['type'] ?? 'path');
    } else if (json is List) {
      final pointsList = <TracePoint>[];
      for (var item in json) {
        pointsList.add(TracePoint.fromJson(item));
      }
      return Stroke(points: pointsList, type: 'path');
    }
    return Stroke(points: [], type: 'path');
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type ?? 'path',
      'points': points.map((p) => p.toJson()).toList(),
    };
  }

  /// Calculate the length of this stroke
  double get length {
    if (points.length < 2) return 0.0;

    double totalLength = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      final dx = points[i + 1].x - points[i].x;
      final dy = points[i + 1].y - points[i].y;
      totalLength += (dx * dx + dy * dy);
    }
    return totalLength;
  }

  /// Get start point of stroke
  TracePoint? get startPoint => points.isNotEmpty ? points.first : null;

  /// Get end point of stroke
  TracePoint? get endPoint => points.isNotEmpty ? points.last : null;
}

/// A single point with normalized coordinates (0-1)
class TracePoint {
  final double x;
  final double y;

  TracePoint({required this.x, required this.y});

  factory TracePoint.fromJson(Map<String, dynamic> json) {
    return TracePoint(
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }

  /// Convert to Offset with given canvas size
  Offset toOffset(double canvasSize) {
    return Offset(x * canvasSize, y * canvasSize);
  }

  /// Create from Offset with given canvas size
  static TracePoint fromOffset(Offset offset, double canvasSize) {
    return TracePoint(
      x: (offset.dx / canvasSize).clamp(0.0, 1.0),
      y: (offset.dy / canvasSize).clamp(0.0, 1.0),
    );
  }

  /// Calculate distance to another point
  double distanceTo(TracePoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy);
  }

  /// Calculate distance to an offset (with canvas size)
  double distanceToOffset(Offset offset, double canvasSize) {
    final other = TracePoint.fromOffset(offset, canvasSize);
    return distanceTo(other);
  }

  @override
  String toString() => '($x, $y)';
}

/// Bounding box for a letter
class BoundingBox {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  BoundingBox({
    this.minX = 0.0,
    this.maxX = 1.0,
    this.minY = 0.0,
    this.maxY = 1.0,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      minX: (json['minX'] ?? 0.0).toDouble(),
      maxX: (json['maxX'] ?? 1.0).toDouble(),
      minY: (json['minY'] ?? 0.0).toDouble(),
      maxY: (json['maxY'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minX': minX,
      'maxX': maxX,
      'minY': minY,
      'maxY': maxY,
    };
  }

  /// Get width of bounding box
  double get width => maxX - minX;

  /// Get height of bounding box
  double get height => maxY - minY;

  /// Get center of bounding box
  TracePoint get center {
    return TracePoint(
      x: (minX + maxX) / 2,
      y: (minY + maxY) / 2,
    );
  }

  /// Check if a point is inside the bounding box
  bool contains(TracePoint point) {
    return point.x >= minX && point.x <= maxX &&
           point.y >= minY && point.y <= maxY;
  }
}

/// Constants for trace rendering
class TraceConstants {
  static const double canvasPadding = 0.13;
  static const double tolerance = 0.08;
  static const double waypointSpacing = 0.05;
  static const double keyPointAngleThreshold = 36.0;
  static const double completionThreshold = 0.98;
  static const double simplifyEpsilon = 0.008;
  static const double strokeWidth = 8.0;
  static const double guideStrokeWidth = 2.0;
  static const double waypointRadius = 12.0;
  static const double ghostLetterOpacity = 0.3;
}
