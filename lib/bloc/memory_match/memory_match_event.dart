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

class ResetGame extends MemoryMatchEvent {}
