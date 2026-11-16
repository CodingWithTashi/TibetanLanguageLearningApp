import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/memory_match.dart';

part 'memory_match_event.dart';
part 'memory_match_state.dart';

/// Every game opens with all cards face up for [previewDuration], then
/// they turn over and the player finds the pairs.
class MemoryMatchBloc extends Bloc<MemoryMatchEvent, MemoryMatchState> {
  static const defaultPreview = Duration(seconds: 3);

  MemoryMatchBloc({this.previewDuration = defaultPreview})
      : super(MemoryMatchState()) {
    on<InitializeGame>(_onInitializeGame);
    on<EndPreview>(_onEndPreview);
    on<FlipCard>(_onFlipCard);
    on<HideUnmatched>(_onHideUnmatched);
    on<ResetGame>(_onResetGame);
  }

  final Duration previewDuration;

  // Cancelled on close, so nothing fires after the screen is gone.
  Timer? _previewTimer;
  Timer? _hideTimer;

  @override
  Future<void> close() {
    _previewTimer?.cancel();
    _hideTimer?.cancel();
    return super.close();
  }

  void _onInitializeGame(InitializeGame event, Emitter<MemoryMatchState> emit) {
    _start(event.cards, emit);
  }

  void _onResetGame(ResetGame event, Emitter<MemoryMatchState> emit) {
    final game = state.game;
    if (game != null) _start(game.cards, emit);
  }

  void _start(List<String> cards, Emitter<MemoryMatchState> emit) {
    // A fresh state, so a finished game doesn't stay finished on replay.
    final game = MemoryMatchGame(cards: cards);
    emit(MemoryMatchState(game: game, isPreviewing: true));
    // Through an event: this handler has returned by then and may no
    // longer emit.
    _hideTimer?.cancel();
    _previewTimer?.cancel();
    _previewTimer = Timer(previewDuration, () => add(EndPreview(game)));
  }

  void _onEndPreview(EndPreview event, Emitter<MemoryMatchState> emit) {
    if (!identical(state.game, event.game) || !state.isPreviewing) return;
    emit(state.copyWith(isPreviewing: false));
  }

  void _onFlipCard(FlipCard event, Emitter<MemoryMatchState> emit) {
    final game = state.game;
    if (game == null || state.isPreviewing) return;
    game.flipCard(event.index);

    // Check if two cards are flipped
    if (game.currentlyFlipped.length == 2) {
      final isMatch = game.checkMatch();
      if (!isMatch) {
        // Turn the pair back after a moment, again through an event.
        _hideTimer =
            Timer(const Duration(seconds: 1), () => add(HideUnmatched()));
      }
    }

    emit(state.copyWith(game: game, isGameComplete: game.isGameComplete()));
  }

  void _onHideUnmatched(HideUnmatched event, Emitter<MemoryMatchState> emit) {
    final game = state.game;
    if (game == null) return;
    game.resetFlippedCards();
    emit(state.copyWith(game: game));
  }
}
