import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/memory_match/memory_match_bloc.dart';
import '../../../model/memory_match.dart';
import '../../../util/constant.dart';
import '../util/game_model.dart';
import '../widget/game_animations.dart';
import '../widget/game_ui.dart';

class MemoryMatchGameScreen extends StatelessWidget {
  static const routeName = 'memory-match-game';

  const MemoryMatchGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MemoryMatchBloc()..add(InitializeGame(cards: generateMemoryCards())),
      child: const _MemoryMatchView(),
    );
  }
}

/// Pairs on the board: 8 cards around the score tile in a 3×3 grid.
const kMemoryPairs = 4;

/// [kMemoryPairs] random Tibetan consonants, each twice, shuffled.
List<String> generateMemoryCards() {
  final letters = AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET)
      .map((a) => a.alphabetName.replaceAll('་', ''))
      .toList()
    ..shuffle();
  final picked = letters.take(kMemoryPairs).toList();
  return [...picked, ...picked]..shuffle();
}

String _moves(int n) => n == 1 ? '1 move' : '$n moves';

class _MemoryMatchView extends StatelessWidget {
  const _MemoryMatchView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemoryMatchBloc, MemoryMatchState>(
      listenWhen: (previous, current) =>
          !previous.isGameComplete && current.isGameComplete,
      listener: (context, state) => _showWin(context, state.game!),
      builder: (context, state) {
        final game = state.game;
        return GameScaffold(
          title: 'Memory Match',
          chips: game == null
              ? const []
              : [
                  GameChip(
                    icon: Icons.touch_app_rounded,
                    label: _moves(game.attempts ~/ 2),
                  ),
                ],
          body: game == null
              ? Center(
                  child: CircularProgressIndicator(
                      color: GamePalette.of(context).lime),
                )
              : _Board(
                  game: game,
                  previewing: state.isPreviewing,
                  previewDuration:
                      context.read<MemoryMatchBloc>().previewDuration,
                ),
        );
      },
    );
  }

  void _showWin(BuildContext context, MemoryMatchGame game) {
    final bloc = context.read<MemoryMatchBloc>();
    showGameDialog(
      context,
      header: const GameCelebration(type: GameType.memoryGame),
      title: 'Well done!',
      message: 'You found all ${game.pairsFound} pairs '
          'in ${_moves(game.attempts ~/ 2)}.',
      actions: [
        GameDialogAction(
          'Exit',
          icon: Icons.logout_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        GameDialogAction(
          'Play again',
          icon: Icons.replay_rounded,
          filled: true,
          onPressed: () =>
              bloc.add(InitializeGame(cards: generateMemoryCards())),
        ),
      ],
    );
  }
}

/// 3×3: the cards fill the outer ring, the score tile sits in the middle.
class _Board extends StatelessWidget {
  const _Board({
    required this.game,
    required this.previewing,
    required this.previewDuration,
  });

  final MemoryMatchGame game;
  final bool previewing;
  final Duration previewDuration;

  static const _size = 3;
  static const _middle = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 12.0;
      const ratio = 1.25; // card height / width
      final width = math.min(
        (constraints.maxWidth - gap * (_size - 1)) / _size,
        (constraints.maxHeight - gap * (_size - 1)) / _size / ratio,
      );
      Widget cell(int position) {
        if (position == _middle) {
          return _ScoreTile(
            key: const ValueKey('memory-score'),
            game: game,
            previewing: previewing,
            previewDuration: previewDuration,
          );
        }
        final i = position < _middle ? position : position - 1;
        return _MemoryCard(
          key: ValueKey('card-$i'),
          letter: game.cards[i],
          faceUp: previewing || game.flipped[i] || game.matched[i],
          matched: game.matched[i],
          onTap: () {
            if (!previewing && game.currentlyFlipped.length < 2) {
              context.read<MemoryMatchBloc>().add(FlipCard(index: i));
            }
          },
        );
      }

      return Center(
        child: SizedBox(
          width: width * _size + gap * (_size - 1),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var p = 0; p < _size * _size; p++)
                SizedBox(width: width, height: width * ratio, child: cell(p)),
            ],
          ),
        ),
      );
    });
  }
}

