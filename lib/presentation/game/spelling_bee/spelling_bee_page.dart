import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drag.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drop.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/fly_in_animation.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

import '../../../game_bloc/game_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../util/game_model.dart';
import '../widget/game_animations.dart';
import '../widget/game_ui.dart';

class SpellingBeePage extends StatefulWidget {
  static const routeName = 'spelling-bee';
  const SpellingBeePage({Key? key}) : super(key: key);

  @override
  State<SpellingBeePage> createState() => _SpellingBeePageState();
}

class _SpellingBeePageState extends State<SpellingBeePage> {
  List<Verb> _tempList = List.from(AppConstant.verbsList);
  late Verb selectedVerb;
  late Verb shuffledVerb;

  // One key per slot and tile, new for every word. Turning the phone swaps
  // the layout (column/row), and these keys carry each slot and tile across,
  // so letters already placed stay placed.
  List<GlobalKey> _slotKeys = [];
  List<GlobalKey> _tileKeys = [];

  /// Words done when the current word was picked, so each word is picked
  /// once even if the page rebuilds before the provider settles.
  int _generatedFor = -1;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back (button or gesture) asks first: the round would be lost.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Selector<SpellingBeeProvider, bool>(
        selector: (_, controller) => controller.generateWord,
        builder: (_, generate, __) {
          final done = context.read<SpellingBeeProvider>().wordAnswered;
          if (generate && _generatedFor != done && _tempList.isNotEmpty) {
            _generatedFor = done;
            _generateWord();
          }
          return GameScaffold(
            title: AppLocalizations.of(context)!.spellingBeeContest,
            onBack: _confirmExit,
            chips: [
              _WordsDone(
                builder: (done) => GameChip(
                  icon: Icons.emoji_events_rounded,
                  label: _progressLabel(done),
                  fontFamily: kLetterFont,
                ),
              ),
            ],
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                LayoutBuilder(builder: _buildBoard),
                _wordCelebration(),
              ],
            ),
            overlay: _unlockNotice(),
          );
        },
      ),
    );
  }

  void _generateWord() {
    final randomNumber = Random().nextInt(_tempList.length);
    selectedVerb = _tempList[randomNumber];

    if (_tempList[randomNumber].characterList.isNotEmpty) {
      List<String> characterList =
          List.from(_tempList[randomNumber].characterList)..shuffle();

      shuffledVerb = Verb(
          fileName: _tempList[randomNumber].fileName,
          word: _tempList[randomNumber].word,
          characterList: characterList);
    }
    _tempList.removeAt(randomNumber);
    _slotKeys = [for (final _ in selectedVerb.characterList) GlobalKey()];
    _tileKeys = [for (final _ in shuffledVerb.characterList) GlobalKey()];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<SpellingBeeProvider>(context, listen: false)
          .setUp(total: shuffledVerb.characterList.length);
      Provider.of<SpellingBeeProvider>(context, listen: false)
          .requestWord(request: false);
    });
  }

  /// Slots, picture, letters and progress. Side by side when the screen is
  /// wide, stacked otherwise.
  Widget _buildBoard(BuildContext context, BoxConstraints constraints) {
    final landscape = constraints.maxWidth > constraints.maxHeight * 1.2;
    final count = max(selectedVerb.characterList.length, 3);
    final rowWidth =
        landscape ? constraints.maxWidth * 0.55 : constraints.maxWidth;
    final tile = [
      76.0,
      (rowWidth - 32 - (count - 1) * 12) / count,
      constraints.maxHeight * (landscape ? 0.2 : 0.13),
    ].reduce(min);

    final slots = _panel(
      caption: landscape ? null : 'Build the word',
      children: [
        for (var i = 0; i < selectedVerb.characterList.length; i++)
          FlyInAnimation(
            key: _slotKeys[i],
            animate: true,
            child: Drop(
              key: ValueKey('slot-${selectedVerb.word}-$i'),
              letter: selectedVerb.characterList[i],
              size: tile,
            ),
          ),
      ],
    );
    final letters = _panel(
      caption: landscape ? null : 'Drag each letter to its place',
      children: [
        for (var i = 0; i < shuffledVerb.characterList.length; i++)
          FlyInAnimation(
            key: _tileKeys[i],
            animate: true,
            child: Drag(
              key: ValueKey('tile-${shuffledVerb.word}-$i'),
              letter: shuffledVerb.characterList[i],
              size: tile,
            ),
          ),
      ],
    );
    final picture =
        _Picture(path: ApplicationUtil.getImagePath(selectedVerb.fileName));
    final progress = _WordsDone(
      builder: (done) => _ProgressBar(
        value: done / AppConstant.verbsList.length,
        label: _progressLabel(done),
      ),
    );

    if (landscape) {
      return Row(
        children: [
          Expanded(flex: 4, child: picture),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                slots,
                const SizedBox(height: 12),
                letters,
                const SizedBox(height: 12),
                progress,
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        slots,
        const SizedBox(height: 16),
        Expanded(child: picture),
        const SizedBox(height: 16),
        letters,
        const SizedBox(height: 16),
        progress,
      ],
    );
  }

  Widget _panel({String? caption, required List<Widget> children}) {
    return SizedBox(
      width: double.infinity,
      child: GamePanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            if (caption != null) ...[
              Text(
                caption,
                style: TextStyle(
                  color: GamePalette.of(context).cream,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    children[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Honeycomb burst when a word is done and more are coming.
  Widget _wordCelebration() {
    return Selector<SpellingBeeProvider, int>(
      selector: (_, controller) => controller.wordAnswered,
      builder: (_, done, __) {
        final more = done > 0 && done < AppConstant.verbsList.length;
        if (!more) return const SizedBox.shrink();
        // A small box: the burst scales its pieces to the space it gets.
        return Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 320,
              height: 220,
              child: CelebrationBurst(
                key: ValueKey(done),
                type: GameType.spellingBeeGame,
                repeat: false,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Banner once this round unlocks Snake.
  Widget _unlockNotice() {
    return Selector<SpellingBeeProvider, bool>(
      selector: (_, controller) => controller.nextGameUnlocked,
      builder: (context, unlocked, __) {
        if (!unlocked) return const SizedBox.shrink();
        final snake = context
            .read<GameBloc>()
            .state
            .games
            .where((g) => g.gameType == GameType.snakeGame);
        final name = snake.isEmpty ? 'Snake Game' : snake.first.name;
        // Over the top bar, like a notification, so the board stays clear.
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: _UnlockBanner(message: '$name unlocked!'),
          ),
        );
      },
    );
  }

  String _progressLabel(int done) =>
      '${AppConstant.getTibetanNumberByNumber(number: done.toString())}'
      ' / '
      '${AppConstant.getTibetanNumberByNumber(number: AppConstant.verbsList.length.toString())}';

  void _confirmExit() {
    showGameDialog(
      context,
      dismissible: true,
      header:
          const GameCelebration(type: GameType.spellingBeeGame, burst: false),
      title: 'Leave the game?',
      message: 'Your progress in this round will be lost.',
      actions: [
        GameDialogAction(
          'Leave',
          icon: Icons.logout_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const GameDialogAction('Keep playing',
            icon: Icons.play_arrow_rounded, filled: true),
      ],
    );
  }
}

/// Rebuilds [builder] with the number of words spelled so far, without
/// rebuilding the board (which would replay the letters' fly-in).
class _WordsDone extends StatelessWidget {
  const _WordsDone({required this.builder});

  final Widget Function(int done) builder;

  @override
  Widget build(BuildContext context) {
    return Selector<SpellingBeeProvider, int>(
      selector: (_, controller) => controller.wordAnswered,
      builder: (_, done, __) => builder(done),
    );
  }
}

/// Slides in from the top, stays a moment, then fades away. Never blocks
/// the letters underneath.
class _UnlockBanner extends StatefulWidget {
  const _UnlockBanner({required this.message});

  final String message;

  @override
  State<_UnlockBanner> createState() => _UnlockBannerState();
}

class _UnlockBannerState extends State<_UnlockBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final slide = Curves.easeOutBack.transform((t / 0.15).clamp(0, 1));
          final fade = t < 0.85 ? 1.0 : 1 - (t - 0.85) / 0.15;
          return Opacity(
            opacity: fade.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -40 * (1 - slide)),
              child: child,
            ),
          );
        },
        child: Center(
          // Only as tall as the pill, so the parent decides where it sits.
          heightFactor: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: palette.lime,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open_rounded, color: palette.ink, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Picture extends StatelessWidget {
  const _Picture({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: GamePalette.of(context).cream,
            borderRadius: kGameRadius,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(path, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: palette.deep,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.card, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          fit: StackFit.expand,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: value.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: v,
                child: ColoredBox(color: palette.lime),
              ),
            ),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kLetterFont,
                  fontSize: 14,
                  color: value > 0.5 ? palette.ink : palette.cream,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
