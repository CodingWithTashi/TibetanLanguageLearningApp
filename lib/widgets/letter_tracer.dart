// ─────────────────────────────────────────────────────────────────────────────
// letter_tracer.dart — Tibetan Letter Tracer Core
// Uses professional font rendering with fog-of-war reveal effect
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═════════════════════════════════════════════════════
// DESIGN TOKENS
// ═════════════════════════════════════════════════════

class TracerTokens {
  static const bg        = Color(0xFFF2F4F8);
  static const surface   = Color(0xFFFFFFFF);
  static const border    = Color(0xFFDDE2EF);
  static const text1     = Color(0xFF0F172A);
  static const text2     = Color(0xFF475569);
  static const text3     = Color(0xFF94A3B8);
  static const accent    = Color(0xFF1D4ED8);
  static const accentLt  = Color(0xFFEFF6FF);
  static const green     = Color(0xFF15803D);
  static const greenLt   = Color(0xFFF0FDF4);
  static const ink       = Color(0xFF1E293B);
  static const radius    = 14.0;
  static const shadow    = [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 2))];
}

// ═════════════════════════════════════════════════════
// MODELS
// ═════════════════════════════════════════════════════

class Pt {
  final double x, y;
  const Pt(this.x, this.y);

  Offset toOffset(double canvasSize) => Offset(x * canvasSize, y * canvasSize);
}

class StrokeData {
  final List<Pt> points;
  const StrokeData(this.points);

  factory StrokeData.fromJson(Map<String, dynamic> json) {
    final pts = (json['points'] as List<dynamic>)
        .map<Pt>((p) => Pt(
              (p['x'] as num).toDouble(),
              (p['y'] as num).toDouble(),
            ))
        .toList();
    return StrokeData(pts);
  }
}

class LetterData {
  final String char;
  final String name;
  final String desc;
  final int index;
  final List<StrokeData> strokes;

  const LetterData({
    required this.char,
    required this.name,
    required this.desc,
    required this.index,
    required this.strokes,
  });

  static LetterData? fromMap(Map<String, dynamic> m) {
    final char = m['char'] as String?;
    final raw  = m['strokes'] as List<dynamic>?;
    if (char == null || raw == null || raw.isEmpty) return null;
    final strokes = raw.map<StrokeData>((s) {
      if (s is Map) {
        return StrokeData.fromJson(s as Map<String, dynamic>);
      } else {
        final pts = (s as List<dynamic>)
            .map<Pt>((p) => Pt(
                  (p['x'] as num).toDouble(),
                  (p['y'] as num).toDouble(),
                ))
            .toList();
        return StrokeData(pts);
      }
    }).toList();
    return LetterData(
      char:    char,
      name:    (m['name']  as String?) ?? char,
      desc:    (m['desc']  as String?) ?? '',
      index:   (m['index'] as num?)?.toInt() ?? 0,
      strokes: strokes,
    );
  }

  int get strokeCount => strokes.length;
}

// ═════════════════════════════════════════════════════
// JSON PARSER
// ═════════════════════════════════════════════════════

List<LetterData> parseLettersJson(String raw) {
  final parsed = json.decode(raw);
  final result = <LetterData>[];

  dynamic root = parsed;
  if (parsed is Map && parsed.containsKey('letters')) {
    root = parsed['letters'];
  }

  if (root is List) {
    for (final item in root) {
      final l = LetterData.fromMap(Map<String, dynamic>.from(item as Map));
      if (l != null) result.add(l);
    }
  } else if (root is Map) {
    root.forEach((char, v) {
      if (v is Map) {
        final map = Map<String, dynamic>.from(v);
        map['char'] = char.toString();
        final l = LetterData.fromMap(map);
        if (l != null) result.add(l);
      }
    });
    result.sort((a, b) => a.index.compareTo(b.index));
  }
  return result;
}

// ═════════════════════════════════════════════════════
// NORMALISE
// ═════════════════════════════════════════════════════

List<StrokeData> normaliseStrokes(List<StrokeData> raw) {
  if (raw.isEmpty) return [];
  double mnX =  double.infinity, mnY =  double.infinity;
  double mxX = -double.infinity, mxY = -double.infinity;
  for (final s in raw) {
    for (final p in s.points) {
      if (p.x < mnX) mnX = p.x; if (p.y < mnY) mnY = p.y;
      if (p.x > mxX) mxX = p.x; if (p.y > mxY) mxY = p.y;
    }
  }
  final rX = math.max(mxX - mnX, 1e-9);
  final rY = math.max(mxY - mnY, 1e-9);
  final r  = math.max(rX, rY);
  const pad   = 0.13;
  const avail = 1.0 - pad * 2;
  final sc = avail / r;
  final ox = pad + (avail - rX * sc) / 2 - mnX * sc;
  final oy = pad + (avail - rY * sc) / 2 - mnY * sc;
  return raw.map((s) => StrokeData(
    s.points.map((p) => Pt(p.x * sc + ox, p.y * sc + oy)).toList(),
  )).toList();
}

