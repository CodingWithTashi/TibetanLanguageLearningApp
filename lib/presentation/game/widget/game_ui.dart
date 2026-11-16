import 'package:material_ui/material_ui.dart';

import '../../../util/application_util.dart';
import '../../../util/constant.dart';

/// Shared look for the game list and the three games: olive cards like the
/// home screen tiles, light green accents taken from the app's seed color.

const kGameRadius = BorderRadius.all(Radius.circular(18));

/// Tibetan letters are always drawn in Jomolhari: the English theme font
/// (Roboto) has no Tibetan glyphs.
const kLetterFont = AppConstant.JOMAHALI_FAMILY;

/// The few colors the game screens use, all from the theme's color scheme.
class GamePalette {
  GamePalette._(ColorScheme s)
      : card = s.primary,
        deep = s.onPrimaryContainer,
        lime = s.primaryContainer,
        limeDim = s.primaryFixedDim,
        cream = s.secondaryContainer,
        mint = s.tertiaryContainer,
        mintDim = s.tertiaryFixedDim,
        ink = s.onPrimaryContainer,
        inkTeal = s.onTertiaryContainer;

  factory GamePalette.of(BuildContext context) =>
      GamePalette._(Theme.of(context).colorScheme);

  /// Olive of the cards and buttons.
  final Color card;

  /// Darker olive for boards and insets.
  final Color deep;

  final Color lime;
  final Color limeDim;
  final Color cream;
  final Color mint;
  final Color mintDim;

  /// Text and icons on the light colors.
  final Color ink;
  final Color inkTeal;

  List<Color> get lights => [lime, mint, cream, limeDim, mintDim];

  @override
  bool operator ==(Object other) =>
      other is GamePalette &&
      other.card == card &&
      other.deep == deep &&
      other.lime == lime &&
      other.limeDim == limeDim &&
      other.cream == cream &&
      other.mint == mint &&
      other.mintDim == mintDim &&
      other.inkTeal == inkTeal;

  @override
  int get hashCode =>
      Object.hash(card, deep, lime, limeDim, cream, mint, mintDim, inkTeal);
}

/// The olive card with the app's usual shadow.
BoxDecoration gameCardDecoration(BuildContext context,
        {BorderRadius radius = kGameRadius}) =>
    (ApplicationUtil.getBoxDecorationOne(context) as BoxDecoration)
        .copyWith(borderRadius: radius);

/// Olive card. Tappable when [onTap] is set.
class GamePanel extends StatelessWidget {
  const GamePanel({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // The decoration sits outside the Material: ink is clipped to the
    // Material's rectangle, which would cut the shadow into square corners.
    return DecoratedBox(
      decoration: gameCardDecoration(context),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: kGameRadius,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Dark olive well inside a card, used behind boards and animations.
class GameInset extends StatelessWidget {
  const GameInset({Key? key, required this.child, this.radius = 14})
      : super(key: key);

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(color: GamePalette.of(context).deep, child: child),
    );
  }
}

/// Small light pill: an icon and a short value.
class GameChip extends StatelessWidget {
  const GameChip({
    Key? key,
    required this.icon,
    required this.label,
    this.fontFamily,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: palette.cream,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.ink),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill button. Filled light green for the main action, outlined otherwise.
class GameButton extends StatelessWidget {
  const GameButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
    this.expand = false,
  }) : super(key: key);

  final String label;

  /// Null shows the button dimmed and not tappable.
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  /// Takes the full width, content centred.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    final foreground = filled ? palette.ink : Colors.white;
    final button = Material(
      color: filled ? palette.lime : Colors.transparent,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : BorderSide(
                color: palette.cream.withValues(alpha: 0.7), width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return onPressed == null ? Opacity(opacity: 0.5, child: button) : button;
  }
}

/// Fades and slides a child in, each [index] a little after the one before.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    Key? key,
    required this.animation,
    required this.index,
    required this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.15).clamp(0.0, 0.6);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, start + 0.4, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(curved),
        child: child,
      ),
    );
  }
}

/// Light green round button with an icon, e.g. back.
class GameRoundButton extends StatelessWidget {
  const GameRoundButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 40,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: palette.lime,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: palette.ink, size: size * 0.55),
          ),
        ),
      ),
    );
  }
}

/// Page frame for a game: a top bar (back, title, chips) over the shared
/// background, and [body] below it.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.chips = const [],
    this.onBack,
    this.overlay,
  }) : super(key: key);

  final String title;
  final Widget body;
  final List<Widget> chips;

  /// Drawn over everything, top bar included (for short notices).
  final Widget? overlay;

  /// Defaults to popping the page.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: gameCardDecoration(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          GameRoundButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: MaterialLocalizations.of(context)
                                .backButtonTooltip,
                            onPressed: onBack ??
                                () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          for (final chip in chips) ...[
                            const SizedBox(width: 6),
                            chip,
                          ],
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: body),
                ],
              ),
            ),
            if (overlay != null) Positioned.fill(child: overlay!),
          ],
        ),
      ),
    );
  }
}

class GameDialogAction {
  const GameDialogAction(this.label,
      {this.onPressed, this.icon, this.filled = false});

  final String label;
  final IconData? icon;
  final bool filled;

  /// Runs after the dialog has closed.
  final VoidCallback? onPressed;
}

/// Dialog in the game style: [header] (usually an animation) on top, then
/// the title, message and buttons. Every button closes the dialog first.
Future<void> showGameDialog(
  BuildContext context, {
  required Widget header,
  required String title,
  String? message,
  required List<GameDialogAction> actions,
  bool dismissible = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      final palette = GamePalette.of(dialogContext);
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: DecoratedBox(
            decoration: gameCardDecoration(dialogContext),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 150, child: header),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: palette.cream, fontSize: 15),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        for (final action in actions)
                          GameButton(
                            label: action.label,
                            icon: action.icon,
                            filled: action.filled,
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              action.onPressed?.call();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Square tile with a Tibetan letter, for Spelling Bee.
class LetterTile extends StatelessWidget {
  const LetterTile({
    Key? key,
    required this.letter,
    required this.size,
    this.placed = false,
    this.lifted = false,
  }) : super(key: key);

  final String letter;
  final double size;

  /// Sitting in its slot: light green instead of cream.
  final bool placed;

  /// Being dragged: a deeper shadow.
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: placed ? palette.lime : palette.cream,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.35 : 0.22),
            blurRadius: lifted ? 14 : 5,
            offset: Offset(0, lifted ? 8 : 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.12),
        child: FittedBox(
          child: Text(
            letter,
            style: TextStyle(
              fontFamily: kLetterFont,
              color: palette.ink,
              fontSize: 40,
            ),
          ),
        ),
      ),
    );
  }
}
