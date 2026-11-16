import 'package:material_ui/material_ui.dart';

import '../../widget/game_ui.dart';

/// Slot for one letter of the word. Takes only its own letter.
///
/// Stateful so a filled slot stays filled when the page rebuilds. The page
/// keys each slot per word, which also keeps it filled when the phone turns.
class Drop extends StatefulWidget {
  final String letter;
  final double size;

  const Drop({Key? key, required this.letter, required this.size})
      : super(key: key);

  @override
  State<Drop> createState() => _DropState();
}

class _DropState extends State<Drop> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return SizedBox.square(
      dimension: widget.size,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) =>
            !_accepted && details.data == widget.letter,
        onAcceptWithDetails: (_) => setState(() => _accepted = true),
        builder: (context, candidates, rejected) {
          if (_accepted) {
            // Settles in with a little bounce.
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: LetterTile(
                  letter: widget.letter, size: widget.size, placed: true),
            );
          }
          final hovering = candidates.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: palette.lime.withValues(alpha: hovering ? 0.35 : 0.1),
              borderRadius: BorderRadius.circular(widget.size * 0.22),
              border: Border.all(
                color: palette.cream.withValues(alpha: hovering ? 0.9 : 0.45),
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
