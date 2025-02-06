import 'package:equatable/equatable.dart';

// Updated Game model
class Game extends Equatable {
  final String name;
  final String description;
  final String gameIcon;
  final GameType gameType;
  final int requiredScoreInPreviousLevelToUnlock;
  final bool isUnlocked;
  final int currentScore;
  final int level;

  const Game({
    required this.name,
    required this.description,
    required this.gameIcon,
    required this.gameType,
    required this.requiredScoreInPreviousLevelToUnlock,
    required this.level,
    this.isUnlocked = false,
    this.currentScore = 0,
  });

  Game copyWith({
    bool? isUnlocked,
    int? currentScore,
  }) {
    return Game(
      name: this.name,
      description: this.description,
      gameIcon: this.gameIcon,
      gameType: this.gameType,
      requiredScoreInPreviousLevelToUnlock:
          this.requiredScoreInPreviousLevelToUnlock,
      level: this.level,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentScore: currentScore ?? this.currentScore,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        gameIcon,
        gameType,
        requiredScoreInPreviousLevelToUnlock,
        isUnlocked,
        currentScore,
        level,
      ];
}

enum GameType { snakeGame, spellingBeeGame, hangManGame }
