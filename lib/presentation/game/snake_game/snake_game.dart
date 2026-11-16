import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/snake_game/snake_game_bloc.dart';
import '../../../game_bloc/game_bloc.dart';
import '../../../util/constant.dart';
import '../util/game_model.dart';
import '../widget/game_animations.dart';
import '../widget/game_ui.dart';

// Board size used by SnakeGameBloc: 20 columns, 760 cells.
const _columns = 20;
const _rows = SnakeGameBloc.gridSize ~/ _columns;

class SnakeGamePage extends StatefulWidget {
  static const routeName = 'snake-game';

  const SnakeGamePage({Key? key}) : super(key: key);

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  // The tall board would be tiny on a phone turned sideways.
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // Back to the orientations the app allows everywhere else.
    SystemChrome.setPreferredOrientations(const []);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SnakeGameBloc(),
      child: const SnakeGameView(),
    );
  }
}

class SnakeGameView extends StatelessWidget {
  const SnakeGameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SnakeGameBloc, SnakeGameState>(
      // Unlocks the next game once enough letters are eaten.
      listenWhen: (previous, current) =>
          current.score != previous.score &&
          current.score > kLevelOneScoreLimit,
      listener: (context, state) {
        context.read<GameBloc>().add(UpdateGameScore(
              gameType: GameType.snakeGame,
              score: kLevelOneScoreLimit,
            ));
      },
      child: BlocConsumer<SnakeGameBloc, SnakeGameState>(
        // Only on the change, so a late tick can't open a second dialog.
        listenWhen: (previous, current) =>
            !previous.isGameOver && current.isGameOver,
        listener: (context, state) => _showGameOver(context, state.score),
        builder: (context, state) {
          final speed = ((300 - state.speed) / 250 * 100).toStringAsFixed(0);
          return GameScaffold(
            title: 'Snake Game',
            chips: [
              GameChip(icon: Icons.star_rounded, label: '${state.score}'),
              GameChip(icon: Icons.speed_rounded, label: '$speed%'),
            ],
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _columns / _rows,
                      child: _SwipeArea(
                        state: state,
                        child: GamePanel(
                          padding: const EdgeInsets.all(6),
                          child: GameInset(
                            radius: 12,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CustomPaint(
                                  key: const ValueKey('snake-board'),
                                  painter: _BoardPainter(
                                    state: state,
                                    palette: GamePalette.of(context),
                                  ),
                                ),
                                if (!state.isPlaying) const _StartHint(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GameButton(
                  label: state.isPlaying ? 'End game' : 'Start game',
                  icon: state.isPlaying
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  onPressed: () {
                    final bloc = context.read<SnakeGameBloc>();
                    bloc.add(state.isPlaying ? EndGame() : StartGame());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showGameOver(BuildContext context, int score) {
    final bloc = context.read<SnakeGameBloc>();
    showGameDialog(
      context,
      header: GameCelebration(type: GameType.snakeGame, burst: score > 0),
      title: score > 0 ? 'Well played!' : 'Game over',
      message: 'Your snake ate $score ${score == 1 ? 'letter' : 'letters'}.',
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
          onPressed: () => bloc.add(StartGame()),
        ),
      ],
    );
  }
}

/// Turns swipes into direction changes, as before.
class _SwipeArea extends StatelessWidget {
  const _SwipeArea({required this.state, required this.child});

  final SnakeGameState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SnakeGameBloc>();
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (state.direction != 'up' && details.delta.dy > 0) {
          bloc.add(ChangeDirection('down'));
        } else if (state.direction != 'down' && details.delta.dy < 0) {
          bloc.add(ChangeDirection('up'));
        }
      },
      onHorizontalDragUpdate: (details) {
        if (state.direction != 'left' && details.delta.dx > 0) {
          bloc.add(ChangeDirection('right'));
        } else if (state.direction != 'right' && details.delta.dx < 0) {
          bloc.add(ChangeDirection('left'));
        }
      },
      child: child,
    );
  }
}

class _StartHint extends StatelessWidget {
  const _StartHint();

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return ColoredBox(
      color: palette.deep.withValues(alpha: 0.55),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe_rounded, color: palette.lime, size: 44),
              const SizedBox(height: 12),
              Text(
                'Swipe to steer the snake and eat the letters',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.cream, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the board, the snake and the letter to eat.
class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.state, required this.palette});

  final SnakeGameState state;
  final GamePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    // Square cells, centred, whatever the box's exact shape.
    final cell = math.min(size.width / _columns, size.height / _rows);
    final origin = Offset(
      (size.width - cell * _columns) / 2,
      (size.height - cell * _rows) / 2,
    );
    Rect cellRect(int index) => Rect.fromLTWH(
          origin.dx + (index % _columns) * cell,
          origin.dy + (index ~/ _columns) * cell,
          cell,
          cell,
        );

    final dot = Paint()..color = palette.cream.withValues(alpha: 0.07);
    for (var i = 0; i < SnakeGameBloc.gridSize; i++) {
      canvas.drawCircle(cellRect(i).center, cell * 0.08, dot);
    }

    if (state.isPlaying || state.isGameOver) {
      final food = cellRect(state.food).center;
      canvas.drawCircle(food, cell * 1.15,
          Paint()..color = palette.lime.withValues(alpha: 0.18));
      canvas.drawCircle(food, cell * 0.82, Paint()..color = palette.cream);
      final letter = TextPainter(
        text: TextSpan(
          text: state.currentLetter,
          style: TextStyle(
            fontFamily: kLetterFont,
            fontSize: cell * 1.05,
            color: palette.ink,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      letter.paint(
        canvas,
        food - Offset(letter.width / 2, letter.height / 2 - cell * 0.1),
      );
    }

    final body = state.snakePosition;
    for (var i = 0; i < body.length; i++) {
      final isHead = i == body.length - 1;
      final share = body.length == 1 ? 1.0 : i / (body.length - 1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          cellRect(body[i]).deflate(cell * (isHead ? 0.02 : 0.08)),
          Radius.circular(cell * 0.38),
        ),
        Paint()..color = Color.lerp(palette.limeDim, palette.lime, share)!,
      );
    }

    if (body.isNotEmpty) {
      final head = cellRect(body.last).center;
      Offset forward;
      switch (state.direction) {
        case 'up':
          forward = const Offset(0, -1);
          break;
        case 'left':
          forward = const Offset(-1, 0);
          break;
        case 'right':
          forward = const Offset(1, 0);
          break;
        default:
          forward = const Offset(0, 1);
      }
      final side = Offset(-forward.dy, forward.dx);
      final eye = Paint()..color = palette.ink;
      for (final sign in [-1.0, 1.0]) {
        canvas.drawCircle(
          head + forward * cell * 0.18 + side * cell * 0.22 * sign,
          cell * 0.11,
          eye,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.state != state || old.palette != palette;
}
