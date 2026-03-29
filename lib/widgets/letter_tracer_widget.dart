import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/widgets/letter_tracer.dart';

/// Minimal letter tracer widget - just the canvas
/// Reloads when alphabet changes
class LetterTracerWidget extends StatefulWidget {
  final Alphabet alphabet;
  final VoidCallback? onComplete;
  final VoidCallback? onStrokeComplete;
  final Function(double)? onProgressChanged;

  const LetterTracerWidget({
    Key? key,
    required this.alphabet,
    this.onComplete,
    this.onStrokeComplete,
    this.onProgressChanged,
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

  static const double _fixedCanvasSize = 280.0;
  static const double _proximityThreshold = 19.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLetterData();
  }

  @override
  void didUpdateWidget(LetterTracerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when alphabet changes
    if (oldWidget.alphabet.alphabetName != widget.alphabet.alphabetName) {
      _resetAndLoad();
    }
  }

  Future<void> _resetAndLoad() async {
    // Reset state before loading new letter
    setState(() {
      _isLoading = true;
      _letter = null;
      _normSt = [];
      _sIdx = 0;
      _fillIdx = 0;
      _done = {};
      _revealed = [];
    });
    await _loadLetterData();
  }

  Future<void> _loadLetterData() async {
    setState(() => _isLoading = true);

    try {
      // Load from letters.json (contains all letters)
      final jsonStr = await rootBundle.loadString('assets/letters/letters.json');
      final letters = parseLettersJson(jsonStr);

      if (letters.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Find the letter matching the alphabet name
      // Strip tsheg (་) from alphabetName for matching
      final cleanName = widget.alphabet.alphabetName.replaceAll('་', '');

      LetterData? matchingLetter;
      for (final l in letters) {
        if (l.char == cleanName) {
          matchingLetter = l;
          break;
        }
      }

      // Fallback to first letter if no match
      matchingLetter ??= letters.first;

      final normSt = normaliseStrokes(matchingLetter.strokes);

      setState(() {
        _letter = matchingLetter;
        _normSt = normSt;
        _sIdx = 0;
        _fillIdx = 0;
        _revealed = List.generate(normSt.length, (si) => 0);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
      } else {
        setState(() {
          _revealed = newRevealed;
          _sIdx = nextSIdx;
          _fillIdx = 0;
        });
        widget.onStrokeComplete?.call();
      }
    } else {
      setState(() {
        _revealed = newRevealed;
      });
    }
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

    if (_letter == null) {
      return const SizedBox.shrink();
    }

    final isDone = _done.contains(0);

    return Center(
      child: Container(
        width: _fixedCanvasSize,
        height: _fixedCanvasSize,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE2EF), width: 1),
          boxShadow: TracerTokens.shadow,
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
}
