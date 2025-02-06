part of 'snake_game_bloc.dart';

// bloc/snake_game_event.dart
abstract class SnakeGameEvent {}

class StartGame extends SnakeGameEvent {}

class UpdateSnake extends SnakeGameEvent {}

class ChangeDirection extends SnakeGameEvent {
  final String direction;
  ChangeDirection(this.direction);
}

class GenerateFood extends SnakeGameEvent {}

class EndGame extends SnakeGameEvent {}
