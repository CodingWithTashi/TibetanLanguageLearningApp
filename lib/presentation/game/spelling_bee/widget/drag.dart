import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/controller.dart';

class Drag extends StatefulWidget {
  final String letter;
  const Drag({Key? key, required this.letter}) : super(key: key);

  @override
  State<Drag> createState() => _DragState();
}

class _DragState extends State<Drag> {
  bool _accepted = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Selector<Controller, bool>(
      shouldRebuild: (previous, next) {
        return true;
      },
      selector: (context, controller) => controller.generateWord,
      builder: (_, generate, __) {
        if (generate) {
          _accepted = false;
        }
        return SizedBox(
          width: size.width * 0.15,
          height: size.height * 0.15,
          child: Center(
            child: _accepted
                ? SizedBox()
                : Draggable(
                    data: widget.letter,
                    childWhenDragging: SizedBox(),
                    onDragEnd: (details) {
                      if (details.wasAccepted) {
                        _accepted = true;
                        setState(() {});
                        Provider.of<Controller>(context, listen: false)
                            .incrementLetters(context: context);
                      }
                    },
                    feedback: Text(
                      widget.letter,
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                        shadows: [
                          Shadow(
                            offset: Offset(3, 3),
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    child: Text(
                      widget.letter,
                      //style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
