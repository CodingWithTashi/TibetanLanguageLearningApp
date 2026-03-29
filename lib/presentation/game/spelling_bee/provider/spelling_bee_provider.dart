import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

import '../../../../game_bloc/game_bloc.dart';
import '../../util/game_model.dart';
import '../../widgets/game_result_dialog.dart';

class SpellingBeeProvider extends ChangeNotifier {
  int totalLetters = 0, lettersAnswered = 0, wordAnswered = 0;
  bool generateWord = true, sessionCompleted = false;
  setUp({required int total}) {
    lettersAnswered = 0;
    totalLetters = total;
    notifyListeners();
  }

  incrementLetters({required BuildContext context}) {
    lettersAnswered++;
    if (lettersAnswered == totalLetters) {
      wordAnswered++;
      if (wordAnswered == AppConstant.verbsList.length) {
        sessionCompleted = true;
      }
      if (sessionCompleted) {
        // Calculate stars and coins based on performance
        final totalWords = AppConstant.verbsList.length;
        final stars = 3; // Perfect completion = 3 stars
        final score = wordAnswered * 10; // 10 points per word
        final coinsEarned = score + (stars * 20);

        // Update game stats
        context.read<GameBloc>().add(UpdateGameStars(
              gameType: GameType.spellingBeeGame,
              stars: stars,
              coinsEarned: coinsEarned,
            ));

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) {
            return GameResultDialog(
              title: 'Perfect! 🐝🌟',
              score: score,
              stars: stars,
              coinsEarned: coinsEarned,
              message:
                  'You completed all $totalWords words!\n\nYou\'re a Spelling Bee Champion!',
              onPlayAgain: () {
                reset();
                Navigator.pop(dialogContext);
              },
              onExit: () {
                reset();
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
            );
          },
        );
      } else {
        requestWord(request: true);
      }
    }
    notifyListeners();
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
