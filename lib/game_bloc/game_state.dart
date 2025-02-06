part of 'game_bloc.dart';

class GameState extends Equatable {
  final List<Game> games;
  final bool isLoading;
  final String? error;

  const GameState({
    required this.games,
    this.isLoading = false,
    this.error,
  });

  GameState copyWith({
    List<Game>? games,
    bool? isLoading,
    String? error,
  }) {
    return GameState(
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [games, isLoading, error];
}
