import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/game/util/game_model.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const String _scorePrefix = 'game_score_';
  static const String _unlockPrefix = 'game_unlock_';

  GameBloc() : super(GameState(games: [])) {
    on<LoadGames>(_onLoadGames);
    on<UpdateGameScore>(_onUpdateGameScore);
    on<CheckGameUnlock>(_onCheckGameUnlock);
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

      // Load saved scores and unlock status
      for (var i = 0; i < games.length; i++) {
        var game = games[i];
        final score =
            _prefs.getInt(_scorePrefix + game.gameType.toString()) ?? 0;
        final isUnlocked =
            _prefs.getBool(_unlockPrefix + game.gameType.toString()) ??
                (i == 0);

        games[i] = game.copyWith(
          isUnlocked: isUnlocked,
          currentScore: score,
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

  Future<void> _onCheckGameUnlock(
      CheckGameUnlock event, Emitter<GameState> emit) async {
    try {
      final _prefs = await SharedPreferences.getInstance();

      final updatedGames = List<Game>.from(state.games);
      bool hasChanges = false;

      // Check each game's unlock conditions
      for (int i = 1; i < updatedGames.length; i++) {
        final game = updatedGames[i];
        final previousGame = updatedGames[i - 1];

        if (!game.isUnlocked &&
            previousGame.currentScore >=
                game.requiredScoreInPreviousLevelToUnlock) {
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
      Game(
        name: 'Spelling Bee',
        description: 'Master Tibetan spelling with this exciting game!',
        gameIcon: 'https://assets6.lottiefiles.com/packages/lf20_yU09RI.json',
        gameType: GameType.spellingBeeGame,
        requiredScoreInPreviousLevelToUnlock: 0,
        level: 1,
        currentScore: 0,
      ),
      Game(
        name: 'Snake Game',
        description: 'Collect Tibetan letters while growing your snake!',
        gameIcon: 'https://assets6.lottiefiles.com/packages/lf20_qoo3cyxi.json',
        gameType: GameType.snakeGame,
        requiredScoreInPreviousLevelToUnlock: 1,
        level: 2,
        currentScore: 0,
      ),
      Game(
        name: 'Hang Man Game',
        description: 'Collect Tibetan letters while growing your snake!',
        gameIcon: 'https://assets6.lottiefiles.com/packages/lf20_qoo3cyxi.json',
        gameType: GameType.hangManGame,
        requiredScoreInPreviousLevelToUnlock: 10,
        level: 3,
        currentScore: 0,
      ),
    ];
  }
}
