import 'package:equatable/equatable.dart';

/// Achievement model for gamification
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int coinsReward;
  final bool isUnlocked;
  final AchievementType type;
  final int targetValue; // e.g., play 10 games, earn 100 stars

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.coinsReward,
    required this.type,
    required this.targetValue,
    this.isUnlocked = false,
  });

  Achievement copyWith({
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      coinsReward: coinsReward,
      type: type,
      targetValue: targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        coinsReward,
        isUnlocked,
        type,
        targetValue,
      ];
}

enum AchievementType {
  gamesPlayed,
  starsEarned,
  coinsEarned,
  perfectGame, // All 3 stars
  streakDays,
  allGamesUnlocked,
}

/// Game result after completing a game
class GameResult extends Equatable {
  final int score;
  final int stars; // 0-3 stars
  final int coinsEarned;
  final bool isNewHighScore;
  final bool isNewStarRecord;

  const GameResult({
    required this.score,
    required this.stars,
    required this.coinsEarned,
    this.isNewHighScore = false,
    this.isNewStarRecord = false,
  });

  @override
  List<Object?> get props => [
        score,
        stars,
        coinsEarned,
        isNewHighScore,
        isNewStarRecord,
      ];
}

/// User statistics and progress
class UserProgress extends Equatable {
  final int totalCoins;
  final int totalStars;
  final int gamesPlayed;
  final int currentStreak; // Days in a row
  final DateTime? lastPlayedDate;
  final List<String> unlockedAchievements;

  const UserProgress({
    this.totalCoins = 0,
    this.totalStars = 0,
    this.gamesPlayed = 0,
    this.currentStreak = 0,
    this.lastPlayedDate,
    this.unlockedAchievements = const [],
  });

  UserProgress copyWith({
    int? totalCoins,
    int? totalStars,
    int? gamesPlayed,
    int? currentStreak,
    DateTime? lastPlayedDate,
    List<String>? unlockedAchievements,
  }) {
    return UserProgress(
      totalCoins: totalCoins ?? this.totalCoins,
      totalStars: totalStars ?? this.totalStars,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
        totalCoins,
        totalStars,
        gamesPlayed,
        currentStreak,
        lastPlayedDate,
        unlockedAchievements,
      ];
}
