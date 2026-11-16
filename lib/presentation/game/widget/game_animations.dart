import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../util/game_model.dart';
import 'game_ui.dart';

/// Hand-drawn animations for the games, in place of the downloaded Lottie
/// files and the confetti package: they load instantly, work offline and use
/// the app's greens.

/// Runs [builder] with a value going from 0 to 1 over [duration], repeating
/// unless [repeat] is false. Holds still at [stillValue] when the system asks
/// for reduced motion.
class LoopingAnimation extends StatefulWidget {
  const LoopingAnimation({
    Key? key,
    required this.duration,
    required this.builder,
    this.stillValue = 0.5,
    this.repeat = true,
  }) : super(key: key);

  final Duration duration;
  final double stillValue;
  final bool repeat;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<LoopingAnimation> createState() => _LoopingAnimationState();
}

class _LoopingAnimationState extends State<LoopingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = widget.stillValue;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      widget.repeat ? _controller.repeat() : _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(context, _controller.value),
    );
  }
}

/// Looping picture of how each game is played.
class GamePreview extends StatelessWidget {
  const GamePreview({Key? key, required this.type}) : super(key: key);

  final GameType type;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    switch (type) {
      case GameType.spellingBeeGame:
        return LoopingAnimation(
          duration: const Duration(milliseconds: 4200),
          stillValue: 0.8,
          builder: (_, t) => CustomPaint(
            size: Size.infinite,
            painter: _SpellingBeePainter(t, palette),
          ),
        );
      case GameType.snakeGame:
        return LoopingAnimation(
          duration: const Duration(milliseconds: 4800),
          stillValue: 0.15,
          builder: (_, t) => CustomPaint(
            size: Size.infinite,
            painter: _SnakePainter(t, palette),
          ),
        );
      case GameType.memoryGame:
        return LoopingAnimation(
          duration: const Duration(milliseconds: 5200),
          stillValue: 0.8,
          builder: (_, t) => CustomPaint(
            size: Size.infinite,
            painter: _MemoryPainter(t, palette),
          ),
        );
    }
  }
}

/// A burst of game-themed pieces: honeycomb cells for Spelling Bee, round
/// scales for Snake, little cards for Memory Match, with a few Tibetan
/// letters mixed in. Paints outside its box on purpose.
class CelebrationBurst extends StatelessWidget {
  const CelebrationBurst({Key? key, required this.type, this.repeat = true})
      : super(key: key);

  final GameType type;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return IgnorePointer(
      child: LoopingAnimation(
        duration: const Duration(milliseconds: 2600),
        repeat: repeat,
        stillValue: 1,
        builder: (_, t) => CustomPaint(
          size: Size.infinite,
          painter: _BurstPainter(t, type, palette),
        ),
      ),
    );
  }
}

/// The game's preview in a dark well with a burst behind it, for the
/// end-of-game dialogs.
class GameCelebration extends StatelessWidget {
  const GameCelebration({Key? key, required this.type, this.burst = true})
      : super(key: key);

  final GameType type;
  final bool burst;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (burst) Positioned.fill(child: CelebrationBurst(type: type)),
        Center(
          child: SizedBox.square(
            dimension: 140,
            child: GameInset(radius: 18, child: GamePreview(type: type)),
          ),
        ),
      ],
    );
  }
}

