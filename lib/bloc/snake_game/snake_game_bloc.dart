import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/constant.dart';

part 'snake_game_event.dart';
part 'snake_game_state.dart';

class SnakeGameBloc extends Bloc<SnakeGameEvent, SnakeGameState> {
  Timer? _gameTimer;
  static const int gridSize = 760;
  static const int initialSpeed = 300; // Initial speed in milliseconds
  static const int minSpeed = 50; // Minimum speed (maximum difficulty)
  static const int speedDecrement = 5; // How much to decrease speed per score
  final Random _random = Random();
  List<String> _alphabet =
      AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET)
          .map((e) => e.alphabetName)
          .toList();

  SnakeGameBloc() : super(SnakeGameState.initial()) {
    on<StartGame>(_onStartGame);
    on<UpdateSnake>(_onUpdateSnake);
    on<ChangeDirection>(_onChangeDirection);
    on<GenerateFood>(_onGenerateFood);
    on<EndGame>(_onEndGame);
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: state.speed),
      (timer) {
        if (!state.isGameOver) {
          add(UpdateSnake());
        } else {
          timer.cancel();
        }
      },
    );
  }

  void _onStartGame(StartGame event, Emitter<SnakeGameState> emit) {
    _gameTimer?.cancel();
    final initialState = SnakeGameState.initial();
    emit(initialState.copyWith(
      isPlaying: true,
      food: _random.nextInt(700),
      currentLetter: _alphabet[_random.nextInt(_alphabet.length)],
    ));

    _startGameTimer();
  }

  void _onUpdateSnake(UpdateSnake event, Emitter<SnakeGameState> emit) {
    final List<int> newPosition = List.from(state.snakePosition);
    int newHead;

    switch (state.direction) {
      case 'down':
        newHead = state.snakePosition.last > 740
            ? state.snakePosition.last + 20 - 760
            : state.snakePosition.last + 20;
        break;
      case 'up':
        newHead = state.snakePosition.last < 20
            ? state.snakePosition.last - 20 + 760
            : state.snakePosition.last - 20;
        break;
      case 'left':
        newHead = state.snakePosition.last % 20 == 0
            ? state.snakePosition.last - 1 + 20
            : state.snakePosition.last - 1;
        break;
      case 'right':
        newHead = (state.snakePosition.last + 1) % 20 == 0
            ? state.snakePosition.last + 1 - 20
            : state.snakePosition.last + 1;
        break;
      default:
        return;
    }

    newPosition.add(newHead);

    if (newHead == state.food) {
      add(GenerateFood());

      // Calculate new speed based on score
      final newScore = state.score + 1;
      final newSpeed = _calculateSpeed(newScore);

      emit(state.copyWith(
        snakePosition: newPosition,
        score: newScore,
        speed: newSpeed,
      ));

      // Restart timer with new speed
      _startGameTimer();
    } else {
      newPosition.removeAt(0);
      emit(state.copyWith(snakePosition: newPosition));
    }

    if (_checkCollision(newPosition)) {
      add(EndGame());
    }
  }

  int _calculateSpeed(int score) {
    // Calculate new speed based on score
    // Speed decreases (gets faster) as score increases
    int calculatedSpeed = initialSpeed - (score ~/ 1 * speedDecrement);
    // Ensure speed doesn't go below minimum
    return calculatedSpeed.clamp(minSpeed, initialSpeed);
  }

  void _onChangeDirection(ChangeDirection event, Emitter<SnakeGameState> emit) {
    emit(state.copyWith(direction: event.direction));
  }

  void _onGenerateFood(GenerateFood event, Emitter<SnakeGameState> emit) {
    final newFood = _random.nextInt(700);
    final newLetter = _alphabet[_random.nextInt(_alphabet.length)];
    emit(state.copyWith(
      food: newFood,
      currentLetter: newLetter,
    ));
  }

  void _onEndGame(EndGame event, Emitter<SnakeGameState> emit) {
    _gameTimer?.cancel();
    emit(state.copyWith(
      isGameOver: true,
      isPlaying: false,
    ));
  }

  bool _checkCollision(List<int> positions) {
    final snakeSet = Set<int>();
    for (final position in positions) {
      if (!snakeSet.add(position)) return true;
    }
    return false;
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    return super.close();
  }
}
