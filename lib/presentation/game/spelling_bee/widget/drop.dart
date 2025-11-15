import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

class Drop extends StatefulWidget {
  final String letter;
  const Drop({Key? key, required this.letter}) : super(key: key);

  @override
  State<Drop> createState() => _DropState();
}

class _DropState extends State<Drop> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.20,
      height: size.height * 0.20,
      child: Center(
        child: DragTarget<String>(
          onWillAccept: (data) {
            if (data == widget.letter && !accepted) {
              print("accepted: ${widget.letter}");
              return true;
            } else {
              print("rejected");
              return false;
            }
          },
          onAccept: (data) {
            setState(() {
              accepted = true;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: ApplicationUtil.getBoxDecorationOne(context),
              width: size.width * 0.15,
              height: size.width * 0.15,
              child: Center(
                child: accepted
                    ? Text(
                        widget.letter,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'jomolhari',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : Container(),
              ),
            );
          },
        ),
      ),
    );
  }
}
