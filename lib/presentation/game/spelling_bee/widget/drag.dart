import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

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
    return Selector<SpellingBeeProvider, bool>(
      shouldRebuild: (previous, next) {
        return true;
      },
      selector: (context, controller) => controller.generateWord,
      builder: (_, generate, __) {
        if (generate) {
          _accepted = false;
        }
        return SizedBox(
          width: size.width * 0.20,
          height: size.height * 0.20,
          child: Center(
            child: _accepted
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: size.width * 0.15,
                    height: size.width * 0.15,
                    decoration: ApplicationUtil.getBoxDecorationOne(context),
                    child: Center(
                      child: Draggable(
                        data: widget.letter,
                        childWhenDragging: SizedBox(),
                        onDragEnd: (details) {
                          if (details.wasAccepted) {
                            _accepted = true;
                            setState(() {});
                            Provider.of<SpellingBeeProvider>(context,
                                    listen: false)
                                .incrementLetters(context: context);
                          }
                        },
                        feedback: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: size.width * 0.10,
                          height: size.width * 0.10,
                          decoration:
                              ApplicationUtil.getBoxDecorationOne(context),
                          child: Center(
                            child: Text(
                              widget.letter,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(3, 3),
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        child: Container(
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          decoration:
                              ApplicationUtil.getBoxDecorationOne(context),
                          child: Center(
                            child: Text(
                              widget.letter,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
