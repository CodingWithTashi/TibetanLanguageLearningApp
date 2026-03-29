import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../model/letter_trace_data.dart';

/// Main canvas widget for letter tracing - matches HTML reference exactly
class LetterTraceCanvas extends StatefulWidget {
  final Letter letter;
  final VoidCallback? onComplete;
  final VoidCallback? onStrokeComplete;
  final Function(double)? onProgressChanged;
  final Function(String)? onFeedback;

  const LetterTraceCanvas({
    Key? key,
    required this.letter,
    this.onComplete,
    this.onStrokeComplete,
    this.onProgressChanged,
    this.onFeedback,
  }) : super(key: key);

  @override
  State<LetterTraceCanvas> createState() => _LetterTraceCanvasState();
}

class _LetterTraceCanvasState extends State<LetterTraceCanvas>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  // State
  int _currentStrokeIndex = 0;
  double _currentProgress = 0.0;
  double _strokeTotalLength = 0.0;
  bool _isOffPath = false;
  bool _isDone = false;
  bool _isDragging = false;

  // Completed strokes - each stores the revealed length
  final List<double> _completedStrokeLengths = [];

  // Canvas size - calculated once and reused
  double _canvasSize = 400;
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  // Current stroke points for drawing
  final List<Offset> _currentStrokePoints = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initializeForLetter();
  }

  void _initializeForLetter() {
    _currentStrokeIndex = 0;
    _currentProgress = 0.0;
    _isOffPath = false;
    _isDone = false;
    _isDragging = false;
    _currentStrokePoints.clear();
    _completedStrokeLengths.clear();

    for (int i = 0; i < widget.letter.strokes.length; i++) {
      _completedStrokeLengths.add(0.0);
    }

    if (widget.letter.strokes.isNotEmpty) {
      _strokeTotalLength = _getStrokeLength(widget.letter.strokes[0]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateCanvasMetrics();
  }

  void _calculateCanvasMetrics() {
    final size = MediaQuery.of(context).size;
    _canvasSize = (size.width < size.height ? size.width : size.height) - 32; // minus margins

    final bbox = widget.letter.boundingBox;
    final padding = _canvasSize * 0.13;
    final availableSize = _canvasSize - padding * 2;

    final bboxWidth = bbox.maxX - bbox.minX;
    final bboxHeight = bbox.maxY - bbox.minY;

    _scale = (bboxWidth > bboxHeight)
        ? availableSize / bboxWidth
        : availableSize / bboxHeight;

    final scaledWidth = bboxWidth * _scale;
    final scaledHeight = bboxHeight * _scale;

    _offset = Offset(
      padding + (availableSize - scaledWidth) / 2 - bbox.minX * _scale,
      padding + (availableSize - scaledHeight) / 2 - bbox.minY * _scale,
    );
  }

  double _getStrokeLength(Stroke stroke) {
    double total = 0.0;
    for (int i = 1; i < stroke.points.length; i++) {
      final dx = (stroke.points[i].x - stroke.points[i-1].x);
      final dy = (stroke.points[i].y - stroke.points[i-1].y);
      total += sqrt(dx * dx + dy * dy);
    }
    return total * _scale;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    if (_isDone) return;

    setState(() {
      _isDragging = true;
      _currentStrokePoints.clear();
      _isOffPath = false;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging || _isDone) return;

    final localPosition = details.localPosition - const Offset(16, 16); // Account for margin
    final bbox = widget.letter.boundingBox;

    // Convert to normalized coordinates
    final normX = (localPosition.dx - _offset.dx) / _scale;
    final normY = (localPosition.dy - _offset.dy) / _scale;
    final normPos = Offset(normX, normY);

    if (_currentStrokeIndex >= widget.letter.strokes.length) return;

    final stroke = widget.letter.strokes[_currentStrokeIndex];

    // Find closest point on path
    final closest = _findClosestPointOnPath(stroke.points, normPos);
    final distToPath = sqrt(closest.distance);

    // Calculate tolerance
    final tolerance = 0.08; // 8% in normalized coordinates

    final wasOffPath = _isOffPath;
    _isOffPath = distToPath > tolerance;

    if (!_isOffPath) {
      // Calculate distance along stroke
      final distAlong = _getDistanceAtPoint(stroke.points, closest.index) +
          sqrt(_distanceSquared(stroke.points[closest.index], closest.point));

      // Only advance if moving forward
      if (distAlong > _currentProgress) {
        final targetLength = _strokeTotalLength / _scale;
        _currentProgress = distAlong < targetLength ? distAlong : targetLength;

        // Add point for drawing
        _currentStrokePoints.add(localPosition);

        widget.onProgressChanged?.call(_currentProgress / targetLength);

        // Check if stroke is 98% complete
        if (_currentProgress >= targetLength * 0.98) {
          _completeStroke();
          return;
        }
      }
    }

    // Only setState for off-path changes to reduce flicker
    if (_isOffPath != wasOffPath) {
      setState(() {});
      final msg = _isOffPath ? 'Stay on the dotted path!' : null;
      widget.onFeedback?.call(msg ?? '');
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isDragging) {
      setState(() {
        _isDragging = false;
      });
    }
  }

  void _completeStroke() {
    _currentStrokeIndex++;
    _currentProgress = 0.0;
    _currentStrokePoints.clear();

    if (_currentStrokeIndex >= widget.letter.strokes.length) {
      _isDone = true;
      _confettiController.play();
      widget.onComplete?.call();
      widget.onFeedback?.call('Letter complete! Great job!');
    } else {
      _strokeTotalLength = _getStrokeLength(widget.letter.strokes[_currentStrokeIndex]);
      widget.onStrokeComplete?.call();
      widget.onFeedback?.call('Good! Next stroke');
    }

    setState(() {});
  }

  void _reset() {
    _initializeForLetter();
    widget.onFeedback?.call('Canvas cleared');
    setState(() {});
  }

  double _getDistanceAtPoint(List<TracePoint> points, int index) {
    double dist = 0.0;
    for (int i = 1; i <= index && i < points.length; i++) {
      dist += sqrt(_distanceSquared(points[i - 1], points[i]));
    }
    return dist;
  }

  double _distanceSquared(dynamic p1, dynamic p2) {
    final dx = (p2 is Offset ? p2.dx : p2.x) - (p1 is Offset ? p1.dx : p1.x);
    final dy = (p2 is Offset ? p2.dy : p2.y) - (p1 is Offset ? p1.dy : p1.y);
    return dx * dx + dy * dy;
  }

  _ClosestResult _findClosestPointOnPath(List<TracePoint> points, Offset userPoint) {
    double minDist = double.infinity;
    TracePoint closestPoint = points.first;
    int closestIndex = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final p = points[i];
      final p2 = points[i + 1];

      final l2 = _distanceSquared(p, p2);
      if (l2 == 0) {
        final d = _distanceSquared(userPoint, Offset(p.x, p.y));
        if (d < minDist) {
          minDist = d;
          closestPoint = p;
          closestIndex = i;
        }
        continue;
      }

      double t = ((userPoint.dx - p.x) * (p2.x - p.x) +
                  (userPoint.dy - p.y) * (p2.y - p.y)) / l2;
      t = t.clamp(0.0, 1.0);

      final proj = TracePoint(
        x: p.x + t * (p2.x - p.x),
        y: p.y + t * (p2.y - p.y),
      );

      final d = _distanceSquared(userPoint, Offset(proj.x, proj.y));
      if (d < minDist) {
        minDist = d;
        closestPoint = proj;
        closestIndex = i;
      }
    }

    return _ClosestResult(point: closestPoint, index: closestIndex, distance: minDist);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info bar
        _buildInfoBar(context),

        // Canvas
        Expanded(
          child: Stack(
            children: [
              GestureDetector(
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _TracePainter(
                      letter: widget.letter,
                      currentStrokeIndex: _currentStrokeIndex,
                      currentProgress: _currentProgress,
                      strokeTotalLength: _strokeTotalLength,
                      currentStrokePoints: _currentStrokePoints,
                      isDone: _isDone,
                      isOffPath: _isOffPath,
                      primaryColor: Theme.of(context).primaryColor,
                      canvasSize: _canvasSize,
                      scale: _scale,
                      offset: _offset,
                    ),
                  ),
                ),
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                ),
              ),
            ],
          ),
        ),

        // Hint text
        _buildHint(context),

        // Controls
        _buildControls(context),
      ],
    );
  }

  Widget _buildInfoBar(BuildContext context) {
    final currentStrokeNum = (_currentStrokeIndex + 1).clamp(1, widget.letter.strokes.length);
    final totalStrokes = widget.letter.strokes.length;
    final targetLength = _strokeTotalLength / _scale;
    final progress = targetLength > 0
        ? (_currentProgress / targetLength * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE2EF)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          // Letter display
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDDE2EF)),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.letter.name,
              style: const TextStyle(
                fontSize: 28,
                fontFamily: 'jomolhari',
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Meta info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.letter.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  _isDone ? 'Complete!' : 'Stroke $currentStrokeNum of $totalStrokes ($progress%)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Stroke chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _isDone
                  ? const Color(0xFF15803D)
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              _isDone ? '✓' : '$currentStrokeNum/$totalStrokes',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint(BuildContext context) {
    String text;
    Color bgColor;
    Color textColor;

    if (_isDone) {
      text = '✓ Letter complete!';
      bgColor = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF15803D);
    } else if (_isOffPath) {
      text = '⚠️ Stay on the dotted path!';
      bgColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFFDC2626);
    } else {
      text = 'Follow the numbered waypoints — trace along the letter path';
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1D4ED8);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              context,
              '↺ Retry',
              const Color(0xFF1E293B),
              () => _reset(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFDDE2EF), width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ClosestResult {
  final TracePoint point;
  final int index;
  final double distance;
  _ClosestResult({required this.point, required this.index, required this.distance});
}

