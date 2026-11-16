import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';

import '../../widget/game_ui.dart';

/// A letter tile the player drags into its slot. Leaves a faint outline
/// behind once it has been placed.
class Drag extends StatefulWidget {
  final String letter;
  final double size;

  const Drag({Key? key, required this.letter, required this.size})
      : super(key: key);

  @override
  State<Drag> createState() => _DragState();
}

class _DragState extends State<Drag> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    final ghost = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size * 0.22),
        border: Border.all(
            color: palette.cream.withValues(alpha: 0.25), width: 1.5),
      ),
    );
    return Selector<SpellingBeeProvider, bool>(
      shouldRebuild: (previous, next) => true,
      selector: (context, controller) => controller.generateWord,
      builder: (_, generate, __) {
        if (generate) {
          _accepted = false;
        }
        if (_accepted) return ghost;
        return Draggable<String>(
          data: widget.letter,
          childWhenDragging: ghost,
          onDragEnd: (details) {
            if (details.wasAccepted) {
              setState(() => _accepted = true);
              Provider.of<SpellingBeeProvider>(context, listen: false)
                  .incrementLetters(context: context);
            }
          },
          feedback: Material(
            type: MaterialType.transparency,
            child: Transform.scale(
              scale: 1.1,
              child: LetterTile(
                  letter: widget.letter, size: widget.size, lifted: true),
            ),
          ),
          child: LetterTile(letter: widget.letter, size: widget.size),
        );
      },
    );
  }
}
