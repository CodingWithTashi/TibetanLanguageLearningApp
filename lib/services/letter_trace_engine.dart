import 'dart:math';
import 'package:flutter/material.dart';
import '../model/letter_trace_data.dart';
import '../util/trace_geometry.dart';

/// Core tracing engine for tracking progress and validation
class LetterTraceEngine {
  final Letter letter;
  final double canvasSize;
  final double tolerance;

  int _currentStrokeIndex;
  final List<List<Offset>> _drawnStrokes;
  final List<double> _strokeProgress;
  final List<bool> _strokeCompleted;
  List<Offset> _currentDrawing;
  bool _isOffPath;

  LetterTraceEngine({
    required this.letter,
    required this.canvasSize,
    this.tolerance = TraceConstants.tolerance,
  })  : _currentStrokeIndex = 0,
        _drawnStrokes = [],
        _strokeProgress = [],
        _strokeCompleted = [],
        _currentDrawing = [],
        _isOffPath = false {
    _initialize();
  }

  void _initialize() {
    for (int i = 0; i < letter.strokes.length; i++) {
      _drawnStrokes.add([]);
      _strokeProgress.add(0.0);
      _strokeCompleted.add(false);
    }
  }

  /// Get current stroke index
  int get currentStrokeIndex => _currentStrokeIndex;

  /// Check if all strokes are completed
  bool get isComplete {
    return _strokeCompleted.every((completed) => completed);
  }

  /// Get overall completion percentage (0-1)
  double get overallProgress {
    if (letter.strokes.isEmpty) return 0.0;
    final completed = _strokeCompleted.where((c) => c).length;
    return completed / letter.strokes.length;
  }

  /// Get current stroke progress (0-1)
  double get currentStrokeProgress {
    if (_currentStrokeIndex >= _strokeProgress.length) return 0.0;
    return _strokeProgress[_currentStrokeIndex];
  }

  /// Check if currently off path
  bool get isOffPath => _isOffPath;

  /// Get all drawn strokes
  List<List<Offset>> get drawnStrokes => List.unmodifiable(_drawnStrokes);

  /// Get current drawing
  List<Offset> get currentDrawing => List.unmodifiable(_currentDrawing);

  /// Start a new stroke at the given position
  TraceResult startStroke(Offset position) {
    if (isComplete) {
      return TraceResult(
        success: false,
        letterComplete: true,
        message: 'Letter already completed!',
      );
    }

    final point = _transformOffsetToPoint(position);
    final startPoint = letter.strokes[_currentStrokeIndex].startPoint;

    // Check if starting near the correct stroke start
    if (startPoint != null) {
      final dist = sqrt(_distanceSquared(point, startPoint));
      // Allow more generous start distance (15% of canvas)
      if (dist > 0.15) {
        return TraceResult(
          success: false,
          message: 'Start from the green dot',
          isOffPath: true,
        );
      }
    }

    _currentDrawing = [position];
    _isOffPath = false;

    return TraceResult(
      success: true,
      strokeIndex: _currentStrokeIndex,
    );
  }

  /// Update current stroke with new position
  TraceResult updateStroke(Offset position) {
    if (_currentDrawing.isEmpty) {
      return TraceResult(success: false, message: 'Start drawing first');
    }

    final point = _transformOffsetToPoint(position);
    final currentStroke = letter.strokes[_currentStrokeIndex];

    // Check if off path
    final result = TraceGeometry.findClosestPointOnStroke(point, currentStroke);
    final dist = sqrt(result.distance);

    if (dist > tolerance) {
      if (!_isOffPath) {
        _isOffPath = true;
        return TraceResult(
          success: true,
          isOffPath: true,
          message: 'Stay on the path!',
        );
      }
    } else {
      _isOffPath = false;
    }

    _currentDrawing.add(position);

    // Calculate progress based on coverage
    _strokeProgress[_currentStrokeIndex] = _calculateStrokeProgress(_currentDrawing, currentStroke);

    return TraceResult(
      success: true,
      strokeIndex: _currentStrokeIndex,
      progress: _strokeProgress[_currentStrokeIndex],
      isOffPath: _isOffPath,
    );
  }

