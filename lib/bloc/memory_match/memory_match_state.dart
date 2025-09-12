part of 'memory_match_bloc.dart';

class MemoryMatchState {
  final MemoryMatchGame? game;
  final bool isGameComplete;

  MemoryMatchState({
    this.game,
    this.isGameComplete = false,
  });

  MemoryMatchState copyWith({
    MemoryMatchGame? game,
    bool? isGameComplete,
  }) {
    return MemoryMatchState(
      game: game ?? this.game,
      isGameComplete: isGameComplete ?? this.isGameComplete,
    );
  }
}
