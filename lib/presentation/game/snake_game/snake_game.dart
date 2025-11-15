import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/snake_game/snake_game_bloc.dart';
import '../../../game_bloc/game_bloc.dart';
import '../../../util/constant.dart';
import '../../../util/application_util.dart';
import '../util/game_model.dart';
import '../widgets/game_layout.dart';
import '../widgets/game_score_card.dart';
import '../widgets/game_result_dialog.dart';

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
    return BlocConsumer<SnakeGameBloc, SnakeGameState>(
      listener: (context, state) {
        if (state.isGameOver) {
          _showGameOverDialog(context, state.score);
        }
      },
      builder: (context, state) {
        final speedPercentage = ((300 - state.speed) / 250 * 100).toInt();

        return GameLayout(
          title: 'Snake Game 🐍',
          scoreCards: [
            GameScoreCard(
              label: 'Score',
              value: state.score.toString(),
              icon: Icons.stars,
            ),
            GameScoreCard(
              label: 'Speed',
              value: '$speedPercentage%',
              icon: Icons.speed,
            ),
            GameScoreCard(
              label: 'Letters',
              value: state.currentLetter,
              icon: Icons.text_fields,
            ),
          ],
          gameContent: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (state.direction != 'up' && details.delta.dy > 0) {
                      context.read<SnakeGameBloc>().add(ChangeDirection('down'));
                    } else if (state.direction != 'down' && details.delta.dy < 0) {
                      context.read<SnakeGameBloc>().add(ChangeDirection('up'));
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (state.direction != 'left' && details.delta.dx > 0) {
                      context.read<SnakeGameBloc>().add(ChangeDirection('right'));
                    } else if (state.direction != 'right' && details.delta.dx < 0) {
                      context.read<SnakeGameBloc>().add(ChangeDirection('left'));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Theme.of(context).primaryColorLight,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(-5, -5),
                          blurRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          offset: const Offset(5, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 20,
                        ),
                        itemCount: 700, // Match playableGridSize (35 rows × 20 columns)
                        itemBuilder: (context, index) {
                          if (state.snakePosition.contains(index)) {
                            return _buildSnakeBody(index == state.snakePosition.last);
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
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    if (!state.isPlaying) {
                      context.read<SnakeGameBloc>().add(StartGame());
                    } else {
                      context.read<SnakeGameBloc>().add(EndGame());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: ApplicationUtil.getBoxDecorationOne(context),
                    child: Center(
                      child: Text(
                        state.isPlaying ? 'End Game' : 'Start Game',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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


  void _showGameOverDialog(BuildContext context, int score) {
    // Calculate stars based on score (realistic thresholds for snake game)
    int stars = 0;
    String resultTitle;
    String resultMessage;

    if (score >= 10) {
      stars = 3; // Excellent - 10+ letters collected
      resultTitle = 'Amazing! 🐍🌟';
      resultMessage = 'You collected $score Tibetan letters!\n\nYou\'re a Snake Master!';
    } else if (score >= 6) {
      stars = 2; // Good - 6-9 letters collected
      resultTitle = 'Great Job! 🐍';
      resultMessage = 'You collected $score Tibetan letters!\n\nKeep practicing!';
    } else if (score >= 3) {
      stars = 1; // Basic - 3-5 letters collected
      resultTitle = 'Good Try! 🐍';
      resultMessage = 'You collected $score Tibetan letters!\n\nNext level unlocked!';
    } else {
      stars = 0; // Failed - less than 3 letters
      resultTitle = 'Game Over 💪';
      resultMessage = 'You collected $score Tibetan letters.\n\nNeed 3+ letters to unlock next level!';
    }

    final coinsEarned = score * 5 + (stars * 10);

    // Update game stats only if player earned at least 1 star
    if (stars > 0) {
      context.read<GameBloc>().add(UpdateGameStars(
            gameType: GameType.snakeGame,
            stars: stars,
            coinsEarned: coinsEarned,
          ));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return GameResultDialog(
          title: resultTitle,
          score: score,
          stars: stars,
          coinsEarned: coinsEarned,
          message: resultMessage,
          onPlayAgain: () {
            Navigator.of(dialogContext).pop();
            context.read<SnakeGameBloc>().add(StartGame());
          },
          onExit: () {
            Navigator.of(dialogContext).pop();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