  /// End current stroke
  TraceResult endStroke() {
    if (_currentDrawing.isEmpty) {
      return TraceResult(success: false, message: 'No stroke to end');
    }

    final currentStroke = letter.strokes[_currentStrokeIndex];
    final endPoint = currentStroke.endPoint;

    // Check if ended near the correct stroke end
    bool endedNearEnd = true;
    if (endPoint != null && _currentDrawing.isNotEmpty) {
      final lastPoint = _transformOffsetToPoint(_currentDrawing.last);
      final dist = sqrt(_distanceSquared(lastPoint, endPoint));
      endedNearEnd = dist <= tolerance * 2;
    }

    // Check if stroke is complete enough
    final progress = _strokeProgress[_currentStrokeIndex];
    final isStrokeComplete = progress >= 0.7 && endedNearEnd;

    if (isStrokeComplete) {
      _strokeCompleted[_currentStrokeIndex] = true;
      _drawnStrokes[_currentStrokeIndex] = List.from(_currentDrawing);

      // Move to next stroke
      if (_currentStrokeIndex < letter.strokes.length - 1) {
        _currentStrokeIndex++;
        _currentDrawing = [];
        _isOffPath = false;

        return TraceResult(
          success: true,
          strokeComplete: true,
          strokeIndex: _currentStrokeIndex - 1,
          nextStrokeIndex: _currentStrokeIndex,
          message: 'Good! Next stroke',
          overallProgress: overallProgress,
        );
      } else {
        // All strokes complete
        _currentDrawing = [];
        return TraceResult(
          success: true,
          strokeComplete: true,
          letterComplete: true,
          strokeIndex: _currentStrokeIndex,
          overallProgress: 1.0,
          message: 'Complete! Great job!',
        );
      }
    } else {
      // Stroke not complete enough, let user try again
      String feedbackMsg;
      if (!endedNearEnd) {
        feedbackMsg = 'End at the red dot';
      } else if (progress < 0.3) {
        feedbackMsg = 'Keep going!';
      } else {
        feedbackMsg = 'Almost there, trace more carefully';
      }

      _currentDrawing = [];

      return TraceResult(
        success: true,
        strokeComplete: false,
        strokeIndex: _currentStrokeIndex,
        progress: progress,
        message: feedbackMsg,
        overallProgress: overallProgress,
      );
    }
  }

  /// Transform screen offset to normalized letter coordinates
  TracePoint _transformOffsetToPoint(Offset offset) {
    final bbox = letter.boundingBox;

    // Calculate scaling (same as in painter)
    final padding = canvasSize * 0.15;
    final availableSize = canvasSize - padding * 2;

    final bboxWidth = bbox.maxX - bbox.minX;
    final bboxHeight = bbox.maxY - bbox.minY;

    final scaleX = availableSize / bboxWidth;
    final scaleY = availableSize / bboxHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final scaledWidth = bboxWidth * scale;
    final scaledHeight = bboxHeight * scale;

    final offsetX_px = padding + (availableSize - scaledWidth) / 2 - bbox.minX * scale;
    final offsetY_px = padding + (availableSize - scaledHeight) / 2 - bbox.minY * scale;

    // Transform screen offset to normalized coordinates
    final x = (offset.dx - offsetX_px) / scale;
    final y = (offset.dy - offsetY_px) / scale;

    return TracePoint(x: x.clamp(0.0, 1.0), y: y.clamp(0.0, 1.0));
  }

  /// Calculate stroke progress
  double _calculateStrokeProgress(List<Offset> drawnPoints, Stroke stroke) {
    if (stroke.points.isEmpty || drawnPoints.isEmpty) return 0.0;

    int coveredPoints = 0;
    final totalPoints = stroke.points.length;

    for (final point in stroke.points) {
      bool isCovered = false;

      for (final drawnOffset in drawnPoints) {
        final drawnPoint = _transformOffsetToPoint(drawnOffset);
        if (_distanceSquared(point, drawnPoint) < (tolerance * tolerance)) {
          isCovered = true;
          break;
        }
      }

      if (isCovered) coveredPoints++;
    }

    return coveredPoints / totalPoints;
  }

  double _distanceSquared(TracePoint p1, TracePoint p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return dx * dx + dy * dy;
  }

  /// Clear current stroke (for retry)
  void clearCurrentStroke() {
    _currentDrawing = [];
    _isOffPath = false;
  }

  /// Clear all drawings and reset
  void reset() {
    _currentStrokeIndex = 0;
    _currentDrawing = [];
    _isOffPath = false;

    for (int i = 0; i < _drawnStrokes.length; i++) {
      _drawnStrokes[i] = [];
      _strokeProgress[i] = 0.0;
      _strokeCompleted[i] = false;
    }
  }

  /// Undo last completed stroke
  TraceResult undoLastStroke() {
    if (_currentStrokeIndex > 0) {
      _currentStrokeIndex--;
      _strokeCompleted[_currentStrokeIndex] = false;
      _strokeProgress[_currentStrokeIndex] = 0.0;
      _drawnStrokes[_currentStrokeIndex] = [];
      _currentDrawing = [];

      return TraceResult(
        success: true,
        strokeIndex: _currentStrokeIndex,
        message: 'Undo successful',
      );
    } else if (_currentStrokeIndex == 0 && _strokeCompleted[0]) {
      _strokeCompleted[0] = false;
      _strokeProgress[0] = 0.0;
      _drawnStrokes[0] = [];
      _currentDrawing = [];

      return TraceResult(
        success: true,
        strokeIndex: 0,
        message: 'Undo successful',
      );
    }

    return TraceResult(
      success: false,
      message: 'Nothing to undo',
    );
  }

  /// Get waypoints for current stroke
  List<Waypoint> getCurrentStrokeWaypoints() {
    if (_currentStrokeIndex >= letter.strokes.length) return [];
    return TraceGeometry.generateWaypoints(
      letter.strokes[_currentStrokeIndex],
      _currentStrokeIndex,
      TraceConstants.waypointSpacing,
      TraceConstants.keyPointAngleThreshold,
    );
  }

