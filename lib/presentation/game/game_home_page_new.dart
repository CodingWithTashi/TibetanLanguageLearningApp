import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import '../../game_bloc/game_bloc.dart';
import '../../cubit/reward/reward_cubit.dart';
import '../../cubit/audio_cubit.dart';
import '../../util/application_util.dart';
import '../../service/audio_service.dart';
import '../game/util/game_model.dart';
import 'alphabet_match/alphabet_match_game.dart';
import 'character_trace/character_trace_game.dart';
import 'sound_quiz/sound_quiz_game.dart';
import 'word_builder/word_builder_game.dart';
import 'speed_challenge/speed_challenge_game.dart';
import 'memory_match/memory_match_screen.dart';
import 'snake_game/snake_game.dart';
import 'spelling_bee/spelling_bee_page.dart';

class GameHomePageNew extends StatefulWidget {
  static const routeName = 'game-home';

  const GameHomePageNew({Key? key}) : super(key: key);

  @override
  State<GameHomePageNew> createState() => _GameHomePageNewState();
}

class _GameHomePageNewState extends State<GameHomePageNew> {
  @override
  void initState() {
    super.initState();
    context.read<RewardCubit>().loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: BlocConsumer<GameBloc, GameState>(
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error!)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  return _buildGameGrid(state.games);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
              ),
              const Text(
                'Games',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                onPressed: _showAchievements,
                icon: const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 26),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<RewardCubit, RewardState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBadge('${state.progress.totalCoins}', Icons.monetization_on),
                  _buildStatBadge('${state.progress.totalStars}', Icons.star),
                  _buildStatBadge('${state.progress.currentStreak}', Icons.local_fire_department),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatBadge(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: ApplicationUtil.getBoxDecorationOne(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildGameGrid(List<Game> games) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 2,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(child: _buildGameCard(games[index])),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    final isLocked = !game.isUnlocked;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showUnlockDialog(game);
        } else {
          _navigateToGame(game.gameType);
        }
      },
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Level badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('LV ${game.level}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  if (!isLocked)
                    const Icon(Icons.play_circle_filled, color: Colors.greenAccent, size: 20)
                  else
                    const Icon(Icons.lock, color: Colors.white54, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              // Game icon
              Expanded(
                child: Lottie.network(game.gameIcon, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              // Game name
              Text(
                game.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Stars or lock requirement
              if (!isLocked) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Icon(
                      index < game.stars ? Icons.star : Icons.star_border,
                      color: Colors.amberAccent,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, size: 12, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text('${game.currentScore}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 12, color: Colors.amberAccent),
                        const SizedBox(width: 3),
                        Text('${game.coinsEarned}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amberAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('${game.requiredStarsToUnlock} stars', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showUnlockDialog(Game game) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/json/unlock.json', height: 100, repeat: true),
              const SizedBox(height: 16),
              Text('${game.name} Locked', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Text(
                'Earn ${game.requiredStarsToUnlock} stars in Level ${game.level - 1} to unlock!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: ApplicationUtil.getBoxDecorationOne(context),
                  child: const Text('Got it!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievements() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            const Text('Achievements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<RewardCubit, RewardState>(
                builder: (context, state) {
                  if (state.achievements.isEmpty) {
                    return const Center(child: Text('No achievements yet', style: TextStyle(color: Colors.white70)));
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = state.achievements[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: achievement.isUnlocked
                            ? BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, offset: Offset(-3, -3), blurRadius: 6),
                                  BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
                                ],
                              )
                            : ApplicationUtil.getBoxDecorationOne(context),
                        child: Row(
                          children: [
                            Text(achievement.icon, style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(achievement.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text(achievement.description, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ),
                            if (achievement.isUnlocked)
                              const Icon(Icons.check_circle, color: Colors.white, size: 28)
                            else
                              const Icon(Icons.lock, color: Colors.white54, size: 24),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(GameType gameType) {
    Widget? gameWidget;

    switch (gameType) {
      case GameType.alphabetMatchGame:
        gameWidget = const AlphabetMatchGame();
        break;
      case GameType.characterTraceGame:
        gameWidget = const CharacterTraceGame();
        break;
      case GameType.soundQuizGame:
        gameWidget = const SoundQuizGame();
        break;
      case GameType.wordBuilderGame:
        gameWidget = const WordBuilderGame();
        break;
      case GameType.speedChallengeGame:
        gameWidget = const SpeedChallengeGame();
        break;
      case GameType.memoryGame:
        Navigator.pushNamed(context, MemoryMatchGameScreen.routeName);
        return;
      case GameType.snakeGame:
        Navigator.pushNamed(context, SnakeGamePage.routeName);
        return;
      case GameType.spellingBeeGame:
        Navigator.pushNamed(context, SpellingBeePage.routeName);
        return;
    }

    if (gameWidget != null) {
      // Provide AudioCubit to all new games
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider<AudioCubit>(
            create: (context) => AudioCubit(AudioService(), audioPlayer: AudioPlayer()),
            child: gameWidget!,
          ),
        ),
      );
    }
  }
}
