part of 'snake_game_bloc.dart';

class SnakeGameState extends Equatable {
  final List<int> snakePosition;
  final int food;
  final String direction;
  final bool isPlaying;
  final bool isGameOver;
  final int score;
  final String currentLetter;
  final int speed; // Added speed property

  const SnakeGameState({
    required this.snakePosition,
    required this.food,
    required this.direction,
    required this.isPlaying,
    required this.isGameOver,
    required this.score,
    required this.currentLetter,
    required this.speed, // Added speed parameter
  });

  factory SnakeGameState.initial() => SnakeGameState(
        snakePosition: [42, 62, 82, 102],
        food: 0,
        direction: 'down',
        isPlaying: false,
        isGameOver: false,
        score: 0,
        currentLetter: 'ཀ',
        speed: 300, // Initial speed
      );

  SnakeGameState copyWith({
    List<int>? snakePosition,
    int? food,
    String? direction,
    bool? isPlaying,
    bool? isGameOver,
    int? score,
    String? currentLetter,
    int? speed, // Added speed parameter
  }) {
    return SnakeGameState(
      snakePosition: snakePosition ?? this.snakePosition,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      isPlaying: isPlaying ?? this.isPlaying,
      isGameOver: isGameOver ?? this.isGameOver,
      score: score ?? this.score,
      currentLetter: currentLetter ?? this.currentLetter,
      speed: speed ?? this.speed, // Added speed
    );
  }

  @override
  List<Object?> get props => [
        snakePosition,
        food,
        direction,
        isPlaying,
        isGameOver,
        score,
        currentLetter,
        speed, // Added speed
      ];
}
