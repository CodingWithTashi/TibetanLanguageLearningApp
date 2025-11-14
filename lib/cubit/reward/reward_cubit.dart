import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/reward_model.dart';

part 'reward_state.dart';

class RewardCubit extends Cubit<RewardState> {
  static const String _coinsKey = 'total_coins';
  static const String _starsKey = 'total_stars';
  static const String _gamesPlayedKey = 'games_played';
  static const String _streakKey = 'current_streak';
  static const String _lastPlayedKey = 'last_played_date';
  static const String _achievementsKey = 'unlocked_achievements';

  RewardCubit() : super(const RewardState());

  /// Load user progress from storage
  Future<void> loadProgress() async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();

      final totalCoins = prefs.getInt(_coinsKey) ?? 0;
      final totalStars = prefs.getInt(_starsKey) ?? 0;
      final gamesPlayed = prefs.getInt(_gamesPlayedKey) ?? 0;
      final currentStreak = prefs.getInt(_streakKey) ?? 0;
      final lastPlayedString = prefs.getString(_lastPlayedKey);
      final unlockedAchievements =
          prefs.getStringList(_achievementsKey) ?? [];

      DateTime? lastPlayedDate;
      if (lastPlayedString != null) {
        lastPlayedDate = DateTime.tryParse(lastPlayedString);
      }

      // Check and update streak
      final updatedStreak = _calculateStreak(currentStreak, lastPlayedDate);

      final progress = UserProgress(
        totalCoins: totalCoins,
        totalStars: totalStars,
        gamesPlayed: gamesPlayed,
        currentStreak: updatedStreak,
        lastPlayedDate: lastPlayedDate,
        unlockedAchievements: unlockedAchievements,
      );

      final achievements = _initializeAchievements(progress);