/// The middle of the board: counts down while the cards are showing, then
/// shows the pairs found.
class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    Key? key,
    required this.game,
    required this.previewing,
    required this.previewDuration,
  }) : super(key: key);

  final MemoryMatchGame game;
  final bool previewing;
  final Duration previewDuration;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    final total = game.cards.length ~/ 2;
    final Widget content;
    if (previewing) {
      final seconds = previewDuration.inMilliseconds / 1000;
      content = TweenAnimationBuilder<double>(
        // Restarts with every new game.
        key: ObjectKey(game),
        tween: Tween(begin: 1, end: 0),
        duration: previewDuration,
        builder: (context, left, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_rounded, color: palette.lime, size: 22),
            const SizedBox(height: 6),
            SizedBox.square(
              dimension: 46,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: left,
                    strokeWidth: 4,
                    color: palette.lime,
                    backgroundColor: palette.lime.withValues(alpha: 0.2),
                  ),
                  Center(
                    child: Text(
                      '${math.max(1, (left * seconds).ceil())}',
                      style: TextStyle(
                        color: palette.cream,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('Remember!',
                style: TextStyle(color: palette.cream, fontSize: 13)),
          ],
        ),
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: palette.lime, size: 22),
          const SizedBox(height: 6),
          Text(
            '${game.pairsFound}/$total',
            style: TextStyle(
              color: palette.cream,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text('pairs', style: TextStyle(color: palette.cream, fontSize: 13)),
        ],
      );
    }
    return Semantics(
      label: previewing
          ? 'Remember the cards'
          : '${game.pairsFound} of $total pairs found',
      child: Container(
        decoration: BoxDecoration(
          color: palette.deep,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border:
              Border.all(color: palette.lime.withValues(alpha: 0.6), width: 2),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(padding: const EdgeInsets.all(8), child: content),
          ),
        ),
      ),
    );
  }
}

/// A card that turns over in 3D, and glows once its pair is found.
class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    Key? key,
    required this.letter,
    required this.faceUp,
    required this.matched,
    required this.onTap,
  }) : super(key: key);

  final String letter;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    const radius = BorderRadius.all(Radius.circular(14));
    final back = DecoratedBox(
      decoration: gameCardDecoration(context, radius: radius),
      child: CustomPaint(painter: _CardBackPainter(palette)),
    );
    final front = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: palette.cream,
        borderRadius: radius,
        border: Border.all(
          color: matched ? palette.lime : Colors.transparent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: matched
                ? palette.lime.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.25),
            blurRadius: matched ? 14 : 6,
            offset: matched ? Offset.zero : const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.7,
              heightFactor: 0.7,
              child: FittedBox(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontFamily: kLetterFont,
                    color: palette.ink,
                    fontSize: 48,
                  ),
                ),
              ),
            ),
          ),
          if (matched)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.check_circle_rounded,
                  color: palette.inkTeal, size: 18),
            ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: faceUp ? letter : 'Hidden card',
      child: GestureDetector(
        onTap: faceUp ? null : onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: faceUp ? 1 : 0),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
          builder: (context, turn, _) {
            final showFront = turn > 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(turn * math.pi),
              child: showFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: front,
                    )
                  : back,
            );
          },
        ),
      ),
    );
  }
}

/// Inner frame and a diamond, like the cards in the game list preview.
class _CardBackPainter extends CustomPainter {
  _CardBackPainter(this.palette);

  final GamePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.shortestSide * 0.09;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(inset),
        const Radius.circular(9),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = palette.lime.withValues(alpha: 0.45),
    );
    final c = size.center(Offset.zero);
    final d = size.shortestSide * 0.16;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - d * 1.2)
        ..lineTo(c.dx + d, c.dy)
        ..lineTo(c.dx, c.dy + d * 1.2)
        ..lineTo(c.dx - d, c.dy)
        ..close(),
      Paint()..color = palette.lime.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_CardBackPainter old) => old.palette != palette;
}
