part of 'reward_cubit.dart';

class RewardState extends Equatable {
  final UserProgress progress;
  final List<Achievement> achievements;
  final bool isLoading;
  final String? error;
  final Achievement? newlyUnlockedAchievement;

  const RewardState({
    this.progress = const UserProgress(),
    this.achievements = const [],
    this.isLoading = false,
    this.error,
    this.newlyUnlockedAchievement,
  });

  RewardState copyWith({
    UserProgress? progress,
    List<Achievement>? achievements,
    bool? isLoading,
    String? error,
    Achievement? newlyUnlockedAchievement,
  }) {
    return RewardState(
      progress: progress ?? this.progress,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      newlyUnlockedAchievement: newlyUnlockedAchievement,
    );
  }

  @override
  List<Object?> get props => [
        progress,
        achievements,
        isLoading,
        error,
        newlyUnlockedAchievement,
      ];
}