      emit(state.copyWith(
        progress: progress,
        achievements: achievements,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load progress: $e',
      ));
    }
  }

  /// Award coins to the user
  Future<void> awardCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newTotal = state.progress.totalCoins + coins;
      await prefs.setInt(_coinsKey, newTotal);

      emit(state.copyWith(
        progress: state.progress.copyWith(totalCoins: newTotal),
      ));

      await _checkAchievements();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to award coins: $e'));
    }
  }

  /// Add stars to user progress
  Future<void> addStars(int stars) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newTotal = state.progress.totalStars + stars;
      await prefs.setInt(_starsKey, newTotal);

      emit(state.copyWith(
        progress: state.progress.copyWith(totalStars: newTotal),
      ));

      await _checkAchievements();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add stars: $e'));
    }
  }

  /// Record a game completion
  Future<void> recordGamePlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final newCount = state.progress.gamesPlayed + 1;

      // Update streak
      final updatedStreak =
          _calculateStreak(state.progress.currentStreak, state.progress.lastPlayedDate);
      final newStreak = updatedStreak + (state.progress.lastPlayedDate == null ||
              !_isSameDay(state.progress.lastPlayedDate!, now)
          ? 1
          : 0);

      await prefs.setInt(_gamesPlayedKey, newCount);
      await prefs.setInt(_streakKey, newStreak);
      await prefs.setString(_lastPlayedKey, now.toIso8601String());

      emit(state.copyWith(
        progress: state.progress.copyWith(
          gamesPlayed: newCount,
          currentStreak: newStreak,
          lastPlayedDate: now,
        ),
      ));

      await _checkAchievements();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to record game: $e'));
    }
  }

  /// Process game result and award rewards
  Future<GameResult> processGameResult({
    required int score,
    required int stars,
    required int baseCoins,
  }) async {
    final coinsEarned = baseCoins + (stars * 10); // Bonus coins per star

    await awardCoins(coinsEarned);
    await addStars(stars);
    await recordGamePlayed();

    return GameResult(
      score: score,
      stars: stars,
      coinsEarned: coinsEarned,
      isNewHighScore: false,
      isNewStarRecord: false,
    );
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String achievementId) async {
    try {
      if (state.progress.unlockedAchievements.contains(achievementId)) {
        return; // Already unlocked
      }

      final prefs = await SharedPreferences.getInstance();
      final updatedList = [
        ...state.progress.unlockedAchievements,
        achievementId,
      ];
      await prefs.setStringList(_achievementsKey, updatedList);

      // Find achievement and award coins
      final achievement = state.achievements.firstWhere(
        (a) => a.id == achievementId,
        orElse: () => const Achievement(
          id: '',
          title: '',
          description: '',
          icon: '',
          coinsReward: 0,
          type: AchievementType.gamesPlayed,
          targetValue: 0,
        ),
      );

      if (achievement.id.isNotEmpty) {
        await awardCoins(achievement.coinsReward);
      }

      emit(state.copyWith(
        progress: state.progress.copyWith(unlockedAchievements: updatedList),
        newlyUnlockedAchievement: achievement,
      ));

      // Clear notification after a delay
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(newlyUnlockedAchievement: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to unlock achievement: $e'));
    }
  }

  /// Check if any achievements should be unlocked
  Future<void> _checkAchievements() async {
    for (final achievement in state.achievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.gamesPlayed:
          shouldUnlock =
              state.progress.gamesPlayed >= achievement.targetValue;
          break;
        case AchievementType.starsEarned:
          shouldUnlock = state.progress.totalStars >= achievement.targetValue;
          break;
        case AchievementType.coinsEarned:
          shouldUnlock = state.progress.totalCoins >= achievement.targetValue;
          break;
        case AchievementType.streakDays:
          shouldUnlock =
              state.progress.currentStreak >= achievement.targetValue;
          break;
        default:
          break;
      }

      if (shouldUnlock) {
        await unlockAchievement(achievement.id);
      }
    }
  }

  /// Calculate streak based on last played date
  int _calculateStreak(int currentStreak, DateTime? lastPlayed) {
    if (lastPlayed == null) return 0;

    final now = DateTime.now();
    final difference = now.difference(lastPlayed).inDays;

    if (difference == 0) {
      // Same day
      return currentStreak;
    } else if (difference == 1) {
      // Consecutive day
      return currentStreak;
    } else {
      // Streak broken
      return 0;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Initialize achievements list
  List<Achievement> _initializeAchievements(UserProgress progress) {
    final allAchievements = [
      const Achievement(
        id: 'first_game',
        title: 'First Steps',
        description: 'Play your first game',
        icon: '🎮',
        coinsReward: 50,
        type: AchievementType.gamesPlayed,
        targetValue: 1,
      ),
      const Achievement(
        id: 'ten_games',
        title: 'Getting Started',
        description: 'Play 10 games',
        icon: '🎯',
        coinsReward: 100,
        type: AchievementType.gamesPlayed,
        targetValue: 10,
      ),
      const Achievement(
        id: 'fifty_games',
        title: 'Dedicated Learner',
        description: 'Play 50 games',
        icon: '🏆',
        coinsReward: 250,
        type: AchievementType.gamesPlayed,
        targetValue: 50,
      ),
      const Achievement(
        id: 'ten_stars',
        title: 'Rising Star',
        description: 'Earn 10 stars',
        icon: '⭐',
        coinsReward: 100,
        type: AchievementType.starsEarned,
        targetValue: 10,
      ),
      const Achievement(
        id: 'fifty_stars',
        title: 'Star Collector',
        description: 'Earn 50 stars',
        icon: '🌟',
        coinsReward: 300,
        type: AchievementType.starsEarned,
        targetValue: 50,
      ),
      const Achievement(
        id: 'hundred_coins',
        title: 'Coin Collector',
        description: 'Earn 100 coins',
        icon: '🪙',
        coinsReward: 50,
        type: AchievementType.coinsEarned,
        targetValue: 100,
      ),
      const Achievement(
        id: 'five_hundred_coins',
        title: 'Wealthy Learner',
        description: 'Earn 500 coins',
        icon: '💰',
        coinsReward: 200,
        type: AchievementType.coinsEarned,
        targetValue: 500,
      ),
      const Achievement(
        id: 'three_day_streak',
        title: 'Consistency',
        description: 'Play for 3 days in a row',
        icon: '🔥',
        coinsReward: 150,
        type: AchievementType.streakDays,
        targetValue: 3,
      ),
      const Achievement(
        id: 'seven_day_streak',
        title: 'Dedicated',
        description: 'Play for 7 days in a row',
        icon: '🔥',
        coinsReward: 350,
        type: AchievementType.streakDays,
        targetValue: 7,
      ),
    ];

    // Mark achievements as unlocked based on progress
    return allAchievements.map((achievement) {
      final isUnlocked =
          progress.unlockedAchievements.contains(achievement.id);
      return achievement.copyWith(isUnlocked: isUnlocked);
    }).toList();
  }
}
