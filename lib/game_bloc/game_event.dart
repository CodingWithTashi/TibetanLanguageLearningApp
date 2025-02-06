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

class CheckGameUnlock extends GameEvent {}