/// A padlock that gives a little shake now and then.
class LockedAnimation extends StatelessWidget {
  const LockedAnimation({Key? key, this.size = 96}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return LoopingAnimation(
      duration: const Duration(milliseconds: 2000),
      stillValue: 0.9,
      builder: (_, t) {
        final shake = t < 0.4
            ? math.sin(t / 0.4 * math.pi * 6) * 0.2 * (1 - t / 0.4)
            : 0.0;
        return Center(
          child: Transform.rotate(
            angle: shake,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: palette.lime,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.lock_rounded,
                  color: palette.ink, size: size * 0.5),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Painters

/// 0 before [begin], 1 after [end], [curve] in between.
double _span(double t, double begin, double end,
    [Curve curve = Curves.linear]) {
  if (t <= begin) return 0;
  if (t >= end) return 1;
  return curve.transform((t - begin) / (end - begin));
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

void _paintLetter(
    Canvas canvas, String letter, Offset center, double size, Color color) {
  final painter = TextPainter(
    text: TextSpan(
      text: letter,
      style: TextStyle(fontFamily: kLetterFont, fontSize: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  // Tibetan fonts leave a lot of room under the line; nudge down so the
  // letter looks centred.
  painter.paint(
    canvas,
    center - Offset(painter.width / 2, painter.height / 2 - size * 0.12),
  );
}

/// Letter tiles hop into their slots one by one to spell ཁ་པར (phone) while a
/// bee buzzes overhead.
class _SpellingBeePainter extends CustomPainter {
  _SpellingBeePainter(this.t, this.palette);

  final double t;
  final GamePalette palette;

  static const _letters = ['ཁ', 'པ', 'ར'];
  static const _slots = [0.22, 0.5, 0.78];
  static const _from = [0.78, 0.22, 0.5];

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    final tile = s * 0.22;
    final slotY = s * 0.74;
    final startY = s * 0.44;
    final appear = _span(t, 0, 0.08);
    final vanish = _span(t, 0.92, 1);
    final done = _span(t, 0.72, 0.8, Curves.easeOut) * (1 - vanish);
    final radius = Radius.circular(tile * 0.24);

    for (var i = 0; i < 3; i++) {
      final slot = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(_slots[i] * s, slotY), width: tile, height: tile),
        radius,
      );
      canvas.drawRRect(
        slot,
        Paint()..color = palette.lime.withValues(alpha: 0.10 + 0.25 * done),
      );
      canvas.drawRRect(
        slot,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.012
          ..color = palette.cream.withValues(alpha: 0.35 + 0.4 * done),
      );
    }

    final opacity = appear * (1 - vanish);
    for (var i = 0; i < 3; i++) {
      final p = _span(t, 0.12 + 0.18 * i, 0.3 + 0.18 * i, Curves.easeInOut);
      final center = Offset(
        _lerp(_from[i], _slots[i], p) * s,
        _lerp(startY, slotY, p) - math.sin(p * math.pi) * s * 0.16,
      );
      final scale = 1 + 0.1 * math.sin(p * math.pi);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: tile * scale, height: tile * scale),
        radius,
      );
      canvas.drawRRect(
        rect.shift(Offset(0, s * 0.012)),
        Paint()..color = Colors.black.withValues(alpha: 0.25 * opacity),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Color.lerp(palette.cream, palette.lime, done)!
              .withValues(alpha: opacity),
      );
      _paintLetter(canvas, _letters[i], center, tile * 0.62 * scale,
          palette.ink.withValues(alpha: opacity));
    }

    _paintBee(canvas, s);
    canvas.restore();
  }

  void _paintBee(Canvas canvas, double s) {
    final angle = 2 * math.pi * t;
    final position = Offset(
      s * (0.5 + 0.34 * math.cos(angle)),
      s * (0.19 + 0.06 * math.sin(2 * angle)),
    );
    // Moving left while sin > 0; the bee is drawn facing right.
    final facingLeft = math.sin(angle) > 0;
    final flap = 0.55 + 0.45 * math.sin(t * 2 * math.pi * 26).abs();

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(facingLeft ? -1.35 : 1.35, 1.35);

    final wing = Paint()..color = Colors.white.withValues(alpha: 0.7);
    void drawWing(double dx, double tilt) {
      canvas.save();
      canvas.translate(dx, -s * 0.05);
      canvas.rotate(tilt);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(0, -s * 0.02 * flap),
            width: s * 0.06,
            height: s * 0.09 * flap),
        wing,
      );
      canvas.restore();
    }

    drawWing(-s * 0.025, -0.35);

    final body = Rect.fromCenter(
        center: Offset.zero, width: s * 0.15, height: s * 0.105);
    canvas.drawOval(body, Paint()..color = palette.lime);
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    final stripe = Paint()..color = palette.ink;
    for (final x in [-0.035, 0.0]) {
      canvas.drawRect(
        Rect.fromLTWH(s * x, -s * 0.06, s * 0.018, s * 0.12),
        stripe,
      );
    }
    canvas.restore();
    // Stinger and head.
    canvas.drawPath(
      Path()
        ..moveTo(-s * 0.072, -s * 0.012)
        ..lineTo(-s * 0.1, 0)
        ..lineTo(-s * 0.072, s * 0.012)
        ..close(),
      stripe,
    );
    canvas.drawCircle(Offset(s * 0.07, 0), s * 0.034, stripe);
    canvas.drawCircle(
        Offset(s * 0.08, -s * 0.01), s * 0.009, Paint()..color = palette.cream);

    drawWing(s * 0.01, 0.3);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpellingBeePainter old) =>
      old.t != t || old.palette != palette;
}

/// A snake glides round a small board and gobbles letters, which pop and
/// come back.
class _SnakePainter extends CustomPainter {
  _SnakePainter(this.t, this.palette);

  final double t;
  final GamePalette palette;

  static const _foods = [0.3, 0.72];
  static const _letters = ['ཀ', 'ག'];

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    final dot = Paint()..color = palette.cream.withValues(alpha: 0.12);
    for (var x = 1; x < 6; x++) {
      for (var y = 1; y < 6; y++) {
        canvas.drawCircle(Offset(x * s / 6, y * s / 6), s * 0.009, dot);
      }
    }

    final track = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.2, s * 0.2, s * 0.6, s * 0.6),
        Radius.circular(s * 0.17),
      ));
    final metric = track.computeMetrics().first;
    final length = metric.length;

    for (var i = 0; i < _foods.length; i++) {
      final f = _foods[i];
      final at = metric.getTangentForOffset(f * length)!.position;
      final sinceEaten = (t - f) % 1.0;
      final r = s * 0.095;
      if (sinceEaten < 0.08) {
        final k = sinceEaten / 0.08;
        canvas.drawCircle(
          at,
          r * (1 + k * 1.3),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.014
            ..color = palette.lime.withValues(alpha: 1 - k),
        );
        continue;
      }
      if (sinceEaten < 0.45) continue;
      final grow = sinceEaten < 0.55
          ? Curves.easeOutBack.transform((sinceEaten - 0.45) / 0.1)
          : 1.0;
      canvas.drawCircle(at, r * grow, Paint()..color = palette.cream);
      _paintLetter(canvas, _letters[i], at, r * 1.3 * grow, palette.ink);
    }

    const segments = 8;
    final spacing = s * 0.072;
    final head = t * length;
    for (var k = segments - 1; k >= 0; k--) {
      final tangent =
          metric.getTangentForOffset((head - k * spacing) % length)!;
      final r = k == 0 ? s * 0.064 : s * (0.054 - k * 0.002);
      canvas.drawCircle(
        tangent.position,
        r,
        Paint()
          ..color =
              Color.lerp(palette.lime, palette.limeDim, k / (segments - 1))!,
      );
      if (k == 0) {
        final forward = tangent.vector;
        final side = Offset(-forward.dy, forward.dx);
        final eye = Paint()..color = palette.ink;
        for (final sign in [-1.0, 1.0]) {
          canvas.drawCircle(
            tangent.position + forward * s * 0.022 + side * s * 0.028 * sign,
            s * 0.012,
            eye,
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SnakePainter old) => old.t != t || old.palette != palette;
}

/// Four cards: two pairs are turned over, glow when they match, then all
/// turn back.
class _MemoryPainter extends CustomPainter {
  _MemoryPainter(this.t, this.palette);

  final double t;
  final GamePalette palette;

  // Top-left, top-right, bottom-left, bottom-right.
  static const _letters = ['ཀ', 'ག', 'ག', 'ཀ'];
  static const _flipUp = [0.05, 0.48, 0.62, 0.2];
  static const _matchAt = [0.3, 0.72, 0.72, 0.3];

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    final w = s * 0.3;
    final h = s * 0.36;
    final gap = s * 0.07;
    final left = (s - 2 * w - gap) / 2 + w / 2;
    final top = (s - 2 * h - gap) / 2 + h / 2;
    final down = _span(t, 0.88, 0.96, Curves.easeInOut);
    final radius = Radius.circular(s * 0.045);

    for (var i = 0; i < 4; i++) {
      final center =
          Offset(left + (i % 2) * (w + gap), top + (i ~/ 2) * (h + gap));
      final up = _span(t, _flipUp[i], _flipUp[i] + 0.08, Curves.easeInOut);
      final p = (up - down).clamp(0.0, 1.0);
      final glow = _span(t, _matchAt[i], _matchAt[i] + 0.06) * (1 - down);
      final pop = 1 +
          0.07 * math.sin(math.pi * _span(t, _matchAt[i], _matchAt[i] + 0.1));
      final squash = math.max(math.cos(math.pi * p).abs(), 0.02);
      final card = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h), radius);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(squash * pop, pop);
      canvas.drawRRect(card.shift(Offset(0, s * 0.012)),
          Paint()..color = Colors.black.withValues(alpha: 0.25));
      if (p > 0.5) {
        canvas.drawRRect(card, Paint()..color = palette.cream);
        _paintLetter(canvas, _letters[i], Offset.zero, s * 0.17, palette.ink);
        if (glow > 0) {
          canvas.drawRRect(
            card.inflate(s * 0.012),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * 0.022
              ..color = palette.lime.withValues(alpha: glow),
          );
        }
      } else {
        canvas.drawRRect(card, Paint()..color = palette.card);
        final inner = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.01
          ..color = palette.lime.withValues(alpha: 0.5);
        canvas.drawRRect(card.deflate(s * 0.028), inner);
        canvas.drawPath(
          Path()
            ..moveTo(0, -h * 0.18)
            ..lineTo(w * 0.18, 0)
            ..lineTo(0, h * 0.18)
            ..lineTo(-w * 0.18, 0)
            ..close(),
          Paint()..color = palette.lime.withValues(alpha: 0.6),
        );
      }
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MemoryPainter old) =>
      old.t != t || old.palette != palette;
}