/// Custom painter matching HTML reference exactly
class _TracePainter extends CustomPainter {
  final Letter letter;
  final int currentStrokeIndex;
  final double currentProgress;
  final double strokeTotalLength;
  final List<Offset> currentStrokePoints;
  final bool isDone;
  final bool isOffPath;
  final Color primaryColor;
  final double canvasSize;
  final double scale;
  final Offset offset;

  _TracePainter({
    required this.letter,
    required this.currentStrokeIndex,
    required this.currentProgress,
    required this.strokeTotalLength,
    required this.currentStrokePoints,
    required this.isDone,
    required this.isOffPath,
    required this.primaryColor,
    required this.canvasSize,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawSize = size.width < size.height ? size.width : size.height;

    // Translate to account for margin
    canvas.save();
    canvas.translate(16, 16);

    // Background layer with grid and ghost letter
    _paintBackground(canvas, drawSize);

    // Trace layer (revealed letter)
    _paintTraceLayer(canvas, drawSize);

    // Guide layer (waypoints, dotted path, current target)
    _paintGuideLayer(canvas, drawSize);

    canvas.restore();
  }

  void _paintBackground(Canvas canvas, double size) {
    // White background
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size),
        Paint()..color = const Color(0xFFFAFBFF));

    // Draw grid
    _paintGrid(canvas, size);

