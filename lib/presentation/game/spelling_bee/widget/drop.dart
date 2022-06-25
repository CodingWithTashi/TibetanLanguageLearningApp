import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

class Drop extends StatelessWidget {
  final String letter;
  const Drop({Key? key, required this.letter}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    bool accepted = false;
    return Container(
      width: size.width * 0.20,
      height: size.height * 0.20,
      child: Center(
        child: DragTarget(
          onWillAccept: (data) {
            if (data == letter) {
              print("accepted");
              return true;
            } else {
              print("rejected");
              return false;
            }
          },
          onAccept: (data) {
            accepted = true;
          },
          builder: (context, candidateData, rejectedData) {
            if (accepted) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: ApplicationUtil.getBoxDecorationOne(context),
                width: size.width * 0.15,
                height: size.width * 0.15,
                child: Center(
                  child: Text(
                    letter,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              );
            } else {
              return Container(
                width: size.width * 0.15,
                height: size.width * 0.15,
                decoration: ApplicationUtil.getBoxDecorationOne(context),
              );
            }
          },
        ),
      ),
    );
  }
}