class _Particle {
  _Particle(math.Random random)
      : angle = -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.5,
        speed = 0.7 + random.nextDouble() * 0.6,
        spin = (random.nextDouble() - 0.5) * 3,
        size = 0.035 + random.nextDouble() * 0.03,
        color = random.nextInt(5),
        delay = random.nextDouble() * 0.12;

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final int color;
  final double delay;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t, this.type, this.palette);

  final double t;
  final GameType type;
  final GamePalette palette;

  static final List<_Particle> _particles = () {
    final random = math.Random(7);
    return List.generate(28, (_) => _Particle(random));
  }();

  static const _letters = ['ཀ', 'ཁ', 'ག', 'ང', 'ཅ', 'ཆ', 'ཇ'];

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.max(size.height, 120.0);
    final origin = Offset(size.width / 2, size.height * 0.55);
    // The burst takes the first 80% of the cycle; the rest is a pause.
    final time = (t / 0.8).clamp(0.0, 1.0);
    final fade = 1 - _span(time, 0.6, 1);
    if (fade == 0) return;
    final colors = palette.lights;

    for (var i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final local = ((time - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final velocity =
          Offset(math.cos(p.angle), math.sin(p.angle)) * p.speed * unit * 1.5;
      final position =
          origin + velocity * local + Offset(0, unit * 1.3 * local * local);
      final r = p.size * unit;
      final color = colors[p.color].withValues(alpha: fade);

      if (i % 6 == 0) {
        _paintLetter(canvas, _letters[i % _letters.length], position, r * 2.2,
            palette.cream.withValues(alpha: fade));
        continue;
      }

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(p.spin * local * math.pi * 2);
      final paint = Paint()..color = color;
      switch (type) {
        case GameType.spellingBeeGame:
          final hex = Path();
          for (var k = 0; k < 6; k++) {
            final a = math.pi / 3 * k;
            final point = Offset(math.cos(a), math.sin(a)) * r;
            k == 0
                ? hex.moveTo(point.dx, point.dy)
                : hex.lineTo(point.dx, point.dy);
          }
          canvas.drawPath(hex..close(), paint);
          break;
        case GameType.snakeGame:
          canvas.drawCircle(Offset.zero, r * 0.8, paint);
          break;
        case GameType.memoryGame:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: r * 1.3, height: r * 1.7),
              Radius.circular(r * 0.3),
            ),
            paint,
          );
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.t != t || old.type != type || old.palette != palette;
}
