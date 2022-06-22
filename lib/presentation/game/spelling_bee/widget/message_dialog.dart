import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';

class MessageDialog extends StatelessWidget {
  final bool sessionCompleted;
  const MessageDialog({
    Key? key,
    required this.sessionCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = "Well Done";
    String buttonText = "Generate New";
    if (sessionCompleted) {
      title = "All word completed";
      buttonText = "Replay";
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: Colors.amber,
      actionsAlignment: MainAxisAlignment.center,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            if (sessionCompleted) {
              Provider.of<SpellingBeeProvider>(context, listen: false).reset();
              Navigator.of(context)
                  .pushReplacementNamed(SpellingBeePage.routeName);
            } else {
              Provider.of<SpellingBeeProvider>(context, listen: false)
                  .requestWord(request: true);
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              buttonText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 30,
                  ),
            ),
          ),
        )
      ],
    );
  }
}
