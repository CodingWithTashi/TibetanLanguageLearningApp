import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/snake_game/snake_game_bloc.dart';
import '../../../game_bloc/game_bloc.dart';
import '../util/game_model.dart';

class SnakeGamePage extends StatelessWidget {
  static const routeName = 'snake-game';

  const SnakeGamePage({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<SnakeGameBloc, SnakeGameState>(
        listener: (context, state) {
          if (state.isGameOver) {
            _showGameOverDialog(context, state.score);
          } else if (state.score > 10) {
            context.read<GameBloc>().add(UpdateGameScore(
                  gameType: GameType.snakeGame,
                  score: 10,
                ));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                _buildScoreBoard(state.score, state.speed),
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (state.direction != 'up' && details.delta.dy > 0) {
                        context
                            .read<SnakeGameBloc>()
                            .add(ChangeDirection('down'));
                      } else if (state.direction != 'down' &&
                          details.delta.dy < 0) {
                        context
                            .read<SnakeGameBloc>()
                            .add(ChangeDirection('up'));
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      if (state.direction != 'left' && details.delta.dx > 0) {
                        context
                            .read<SnakeGameBloc>()
                            .add(ChangeDirection('right'));
                      } else if (state.direction != 'right' &&
                          details.delta.dx < 0) {
                        context
                            .read<SnakeGameBloc>()
                            .add(ChangeDirection('left'));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 20,
                        ),
                        itemCount: 760,
                        itemBuilder: (context, index) {
                          if (state.snakePosition.contains(index)) {
                            return _buildSnakeBody(
                                index == state.snakePosition.last);
                          }
                          if (index == state.food) {
                            return _buildFood(state.currentLetter);
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                ),
                _buildControlButton(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreBoard(int score, int speed) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Score: $score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Speed: ${((300 - speed) / 250 * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeBody(bool isHead) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isHead ? Colors.greenAccent : Colors.green,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: isHead
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.transparent,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFood(String letter) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.redAccent,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, SnakeGameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          if (!state.isPlaying) {
            context.read<SnakeGameBloc>().add(StartGame());
          } else {
            context.read<SnakeGameBloc>().add(EndGame());
          }
        },
        child: Text(
          state.isPlaying ? 'End Game' : 'Start Game',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.green, width: 2),
          ),
          title: const Text(
            'Game Over',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                  Navigator.pop(context);
                },
                child: Text(
                  'Exit',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                )),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SnakeGameBloc>().add(StartGame());
              },
              child: Text(
                'Play Again',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ],
        );
      },
    );
  }
}
