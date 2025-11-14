part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGames extends GameEvent {}

class UpdateGameScore extends GameEvent {
  final GameType gameType;
  final int score;

  UpdateGameScore({required this.gameType, required this.score});

  @override
  List<Object?> get props => [gameType, score];
}

class UpdateGameStars extends GameEvent {
  final GameType gameType;
  final int stars;
  final int coinsEarned;

  UpdateGameStars({
    required this.gameType,
    required this.stars,
    required this.coinsEarned,
  });

  @override
  List<Object?> get props => [gameType, stars, coinsEarned];
}

class CheckGameUnlock extends GameEvent {}
