import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/game/util/game_model.dart';
import '../util/constant.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const String _scorePrefix = 'game_score_';
  static const String _unlockPrefix = 'game_unlock_';
  static const String _starsPrefix = 'game_stars_';
  static const String _coinsPrefix = 'game_coins_';

  GameBloc() : super(GameState(games: [])) {
    on<LoadGames>(_onLoadGames);
    on<UpdateGameScore>(_onUpdateGameScore);
    on<CheckGameUnlock>(_onCheckGameUnlock);
    on<UpdateGameStars>(_onUpdateGameStars);
  }

  Future<void> _onLoadGames(LoadGames event, Emitter<GameState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final _prefs = await SharedPreferences.getInstance();
      final games = _getInitialGames();

      // Set first game as unlocked if not set before
      if (!_prefs.containsKey(_unlockPrefix + games[0].gameType.toString())) {
        await _prefs.setBool(
            _unlockPrefix + games[0].gameType.toString(), true);
      }

      // Load saved scores, stars, coins and unlock status
      for (var i = 0; i < games.length; i++) {
        var game = games[i];
        final score =
            _prefs.getInt(_scorePrefix + game.gameType.toString()) ?? 0;
        final stars =
            _prefs.getInt(_starsPrefix + game.gameType.toString()) ?? 0;
        final coins =
            _prefs.getInt(_coinsPrefix + game.gameType.toString()) ?? 0;
        final isUnlocked =
            _prefs.getBool(_unlockPrefix + game.gameType.toString()) ??
                (i == 0);

        games[i] = game.copyWith(
          isUnlocked: isUnlocked,
          currentScore: score,
          stars: stars,
          coinsEarned: coins,
        );
      }
      emit(state.copyWith(games: games, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onUpdateGameScore(
      UpdateGameScore event, Emitter<GameState> emit) async {
    try {
      final _prefs = await SharedPreferences.getInstance();

      // Save new score only if it's higher than the current score
      final currentScore =
          _prefs.getInt(_scorePrefix + event.gameType.toString()) ?? 0;
      if (event.score > currentScore) {
        await _prefs.setInt(
            _scorePrefix + event.gameType.toString(), event.score);

        // Update game list with new score
        final updatedGames = state.games.map((game) {
          if (game.gameType == event.gameType) {
            return game.copyWith(currentScore: event.score);
          }
          return game;
        }).toList();

        emit(state.copyWith(games: updatedGames));
      }
      add(CheckGameUnlock());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateGameStars(
      UpdateGameStars event, Emitter<GameState> emit) async {
    try {
      final _prefs = await SharedPreferences.getInstance();

      // Save stars and coins
      await _prefs.setInt(
          _starsPrefix + event.gameType.toString(), event.stars);
      await _prefs.setInt(
          _coinsPrefix + event.gameType.toString(), event.coinsEarned);

      // Update game list with new stars and coins
      final updatedGames = state.games.map((game) {
        if (game.gameType == event.gameType) {
          return game.copyWith(
            stars: event.stars,
            coinsEarned: event.coinsEarned,
          );
        }
        return game;
      }).toList();

      emit(state.copyWith(games: updatedGames));
      add(CheckGameUnlock());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCheckGameUnlock(
      CheckGameUnlock event, Emitter<GameState> emit) async {
    try {
      final _prefs = await SharedPreferences.getInstance();

      final updatedGames = List<Game>.from(state.games);
      bool hasChanges = false;

      // Check each game's unlock conditions based on stars
      for (int i = 1; i < updatedGames.length; i++) {
        final game = updatedGames[i];
        final previousGame = updatedGames[i - 1];

        // Unlock if previous game has required stars
        if (!game.isUnlocked &&
            previousGame.stars >= game.requiredStarsToUnlock) {
          updatedGames[i] = game.copyWith(isUnlocked: true);
          await _prefs.setBool(_unlockPrefix + game.gameType.toString(), true);
          hasChanges = true;
        }
      }

      if (hasChanges) {
        emit(state.copyWith(games: updatedGames));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  List<Game> _getInitialGames() {
    return [
      // Level 1 - Always unlocked
      const Game(
        name: 'Alphabet Match',
        description: 'Match Tibetan characters with their sounds!',
        gameIcon: 'https://assets9.lottiefiles.com/packages/lf20_khzniaya.json',
        gameType: GameType.alphabetMatchGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 0,
        level: 1,
      ),

      // Level 2 - Requires 1 star from Level 1
      const Game(
        name: 'Character Trace',
        description: 'Learn to write Tibetan characters by tracing!',
        gameIcon: 'https://assets2.lottiefiles.com/packages/lf20_x1gjdldd.json',
        gameType: GameType.characterTraceGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 1,
        level: 2,
      ),

      // Level 3 - Requires 1 star from Level 2
      const Game(
        name: 'Sound Quiz',
        description: 'Listen and identify the correct Tibetan character!',
        gameIcon: 'https://lottie.host/8c7e8f3a-7b42-4a57-9f5e-95d7f0c7e8b4/dFqHkLxz5C.json',
        gameType: GameType.soundQuizGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 1,
        level: 3,
      ),

      // Level 4 - Requires 2 stars from Level 3
      const Game(
        name: 'Word Builder',
        description: 'Build Tibetan words from characters!',
        gameIcon: 'https://assets6.lottiefiles.com/packages/lf20_yU09RI.json',
        gameType: GameType.wordBuilderGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 2,
        level: 4,
      ),

      // Level 5 - Requires 2 stars from Level 4
      const Game(
        name: 'Memory Match',
        description: 'Match pairs of Tibetan characters!',
        gameIcon: 'https://lottie.host/e878b150-a736-48c1-a865-35b03bc19920/7zmeLDaVtf.json',
        gameType: GameType.memoryGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 2,
        level: 5,
      ),

      // Level 6 - Requires 2 stars from Level 5
      const Game(
        name: 'Speed Challenge',
        description: 'Race against time to identify characters!',
        gameIcon: 'https://lottie.host/1c4a2f3d-6e5b-4c8a-9f7e-3d5e6f7a8b9c/xYzAbC123d.json',
        gameType: GameType.speedChallengeGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 2,
        level: 6,
      ),

      // Level 7 - Requires 3 stars from Level 6
      const Game(
        name: 'Snake Game',
        description: 'Collect Tibetan letters while growing your snake!',
        gameIcon: 'https://assets6.lottiefiles.com/packages/lf20_qoo3cyxi.json',
        gameType: GameType.snakeGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 3,
        level: 7,
      ),

      // Level 8 - Requires 3 stars from Level 7
      const Game(
        name: 'Spelling Bee',
        description: 'Master Tibetan spelling with this challenging game!',
        gameIcon: 'https://assets1.lottiefiles.com/packages/lf20_touohxv0.json',
        gameType: GameType.spellingBeeGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        requiredStarsToUnlock: 3,
        level: 8,
      ),
    ];
  }
}
