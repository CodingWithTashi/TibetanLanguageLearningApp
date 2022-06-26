import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/message_dialog.dart';
import 'package:tibetan_language_learning_app/presentation/home.dart';
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
      if (wordAnswered == AppConstant.verbsList.length) {
        sessionCompleted = true;
      }
      if (sessionCompleted) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              String title =
                  "Congrats! You just cracked spelling bee contest ❤.";
              String buttonText = "Exit Game";
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
                      width: 120,
                      decoration: ApplicationUtil.getBoxDecorationOne(context),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      reset();
                      Navigator.pushNamedAndRemoveUntil(
                          context, HomePage.routeName, (route) => false);
                    },
                  )
                ],
              );
            });
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
