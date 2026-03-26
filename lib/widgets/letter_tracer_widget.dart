import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/widgets/letter_tracer.dart';
import 'package:tibetan_language_learning_app/widgets/letter_tracer.dart' as tracer;

/// Widget wrapper for the letter tracer - scrollable to prevent overflow
class LetterTracerWidget extends StatefulWidget {
  final Alphabet alphabet;
  final VoidCallback? onComplete;
  final VoidCallback? onStrokeComplete;
  final Function(double)? onProgressChanged;
  final Function(String)? onFeedback;

  const LetterTracerWidget({
    Key? key,
    required this.alphabet,
    this.onComplete,
    this.onStrokeComplete,
    this.onProgressChanged,
    this.onFeedback,
  }) : super(key: key);

  @override
  State<LetterTracerWidget> createState() => _LetterTracerWidgetState();
}

class _LetterTracerWidgetState extends State<LetterTracerWidget> {
  LetterData? _letter;
  List<StrokeData> _normSt = [];
  int _sIdx = 0;
  int _fillIdx = 0;
  Set<int> _done = {};
  List<int> _revealed = [];

  // Fixed canvas size
  static const double _fixedCanvasSize = 280.0;
  static const double _proximityThreshold = 19.0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLetterData();
  }

  Future<void> _loadLetterData() async {
    setState(() => _isLoading = true);

    try {
      final jsonStr = await rootBundle.loadString('assets/letters/${widget.alphabet.fileName}.json');
      final letters = parseLettersJson(jsonStr);

      if (letters.isEmpty) {
        setState(() {
          _errorMessage = 'No letter data found';
          _isLoading = false;
        });
        return;
      }

      LetterData? matchingLetter;
      for (final l in letters) {
        if (l.char == widget.alphabet.alphabetName) {
          matchingLetter = l;
          break;
        }
      }
      matchingLetter ??= letters.first;

      final normSt = normaliseStrokes(matchingLetter.strokes);

      setState(() {
        _letter = matchingLetter;
        _normSt = normSt;
        _sIdx = 0;
        _fillIdx = 0;
        _revealed = List.generate(normSt.length, (si) => 0);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _onPan(Offset local) {
    if (_letter == null) return;
    if (_normSt.isEmpty) return;
    if (_done.contains(0)) return;
    if (_sIdx >= _normSt.length) return;

    final pts = _normSt[_sIdx].points;
    final prev = _fillIdx;

    while (_fillIdx < pts.length) {
      final tx = pts[_fillIdx].x * _fixedCanvasSize;
      final ty = pts[_fillIdx].y * _fixedCanvasSize;
      final dx = local.dx - tx;
      final dy = local.dy - ty;
      if (math.sqrt(dx * dx + dy * dy) < _proximityThreshold) {
        _fillIdx++;
      } else {
        break;
      }
    }

    if (_fillIdx == prev) return;

    final newRevealed = List<int>.from(_revealed);
    newRevealed[_sIdx] = _fillIdx;

    final totalPoints = _normSt.fold<int>(0, (sum, stroke) => sum + stroke.points.length);
    final revealedPoints = newRevealed.fold<int>(0, (sum, count) => sum + count);
    final progress = totalPoints > 0 ? revealedPoints / totalPoints : 0.0;
    widget.onProgressChanged?.call(progress);

    if (_fillIdx >= pts.length) {
      final nextSIdx = _sIdx + 1;
      if (nextSIdx >= _normSt.length) {
        for (int i = 0; i < _normSt.length; i++) {
          newRevealed[i] = _normSt[i].points.length;
        }
        setState(() {
          _revealed = newRevealed;
          _done = {0};
          _sIdx = nextSIdx;
          _fillIdx = 0;
        });
        widget.onComplete?.call();
        widget.onFeedback?.call('Letter complete!');
      } else {
        setState(() {
          _revealed = newRevealed;
          _sIdx = nextSIdx;
          _fillIdx = 0;
        });
        widget.onStrokeComplete?.call();
        widget.onFeedback?.call('Good! Next stroke');
      }
    } else {
      setState(() {
        _revealed = newRevealed;
      });
    }
  }

  void _reset() {
    if (_letter == null) return;
    final normSt = normaliseStrokes(_letter!.strokes);
    setState(() {
      _normSt = normSt;
      _sIdx = 0;
      _fillIdx = 0;
      _revealed = List.generate(normSt.length, (si) => 0);
      _done = {};
    });
    widget.onFeedback?.call('Canvas cleared');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_errorMessage != null || _letter == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'No data',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
    }

    final isDone = _done.contains(0);
    final ns = _normSt.length;
    final si = ns == 0 ? 0 : math.min(_sIdx, ns - 1);

    // Use SingleChildScrollView to prevent overflow
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(), // Only scroll if needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Info bar
          _buildInfoBar(isDone, si, ns),
          const SizedBox(height: 8),
          // Canvas
          _canvasWidget(isDone),
          const SizedBox(height: 8),
          // Hint bar
          _buildHintBar(isDone),
          const SizedBox(height: 8),
          // Controls
          _controls(isDone),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoBar(bool isDone, int si, int ns) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tracer.TracerTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tracer.TracerTokens.border, width: 1),
        boxShadow: tracer.TracerTokens.shadow,
      ),
      child: Row(children: [
        // Character tile
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tracer.TracerTokens.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tracer.TracerTokens.border, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            _letter!.char,
            style: const TextStyle(
              fontFamily: 'jomolhari',
              fontSize: 24,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Name + stroke info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _letter!.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: tracer.TracerTokens.text1,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Stroke ${si + 1} of $ns',
                style: const TextStyle(
                  fontSize: 11,
                  color: tracer.TracerTokens.text3,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDone ? tracer.TracerTokens.green : tracer.TracerTokens.accent,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            isDone ? '✓' : '${si + 1}/$ns',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _canvasWidget(bool isDone) {
    return Center(
      child: Container(
        width: _fixedCanvasSize,
        height: _fixedCanvasSize,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tracer.TracerTokens.border, width: 1),
          boxShadow: tracer.TracerTokens.shadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: GestureDetector(
            onPanStart: (d) => _onPan(d.localPosition),
            onPanUpdate: (d) => _onPan(d.localPosition),
            child: CustomPaint(
              size: const Size.square(_fixedCanvasSize),
              painter: TracerPainter(
                letter: _letter!,
                normSt: _normSt,
                sIdx: _sIdx,
                fillIdx: _fillIdx,
                revealed: List<int>.from(_revealed),
                isDone: isDone,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHintBar(bool isDone) {
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDone ? tracer.TracerTokens.greenLt : tracer.TracerTokens.accentLt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDone ? tracer.TracerTokens.green : tracer.TracerTokens.accent, width: 1),
      ),
      child: Center(
        child: Text(
          isDone ? '✓ Complete! Tap Retry' : 'Trace stroke ${_sIdx + 1}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDone ? tracer.TracerTokens.green : tracer.TracerTokens.accent,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _controls(bool isDone) {
    return SizedBox(
      height: 40,
      child: Center(
        child: _ctrlBtn('↺ Retry', () => _reset()),
      ),
    );
  }

  Widget _ctrlBtn(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: tracer.TracerTokens.ink,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: tracer.TracerTokens.ink, width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
