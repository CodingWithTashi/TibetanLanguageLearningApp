import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/message_dialog.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

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
      //print("word complees");
      if (wordAnswered == AppConstant.allWords.length) {
        sessionCompleted = true;
      }
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            String title = "Well Done";
            String buttonText = "Generate New";
            if (sessionCompleted) {
              title = "All word completed";
              buttonText = "Replay";
            }
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              actions: [
                InkWell(
                  child: Container(
                    width: 200,
                    decoration: ApplicationUtil.getBoxDecorationOne(context),
                    child: Center(
                      child: Text(
                        buttonText,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (sessionCompleted) {
                      reset();
                      Navigator.of(context)
                          .pushReplacementNamed(SpellingBeePage.routeName);
                    } else {
                      requestWord(request: true);
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            );
          });
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
