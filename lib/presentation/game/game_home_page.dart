import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tibetan_language_learning_app/presentation/game/snake_game/snake_game.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/util/game_model.dart';

import '../../game_bloc/game_bloc.dart';
import '../../util/application_util.dart';
import '../../util/constant.dart';
import 'memory_match/memory_match_screen.dart';
import 'widget/game_animations.dart';
import 'widget/game_ui.dart';

class GameHomePage extends StatefulWidget {
  static const routeName = 'game-home';

  const GameHomePage({Key? key}) : super(key: key);

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage>
    with SingleTickerProviderStateMixin {
  // Cards slide in one after another when the page opens.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.games.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: GamePalette.of(context).lime,
              ),
            );
          }
          final games = state.games;
          return SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView.separated(
                  // Bottom room for the back button.
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                  itemCount: games.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => StaggeredEntrance(
                    animation: _entrance,
                    index: i,
                    child: _GameCard(
                      game: games[i],
                      previous: i > 0 ? games[i - 1] : null,
                      onTap: () => games[i].isUnlocked
                          ? _openGame(context, games[i].gameType)
                          : _showLocked(
                              context, games[i], i > 0 ? games[i - 1] : null),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  void _showLocked(BuildContext context, Game game, Game? previous) {
    showGameDialog(
      context,
      dismissible: true,
      header: const LockedAnimation(),
      title: '${game.name} is locked',
      message: _unlockHint(game, previous),
      actions: const [
        GameDialogAction('Got it!', icon: Icons.check_rounded, filled: true),
      ],
    );
  }

  void _openGame(BuildContext context, GameType gameType) {
    switch (gameType) {
      case GameType.spellingBeeGame:
        Navigator.pushNamed(context, SpellingBeePage.routeName);
        break;
      case GameType.snakeGame:
        Navigator.pushNamed(context, SnakeGamePage.routeName);
        break;
      case GameType.memoryGame:
        Navigator.pushNamed(context, MemoryMatchGameScreen.routeName);
        break;
    }
  }
}

/// What the player has to do in the game before this one. Worded the way
/// each game reports its score to GameBloc, not as raw points:
/// Spelling Bee sends 1 after kSpellingBeeWordsToUnlock words, and Snake sends
/// kLevelOneScoreLimit once a single round goes past it.
String _unlockHint(Game game, Game? previous) {
  switch (previous?.gameType) {
    case GameType.spellingBeeGame:
      return 'Spell $kSpellingBeeWordsToUnlock words in one round of '
          '${previous!.name} to unlock it.';
    case GameType.snakeGame:
      return 'Eat ${kLevelOneScoreLimit + 1} letters in one round of '
          '${previous!.name} to unlock it.';
    default:
      final points = game.requiredScoreInPreviousLevelToUnlock;
      final where = previous?.name ?? 'Level ${game.level - 1}';
      return 'Score $points ${points == 1 ? 'point' : 'points'} in $where '
          'to unlock it.';
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.previous,
    required this.onTap,
  });

  final Game game;
  final Game? previous;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    final locked = !game.isUnlocked;
    // Small phones get a smaller picture so the text keeps enough room.
    final compact = MediaQuery.sizeOf(context).width < 360;
    final preview = compact ? 84.0 : 112.0;
    final button = compact ? 38.0 : 44.0;
    return Semantics(
      button: true,
      label: locked ? '${game.name}, locked' : 'Play ${game.name}',
      child: GamePanel(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            SizedBox.square(
              dimension: preview,
              child: GameInset(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: locked ? 0.35 : 1,
                      child: GamePreview(type: game.gameType),
                    ),
                    if (locked)
                      Center(
                        child: Icon(Icons.lock_rounded,
                            color: palette.cream, size: 36),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: compact ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shrinks a long name on narrow phones rather than cutting it.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      game.name,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locked ? _unlockHint(game, previous) : game.description,
                    // The unlock hint is the instruction, so never cut it off.
                    maxLines: locked ? 4 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.cream.withValues(alpha: 0.9),
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      GameChip(
                        icon: Icons.flag_rounded,
                        label: 'Level ${game.level}',
                      ),
                      // The saved score only records that the unlock goal was
                      // met, so show that rather than a number.
                      if (game.currentScore > 0)
                        const GameChip(
                          icon: Icons.check_circle_rounded,
                          label: 'Cleared',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: button,
              height: button,
              decoration: BoxDecoration(
                color: locked ? Colors.transparent : palette.lime,
                shape: BoxShape.circle,
                border: locked
                    ? Border.all(
                        color: palette.cream.withValues(alpha: 0.6), width: 1.5)
                    : null,
              ),
              child: Icon(
                locked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
                color: locked ? palette.cream : palette.ink,
                size: button * 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
