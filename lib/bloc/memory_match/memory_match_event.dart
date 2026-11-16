part of 'memory_match_bloc.dart';

abstract class MemoryMatchEvent {}

class InitializeGame extends MemoryMatchEvent {
  final List<String> cards;

  InitializeGame({required this.cards});
}

class FlipCard extends MemoryMatchEvent {
  final int index;

  FlipCard({required this.index});
}

/// Turns a non-matching pair face down again.
class HideUnmatched extends MemoryMatchEvent {}

/// Turns all cards face down after the opening look. Carries its game so a
/// late one from a game already replaced does nothing.
class EndPreview extends MemoryMatchEvent {
  final MemoryMatchGame game;

  EndPreview(this.game);
}

class ResetGame extends MemoryMatchEvent {}
