import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/memory_match.dart';

part 'memory_match_event.dart';
part 'memory_match_state.dart';

class MemoryMatchBloc extends Bloc<MemoryMatchEvent, MemoryMatchState> {
  MemoryMatchBloc() : super(MemoryMatchState()) {
    on<InitializeGame>(_onInitializeGame);
    on<FlipCard>(_onFlipCard);
    on<ResetGame>(_onResetGame);
  }

  void _onInitializeGame(InitializeGame event, Emitter<MemoryMatchState> emit) {
    final game = MemoryMatchGame(cards: event.cards);
    emit(state.copyWith(game: game));
  }

  void _onFlipCard(FlipCard event, Emitter<MemoryMatchState> emit) {
    final game = state.game!;
    game.flipCard(event.index);

    // Check if two cards are flipped
    if (game.currentlyFlipped.length == 2) {
      final isMatch = game.checkMatch();
      if (!isMatch) {
        // Reset flipped cards after a delay
        Future.delayed(Duration(seconds: 1), () {
          game.resetFlippedCards();
          emit(state.copyWith(game: game));
        });
      }
    }

    emit(state.copyWith(game: game, isGameComplete: game.isGameComplete()));
  }

  void _onResetGame(ResetGame event, Emitter<MemoryMatchState> emit) {
    final game = state.game!;
    emit(state.copyWith(game: MemoryMatchGame(cards: game.cards)));
  }
}