// ═════════════════════════════════════════════════════
// CUSTOM PAINTER
// Uses font-based rendering for professional appearance
// Stroke paths used only for guide layer (waypoints, dots)
// ═════════════════════════════════════════════════════

class TracerPainter extends CustomPainter {
  final LetterData       letter;
  final List<StrokeData> normSt;
  final int              sIdx;
  final int              fillIdx;
  final List<int>        revealed;
  final bool             isDone;

  const TracerPainter({
    required this.letter,
    required this.normSt,
    required this.sIdx,
    required this.fillIdx,
    required this.revealed,
    required this.isDone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cs = size.width;
    _drawBackground(canvas, cs);
    _drawLetterWithReveal(canvas, cs);
    if (!isDone && normSt.isNotEmpty) _drawGuide(canvas, cs);
  }

  // ─── 1. BACKGROUND (grid) ────────────────────────────
  void _drawBackground(Canvas canvas, double cs) {
    // Dashed third-lines
    final dashPaint = Paint()
      ..color = const Color(0xFFE9ECF6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (final v in [cs / 3, cs * 2 / 3]) {
      _dashedLine(canvas, Offset(v, 0),  Offset(v, cs),  dashPaint, 3, 6);
      _dashedLine(canvas, Offset(0, v),  Offset(cs, v),  dashPaint, 3, 6);
    }
    // Solid center-lines
    final solidPaint = Paint()
      ..color = const Color(0xFFD8DCF0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cs / 2, 0), Offset(cs / 2, cs), solidPaint);
    canvas.drawLine(Offset(0, cs / 2), Offset(cs, cs / 2), solidPaint);
  }

  // ─── 2. LETTER WITH FOG-OF-WAR REVEAL ───────────────
  void _drawLetterWithReveal(Canvas canvas, double cs) {
    final rect = Rect.fromLTWH(0, 0, cs, cs);

    if (isDone) {
      // Complete - show full letter in green
      _paintGlyph(canvas, cs, letter.char, TracerTokens.green);
      return;
    }

    // Check if anything is revealed
    final totalRevealed = revealed.fold<int>(0, (sum, c) => sum + c);
    if (totalRevealed == 0) {
      // Nothing revealed yet - show ghost letter only
      _paintGlyph(canvas, cs, letter.char, TracerTokens.ink, opacity: 0.12);
      return;
    }

    // Fog-of-war effect using saveLayer and BlendMode
    canvas.saveLayer(rect, Paint());

    // Layer 1: Full letter in ink (this will be masked)
    _paintGlyph(canvas, cs, letter.char, TracerTokens.ink);

    // Layer 2: Mask layer (dstIn - keeps only where we've drawn)
    canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);

    // Draw the mask - revealed areas only
    final brushPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = cs * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes fully
    for (int si = 0; si < sIdx; si++) {
      _drawStrokePath(canvas, normSt[si].points, cs, brushPaint);
    }

    // Draw current stroke partially
    if (sIdx < normSt.length && fillIdx > 0) {
      final pts = normSt[sIdx].points;
      final path = Path()..moveTo(pts[0].x * cs, pts[0].y * cs);
      for (int i = 1; i < fillIdx; i++) {
        path.lineTo(pts[i].x * cs, pts[i].y * cs);
      }
      canvas.drawPath(path, brushPaint);

      // Draw circle at leading edge for smooth appearance
      if (fillIdx > 0 && fillIdx <= pts.length) {
        final lastIdx = math.min(fillIdx - 1, pts.length - 1);
        canvas.drawCircle(
          Offset(pts[lastIdx].x * cs, pts[lastIdx].y * cs),
          cs * 0.09,
          Paint()..color = Colors.black,
        );
      }
    }

    canvas.restore(); // End mask layer
    canvas.restore(); // End letter layer

    // Draw ghost letter for unrevealed portion (subtle hint)
    canvas.save();
    canvas.clipRect(rect);
    _paintGlyph(canvas, cs, letter.char, TracerTokens.ink, opacity: 0.10);
    canvas.restore();
  }

