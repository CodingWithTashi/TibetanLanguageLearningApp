import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

import '../../../../game_bloc/game_bloc.dart';
import '../../util/game_model.dart';
import '../../widget/game_animations.dart';
import '../../widget/game_ui.dart';
import '../spelling_bee_page.dart';

/// One round of Spelling Bee: every word in [AppConstant.verbsList], in a
/// random order, one after another.
class SpellingBeeProvider extends ChangeNotifier {
  int totalLetters = 0, lettersAnswered = 0, wordAnswered = 0;
  bool generateWord = true, sessionCompleted = false;

  /// True once this round has unlocked Snake, so the page can say so.
  bool nextGameUnlocked = false;

  setUp({required int total}) {
    lettersAnswered = 0;
    totalLetters = total;
    notifyListeners();
  }

  incrementLetters({required BuildContext context}) {
    lettersAnswered++;
    if (lettersAnswered == totalLetters) {
      wordAnswered++;
      final total = AppConstant.verbsList.length;
      if (wordAnswered == math.min(kSpellingBeeWordsToUnlock, total)) {
        _unlockNextGame(context);
      }
      if (wordAnswered == total) {
        sessionCompleted = true;
        _showRoundComplete(context, total);
      } else {
        // On to the next word.
        requestWord(request: true);
      }
    }
    notifyListeners();
  }

  /// Snake needs a score of 1 here (see GameBloc), sent after
  /// [kSpellingBeeWordsToUnlock] words.
  void _unlockNextGame(BuildContext context) {
    final games = context.read<GameBloc>();
    final snakeWasLocked = games.state.games
        .any((g) => g.gameType == GameType.snakeGame && !g.isUnlocked);
    games.add(UpdateGameScore(gameType: GameType.spellingBeeGame, score: 1));
    if (snakeWasLocked) nextGameUnlocked = true;
  }

  void _showRoundComplete(BuildContext context, int total) {
    // The celebration is part of the dialog, so it shows above the dimmed
    // background instead of behind it.
    showGameDialog(
      context,
      header: const GameCelebration(type: GameType.spellingBeeGame),
      title: 'Congrats!',
      message: 'You spelled all $total words. '
          'You just cracked spelling bee contest ❤.',
      actions: [
        GameDialogAction(
          'Exit',
          icon: Icons.logout_rounded,
          onPressed: () {
            reset();
            Navigator.pop(context);
          },
        ),
        GameDialogAction(
          'Play again',
          icon: Icons.replay_rounded,
          filled: true,
          // A fresh page and provider: all words again, in a new order.
          onPressed: () => Navigator.pushReplacementNamed(
              context, SpellingBeePage.routeName),
        ),
      ],
    );
  }

  requestWord({required bool request}) {
    generateWord = request;
    notifyListeners();
  }

  reset() {
    sessionCompleted = false;
    wordAnswered = 0;
    generateWord = true;
  }
}
