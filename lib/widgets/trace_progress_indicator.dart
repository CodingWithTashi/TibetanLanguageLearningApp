import 'package:flutter/material.dart';

/// Progress indicator for letter tracing
class TraceProgressIndicator extends StatelessWidget {
  final int currentStroke;
  final int totalStrokes;
  final double progress;
  final List<bool> completedStrokes;

  const TraceProgressIndicator({
    Key? key,
    required this.currentStroke,
    required this.totalStrokes,
    this.progress = 0.0,
    this.completedStrokes = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress ring
          _buildProgressRing(context),

          const SizedBox(width: 16),

          // Stroke indicators
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stroke $currentStroke of $totalStrokes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStrokeDots(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // Background ring
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _RingPainter(
                progress: 1.0,
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 4,
              ),
            ),
          ),
          // Progress ring
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                color: Theme.of(context).primaryColor,
                strokeWidth: 4,
              ),
            ),
          ),
          // Percentage text
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeDots(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(totalStrokes, (index) {
        final isCompleted = index < completedStrokes.length && completedStrokes[index];
        final isCurrent = index == currentStroke - 1;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isCurrent ? 28 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isCurrent
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}

/// Custom painter for progress ring
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14159 / 2; // Start from top
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

/// Compact progress bar widget
class TraceProgressBar extends StatelessWidget {
  final double progress;
  final int currentStroke;
  final int totalStrokes;
  final String? label;

  const TraceProgressBar({
    Key? key,
    required this.progress,
    required this.currentStroke,
    required this.totalStrokes,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$currentStroke/$totalStrokes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Waypoint indicator for showing current target
class WaypointIndicator extends StatelessWidget {
  final int currentWaypoint;
  final int totalWaypoints;
  final String? instruction;

  const WaypointIndicator({
    Key? key,
    required this.currentWaypoint,
    required this.totalWaypoints,
    this.instruction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated number
          _buildAnimatedNumber(context),

          if (instruction != null) ...[
            const SizedBox(width: 12),
            Text(
              instruction!,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedNumber(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$currentWaypoint',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Status indicator for off-path warning
class OffPathWarningIndicator extends StatelessWidget {
  final bool isOffPath;
  final String? message;

  const OffPathWarningIndicator({
    Key? key,
    required this.isOffPath,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOffPath) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            message ?? 'Stay on the path!',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