    // Ghost letter using TextPainter (8% opacity like HTML)
    _paintGhostLetter(canvas, size);
  }

  void _paintGrid(Canvas canvas, double size) {
    // Grid lines at 1/3 and 2/3 (dashed)
    final gridPaint = Paint()
      ..color = const Color(0xFFE9ECF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final v in [size / 3, size * 2 / 3]) {
      // Horizontal
      canvas.drawLine(Offset(0, v), Offset(size, v), gridPaint);
      // Vertical
      canvas.drawLine(Offset(v, 0), Offset(v, size), gridPaint);
    }

    // Center lines (solid, lighter)
    final centerPaint = Paint()
      ..color = const Color(0xFFD8DCF0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(size / 2, 0), Offset(size / 2, size), centerPaint);
    canvas.drawLine(Offset(0, size / 2), Offset(size, size / 2), centerPaint);
  }

  void _paintGhostLetter(Canvas canvas, double size) {
    // Use TextPainter to render the letter with font (like HTML's renderGlyph)
    final textStyle = TextStyle(
      fontSize: size * 0.6,
      fontFamily: 'jomolhari',
      color: const Color(0xFF1E293B).withOpacity(0.08),
    );

    final textPainter = TextPainter(
      text: TextSpan(text: letter.name, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size / 2 - textPainter.width / 2,
            size / 2 + textPainter.height / 2 - textPainter.height),
    );
  }

  void _paintTraceLayer(Canvas canvas, double size) {
    if (isDone) {
      // Draw all strokes in green when complete
      _paintAllStrokesComplete(canvas, size);
      return;
    }

    // Draw completed strokes
    for (int i = 0; i < currentStrokeIndex && i < letter.strokes.length; i++) {
      _paintStroke(canvas, letter.strokes[i], const Color(0xFF1E293B), size);
    }

    // Draw current stroke progress (fog of war reveal)
    if (currentStrokeIndex < letter.strokes.length && currentProgress > 0) {
      _paintStrokeProgress(canvas, letter.strokes[currentStrokeIndex], currentProgress, size);
    }
  }

  void _paintAllStrokesComplete(Canvas canvas, double size) {
    for (final stroke in letter.strokes) {
      _paintStroke(canvas, stroke, const Color(0xFF15803D), size);
    }
  }

  void _paintStroke(Canvas canvas, Stroke stroke, Color color, double size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size * 0.05).clamp(3.0, 10.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (stroke.points.isEmpty) return;

    final first = _offsetToPoint(stroke.points.first);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      final p = _offsetToPoint(stroke.points[i]);
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _paintStrokeProgress(Canvas canvas, Stroke stroke, double progress, double size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size * 0.08).clamp(4.0, 12.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (stroke.points.isEmpty) return;

    final first = _offsetToPoint(stroke.points.first);
    path.moveTo(first.dx, first.dy);

    double accumulatedDist = 0.0;
    final targetDist = progress; // Already in normalized coordinates

    for (int i = 1; i < stroke.points.length; i++) {
      final p1 = _offsetToPoint(stroke.points[i - 1]);
      final p2 = _offsetToPoint(stroke.points[i]);

      final segLen = sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));

      if (accumulatedDist + segLen >= targetDist) {
        final t = (targetDist - accumulatedDist) / segLen;
        final endX = p1.dx + t * (p2.dx - p1.dx);
        final endY = p1.dy + t * (p2.dy - p1.dy);
        path.lineTo(endX, endY);
        break;
      }

      path.lineTo(p2.dx, p2.dy);
      accumulatedDist += segLen;
    }

    canvas.drawPath(path, paint);

    // Draw circle at current position
    final currentPoint = _getPointAtDistance(stroke.points, progress);
    final circlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(currentPoint, (size * 0.025).clamp(4.0, 8.0), circlePaint);
  }

  Offset _offsetToPoint(TracePoint p) {
    return Offset(p.x * scale + offset.dx, p.y * scale + offset.dy);
  }

  Offset _getPointAtDistance(List<TracePoint> points, double targetDist) {
    double accumulatedDist = 0.0;

    for (int i = 1; i < points.length; i++) {
      final p1 = _offsetToPoint(points[i - 1]);
      final p2 = _offsetToPoint(points[i]);
      final segLen = sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));

      if (accumulatedDist + segLen >= targetDist) {
        final t = (targetDist - accumulatedDist) / segLen;
        return Offset(
          p1.dx + t * (p2.dx - p1.dx),
          p1.dy + t * (p2.dy - p1.dy),
        );
      }

      accumulatedDist += segLen;
    }

    return _offsetToPoint(points.last);
  }

  void _paintGuideLayer(Canvas canvas, double size) {
    if (isDone || currentStrokeIndex >= letter.strokes.length) return;

    final stroke = letter.strokes[currentStrokeIndex];
    final screenPts = stroke.points.map((p) => _offsetToPoint(p)).toList();

    // Extract key points for waypoints
    final keyPoints = _extractKeyPoints(screenPts);

    // Draw dotted path
    _drawDottedPath(canvas, screenPts);

    // Draw waypoints
    final dotR = max(8.0, size * 0.02);
    final fontSize = max(9.0, size * 0.025);

    for (int i = 0; i < keyPoints.length; i++) {
      final kp = keyPoints[i];
      final reached = _getDistanceAtPointPts(screenPts, kp.index) < currentProgress;
      final isNextTarget = !reached && i == 0;

      // Outer glow for next target
      if (isNextTarget) {
        canvas.drawCircle(kp.point, dotR + 5,
            Paint()..color = const Color(0xFF1D4ED8).withOpacity(0.15));
      }

      // Dot fill
      final dotPaint = Paint()
        ..color = reached
            ? const Color(0xFF15803D).withOpacity(0.85)
            : isNextTarget
                ? const Color(0xFF1D4ED8)
                : const Color(0xFF1D4ED8).withOpacity(0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(kp.point, dotR, dotPaint);

      // White border
      canvas.drawCircle(kp.point, dotR,
          Paint()
            ..color = Colors.white.withOpacity(0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);

      // Number label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(kp.point.dx - textPainter.width / 2,
                 kp.point.dy - textPainter.height / 2 + 0.5));
    }

    // Draw current target indicator
    if (currentProgress < strokeTotalLength / scale) {
      final targetDistNormalized = currentProgress;
      final targetPoint = _getPointAtDistance(stroke.points, targetDistNormalized);

      final targetPaint = Paint()
        ..color = isOffPath ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(targetPoint, size * 0.014, targetPaint);

      canvas.drawCircle(targetPoint, size * 0.014,
          Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    // Progress bar at bottom
    final targetLength = strokeTotalLength / scale;
    final progressRatio = targetLength > 0 ? (currentProgress / targetLength).clamp(0.0, 1.0) : 0.0;
    final barWidth = size * 0.6;
    final barHeight = 4.0;
    final barX = (size - barWidth) / 2;
    final barY = size - 20;

    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth, barHeight),
        Paint()..color = Colors.black.withOpacity(0.1));

    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth * progressRatio, barHeight),
        Paint()..color = isOffPath ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8));
  }

  void _drawDottedPath(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFF1D4ED8).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();

    // Use quadratic curves for smoothness (like HTML)
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length - 1; i++) {
      final mx = (points[i].dx + points[i + 1].dx) / 2;
      final my = (points[i].dy + points[i + 1].dy) / 2;
      path.quadraticBezierTo(points[i].dx, points[i].dy, mx, my);
    }
    path.lineTo(points.last.dx, points.last.dy);

    // Create dashed effect
    final dashPath = _createDashedPath(path, 4.0, 6.0);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      final length = metric.length;
      if (length == 0) continue;

      double distance = 0.0;
      bool draw = true;

      while (distance < length) {
        final len = draw ? dashWidth : dashSpace;
        if (distance + len >= length) {
          if (draw) {
            dest.addPath(metric.extractPath(distance, length), Offset.zero);
          }
          break;
        }

        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }

        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  List<_KeyPoint> _extractKeyPoints(List<Offset> points) {
    if (points.length <= 2) {
      return List.generate(points.length, (i) =>
          _KeyPoint(point: points[i], index: i, type: i == 0 ? 'start' : 'end'));
    }

    final keyPoints = [_KeyPoint(point: points.first, index: 0, type: 'start')];

    // Look for direction changes (corners) - 36 degree threshold
    const angleThreshold = 36.0 * pi / 180;

    for (int i = 2; i < points.length - 2; i++) {
      final angle = _calculateAngle(points[i - 1], points[i], points[i + 1]);

      if (angle > angleThreshold) {
        keyPoints.add(_KeyPoint(point: points[i], index: i, type: 'corner'));
      }
    }

    keyPoints.add(_KeyPoint(point: points.last, index: points.length - 1, type: 'end'));

    return keyPoints;
  }

  double _calculateAngle(Offset p0, Offset p1, Offset p2) {
    final v1 = Offset(p0.dx - p1.dx, p0.dy - p1.dy);
    final v2 = Offset(p2.dx - p1.dx, p2.dy - p1.dy);

    final dot = v1.dx * v2.dx + v1.dy * v2.dy;
    final cross = v1.dx * v2.dy - v1.dy * v2.dx;

    return atan2(cross.abs(), dot);
  }

  double _getDistanceAtPointPts(List<Offset> points, int index) {
    double dist = 0.0;
    for (int i = 1; i <= index && i < points.length; i++) {
      dist += sqrt(pow(points[i].dx - points[i-1].dx, 2) +
                  pow(points[i].dy - points[i-1].dy, 2));
    }
    return dist;
  }

  @override
  bool shouldRepaint(_TracePainter oldDelegate) {
    return true;
  }
}

class _KeyPoint {
  final Offset point;
  final int index;
  final String type;
  _KeyPoint({required this.point, required this.index, required this.type});
}
