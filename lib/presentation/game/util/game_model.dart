import 'package:equatable/equatable.dart';

// Enhanced Game model with stars and coins
class Game extends Equatable {
  final String name;
  final String description;
  final String gameIcon;
  final GameType gameType;
  final int requiredScoreInPreviousLevelToUnlock;
  final bool isUnlocked;
  final int currentScore;
  final int level;
  final int stars; // 0-3 stars earned
  final int coinsEarned; // Total coins earned from this game
  final int requiredStarsToUnlock; // Stars needed to unlock

  const Game({
    required this.name,
    required this.description,
    required this.gameIcon,
    required this.gameType,
    required this.requiredScoreInPreviousLevelToUnlock,
    required this.level,
    this.isUnlocked = false,
    this.currentScore = 0,
    this.stars = 0,
    this.coinsEarned = 0,
    this.requiredStarsToUnlock = 0,
  });

  Game copyWith({
    bool? isUnlocked,
    int? currentScore,
    int? stars,
    int? coinsEarned,
  }) {
    return Game(
      name: name,
      description: description,
      gameIcon: gameIcon,
      gameType: gameType,
      requiredScoreInPreviousLevelToUnlock: requiredScoreInPreviousLevelToUnlock,
      level: level,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentScore: currentScore ?? this.currentScore,
      stars: stars ?? this.stars,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      requiredStarsToUnlock: requiredStarsToUnlock,
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
        stars,
        coinsEarned,
        requiredStarsToUnlock,
      ];
}

enum GameType {
  // Existing games
  spellingBeeGame,
  snakeGame,
  memoryGame,

  // New games
  alphabetMatchGame,
  characterTraceGame,
  soundQuizGame,
  wordBuilderGame,
  speedChallengeGame,
}
