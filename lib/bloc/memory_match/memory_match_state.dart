part of 'memory_match_bloc.dart';

class MemoryMatchState {
  final MemoryMatchGame? game;
  final bool isGameComplete;

  /// All cards face up so the player can memorise them; taps do nothing.
  final bool isPreviewing;

  MemoryMatchState({
    this.game,
    this.isGameComplete = false,
    this.isPreviewing = false,
  });

  MemoryMatchState copyWith({
    MemoryMatchGame? game,
    bool? isGameComplete,
    bool? isPreviewing,
  }) {
    return MemoryMatchState(
      game: game ?? this.game,
      isGameComplete: isGameComplete ?? this.isGameComplete,
      isPreviewing: isPreviewing ?? this.isPreviewing,
    );
  }
}