  void _drawStrokePath(Canvas canvas, List<Pt> pts, double cs, Paint paint) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts[0].x * cs, pts[0].y * cs);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].x * cs, pts[i].y * cs);
    }
    canvas.drawPath(path, paint);
  }

  // ─── 3. GUIDE LAYER (waypoints + target dot) ──────────
  void _drawGuide(Canvas canvas, double cs) {
    if (sIdx >= normSt.length) return;
    final pts = normSt[sIdx].points;
    if (pts.length < 2) return;

    // Dotted centerline
    final linePaint = Paint()
      ..color = const Color(0x381D4ED8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path()..moveTo(pts[0].x * cs, pts[0].y * cs);
    for (int i = 1; i < pts.length - 1; i++) {
      final mx = (pts[i].x + pts[i + 1].x) / 2 * cs;
      final my = (pts[i].y + pts[i + 1].y) / 2 * cs;
      linePath.conicTo(pts[i].x * cs, pts[i].y * cs, mx, my, 1.0);
    }
    linePath.lineTo(pts.last.x * cs, pts.last.y * cs);
    _dashedPath(canvas, linePath, linePaint, 4, 6);

    // Numbered waypoints
    final wCount = math.min(pts.length, 6);
    final step = (pts.length - 1) / math.max(wCount - 1, 1);
    final dotR = math.max(7.0, cs * 0.02);
    final fSize = math.max(8.0, cs * 0.023);

    for (int wi = 0; wi < wCount; wi++) {
      final idx = math.min((wi * step).round(), pts.length - 1);
      final p = Offset(pts[idx].x * cs, pts[idx].y * cs);
      final reached = idx < fillIdx;
      final isFirst = wi == 0;

      // Glow for first dot
      if (isFirst && !reached) {
        canvas.drawCircle(p, dotR + 4,
          Paint()..color = const Color(0x1A1D4ED8));
      }

      // Filled dot
      canvas.drawCircle(p, dotR, Paint()..color = reached
          ? const Color(0xD915803D)
          : isFirst
              ? const Color(0xFF1D4ED8)
              : const Color(0x801D4ED8));

      // White ring
      canvas.drawCircle(p, dotR, Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

      // Number
      final tp = TextPainter(
        text: TextSpan(text: '${wi + 1}', style: TextStyle(
          fontSize: fSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        )),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2 + 0.5));
    }

    // Moving target dot
    if (fillIdx < pts.length) {
      final tp = Offset(pts[fillIdx].x * cs, pts[fillIdx].y * cs);
      final targetR = cs * 0.012;
      canvas.drawCircle(tp, targetR, Paint()..color = const Color(0xFF1D4ED8));
      canvas.drawCircle(tp, targetR, Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    }
  }

  // ─── GLYPH PAINTER (font-based, professional) ────────
  void _paintGlyph(Canvas canvas, double cs, String char, Color color,
      {double opacity = 1.0}) {
    canvas.save();
    if (opacity < 1.0) {
      canvas.saveLayer(Rect.fromLTWH(0, 0, cs, cs),
        Paint()..color = color.withValues(alpha: opacity));
    }

    final tp = TextPainter(
      text: TextSpan(text: char, style: TextStyle(
        fontFamily: 'jomolhari',
        fontSize: cs * 0.65,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.0,
      )),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: cs);
    tp.paint(canvas, Offset((cs - tp.width) / 2, (cs - tp.height) / 2));

    if (opacity < 1.0) canvas.restore();
    canvas.restore();
  }

  // ─── DASHED LINE ─────────────────────────────────────
  void _dashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint,
      [double dash = 3, double gap = 6]) {
    final dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final nx = dx / len, ny = dy / len;
    double d = 0; bool draw = true;
    while (d < len) {
      final seg = draw ? dash : gap;
      final end = math.min(d + seg, len);
      if (draw) canvas.drawLine(
        Offset(p1.dx + nx * d,   p1.dy + ny * d),
        Offset(p1.dx + nx * end, p1.dy + ny * end),
        paint,
      );
      d = end; draw = !draw;
    }
  }

  // ─── DASHED PATH ─────────────────────────────────────
  void _dashedPath(Canvas canvas, Path path, Paint paint,
      double dash, double gap) {
    for (final m in path.computeMetrics()) {
      double d = 0; bool draw = true;
      while (d < m.length) {
        final seg = draw ? dash : gap;
        final end = math.min(d + seg, m.length);
        if (draw) canvas.drawPath(m.extractPath(d, end), paint);
        d = end; draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(TracerPainter old) {
    if (old.isDone   != isDone   ) return true;
    if (old.sIdx     != sIdx     ) return true;
    if (old.fillIdx  != fillIdx  ) return true;
    if (old.letter   != letter   ) return true;
    if (old.revealed.length != revealed.length) return true;
    for (int i = 0; i < revealed.length; i++) {
      if (old.revealed[i] != revealed[i]) return true;
    }
    return false;
  }
}