  /// Get all waypoints for the letter
  List<List<Waypoint>> getAllWaypoints() {
    final allWaypoints = <List<Waypoint>>[];

    for (int i = 0; i < letter.strokes.length; i++) {
      allWaypoints.add(TraceGeometry.generateWaypoints(
        letter.strokes[i],
        i,
        TraceConstants.waypointSpacing,
        TraceConstants.keyPointAngleThreshold,
      ));
    }

    return allWaypoints;
  }

  /// Get hint for current stroke (start point)
  Offset? getStartHint() {
    if (_currentStrokeIndex >= letter.strokes.length) return null;
    final startPoint = letter.strokes[_currentStrokeIndex].startPoint;
    return _transformPointToOffset(startPoint);
  }

  /// Get hint for current stroke (end point)
  Offset? getEndHint() {
    if (_currentStrokeIndex >= letter.strokes.length) return null;
    final endPoint = letter.strokes[_currentStrokeIndex].endPoint;
    return _transformPointToOffset(endPoint);
  }

  /// Transform normalized point to screen offset
  Offset? _transformPointToOffset(TracePoint? point) {
    if (point == null) return null;

    final bbox = letter.boundingBox;
    final padding = canvasSize * 0.15;
    final availableSize = canvasSize - padding * 2;

    final bboxWidth = bbox.maxX - bbox.minX;
    final bboxHeight = bbox.maxY - bbox.minY;

    final scaleX = availableSize / bboxWidth;
    final scaleY = availableSize / bboxHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final scaledWidth = bboxWidth * scale;
    final scaledHeight = bboxHeight * scale;

    final offsetX_px = padding + (availableSize - scaledWidth) / 2 - bbox.minX * scale;
    final offsetY_px = padding + (availableSize - scaledHeight) / 2 - bbox.minY * scale;

    return Offset(
      point.x * scale + offsetX_px,
      point.y * scale + offsetY_px,
    );
  }
}

/// Result of a trace operation
class TraceResult {
  final bool success;
  final bool strokeComplete;
  final bool letterComplete;
  final bool isOffPath;
  final int? strokeIndex;
  final int? nextStrokeIndex;
  final double? progress;
  final double? overallProgress;
  final String? message;

  TraceResult({
    required this.success,
    this.strokeComplete = false,
    this.letterComplete = false,
    this.isOffPath = false,
    this.strokeIndex,
    this.nextStrokeIndex,
    this.progress,
    this.overallProgress,
    this.message,
  });

  @override
  String toString() {
    return 'TraceResult(success: $success, strokeComplete: $strokeComplete, '
        'letterComplete: $letterComplete, strokeIndex: $strokeIndex, '
        'progress: $progress, message: $message)';
  }
}

/// Progress tracker for trace sessions
class TraceProgressTracker {
  final Map<String, TraceSession> _sessions = {};

  /// Start a new session for a letter
  TraceSession startSession(String letterId, Letter letter) {
    final session = TraceSession(
      letterId: letterId,
      startTime: DateTime.now(),
      letter: letter,
    );
    _sessions[letterId] = session;
    return session;
  }

  /// Get existing session
  TraceSession? getSession(String letterId) {
    return _sessions[letterId];
  }

  /// End session and return results
  TraceSessionResult endSession(String letterId) {
    final session = _sessions[letterId];
    if (session == null) {
      return TraceSessionResult(
        letterId: letterId,
        duration: Duration.zero,
        completed: false,
        attempts: 0,
      );
    }

    final result = TraceSessionResult(
      letterId: letterId,
      duration: DateTime.now().difference(session.startTime),
      completed: session.isComplete,
      attempts: session.attempts,
      strokeCount: session.letter.strokes.length,
    );

    _sessions.remove(letterId);
    return result;
  }

  /// Clear all sessions
  void clear() {
    _sessions.clear();
  }
}

/// Active tracing session
class TraceSession {
  final String letterId;
  final DateTime startTime;
  final Letter letter;
  int attempts;
  bool isComplete;

  TraceSession({
    required this.letterId,
    required this.startTime,
    required this.letter,
    this.attempts = 1,
    this.isComplete = false,
  });
}

/// Result of a completed trace session
class TraceSessionResult {
  final String letterId;
  final Duration duration;
  final bool completed;
  final int attempts;
  final int? strokeCount;

  TraceSessionResult({
    required this.letterId,
    required this.duration,
    required this.completed,
    required this.attempts,
    this.strokeCount,
  });

  /// Calculate score based on performance
  int get score {
    if (!completed) return 0;

    int baseScore = (strokeCount ?? 1) * 10;
    int timeBonus = 1000 ~/ (duration.inSeconds + 1);
    int attemptPenalty = (attempts - 1) * 5;

    return (baseScore + timeBonus - attemptPenalty).clamp(0, 100);
  }
}
