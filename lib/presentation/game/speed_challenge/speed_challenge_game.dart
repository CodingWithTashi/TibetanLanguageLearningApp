import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:just_audio/just_audio.dart';
import '../../../game_bloc/game_bloc.dart';
import '../../../cubit/audio_cubit.dart';
import '../../../model/alphabet.dart';
import '../../../util/constant.dart';
import '../../../util/application_util.dart';
import '../util/game_model.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/game_score_card.dart';
import '../widgets/game_layout.dart';

class SpeedChallengeGame extends StatefulWidget {
  const SpeedChallengeGame({Key? key}) : super(key: key);

  @override
  State<SpeedChallengeGame> createState() => _SpeedChallengeGameState();
}

class _SpeedChallengeGameState extends State<SpeedChallengeGame>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _timerController;
  late AnimationController _correctAnimController;

  List<Alphabet> allAlphabets = [];
  Alphabet? currentQuestion;
  List<Alphabet> options = [];

  int timeLimit = 60; // 60 seconds
  int timeRemaining = 60;
  Timer? gameTimer;

  int score = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int streak = 0;
  int maxStreak = 0;
  bool isGameActive = false;
  int? selectedOption;
  bool isAudioPlaying = false;
  bool canAnswer = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: timeLimit),
    );
    _correctAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _initializeGame();

    // Show start dialog after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (allAlphabets.length < 4) {
        _showErrorDialog('Not enough content available. Need at least 4 alphabets to play.');
      } else {
        _showStartDialog();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timerController.dispose();
    _correctAnimController.dispose();
    gameTimer?.cancel();

    // Stop audio when leaving the screen
    try {
      context.read<AudioCubit>().pauseAudio();
    } catch (e) {
      print('Could not stop audio on dispose: $e');
    }

    super.dispose();
  }

  void _initializeGame() {
    allAlphabets = AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET)
        .toList();
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Speed Challenge!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Answer as many questions as you can in $timeLimit seconds!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                '🎧 Audio plays at 2x speed for faster gameplay!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.greenAccent),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _startGame();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: ApplicationUtil.getBoxDecorationOne(context),
                  child: const Text(
                    'START',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Error',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GO BACK',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    setState(() {
      isGameActive = true;
      timeRemaining = timeLimit;
      score = 0;
      correctAnswers = 0;
      wrongAnswers = 0;
      streak = 0;
      maxStreak = 0;
    });

    _timerController.forward();
    _loadNextQuestion();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
      });

      if (timeRemaining <= 0) {
        timer.cancel();
        _gameOver();
      }
    });
  }

  void _loadNextQuestion() {
    if (!mounted || !isGameActive) return;

    final random = Random();
    final shuffled = List<Alphabet>.from(allAlphabets)..shuffle(random);

    setState(() {
      currentQuestion = shuffled[0];
      options = shuffled.take(4).toList()..shuffle(random);
      selectedOption = null;
      isAudioPlaying = true;
      canAnswer = false;
      errorMessage = null;
    });

    // Load and play audio at 2x speed
    _playQuestionAudio();
  }

  Future<void> _playQuestionAudio() async {
    try {
      if (!mounted || currentQuestion == null) return;

      final audioCubit = context.read<AudioCubit>();
      await audioCubit.loadAudio(fileName: currentQuestion!.fileName);

      // Set speed to 2x for faster gameplay
      await audioCubit.setPlaybackSpeed(2.0);
      await audioCubit.playAudio();

      // Listen to audio completion
      final audioPlayer = audioCubit.audioPlayer;
      final subscription = audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() {
              isAudioPlaying = false;
              canAnswer = true;
            });
          }
        }
      });

      // Cleanup subscription after a reasonable time
      Future.delayed(const Duration(seconds: 5), () {
        subscription.cancel();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isAudioPlaying = false;
          canAnswer = true;
          errorMessage = 'Audio playback error. Tap to continue.';
        });
      }
    }
  }

  void _selectOption(int index) {
    // Prevent interaction if game is not active
    if (!isGameActive) {
      setState(() {
        errorMessage = 'Game is not active!';
      });
      _clearErrorMessage();
      return;
    }

    // Prevent repeat presses
    if (selectedOption != null) {
      setState(() {
        errorMessage = 'Please wait for next question...';
      });
      _clearErrorMessage();
      return;
    }

    // Prevent answering while audio is playing
    if (isAudioPlaying || !canAnswer) {
      setState(() {
        errorMessage = '🎧 Please wait for audio to finish!';
      });
      _clearErrorMessage();
      return;
    }

    setState(() {
      selectedOption = index;
      errorMessage = null;
    });

    final isCorrect = options[index].fileName == currentQuestion!.fileName;

    if (isCorrect) {
      _confettiController.play();
      _correctAnimController.forward().then((_) {
        _correctAnimController.reverse();
      });

      setState(() {
        correctAnswers++;
        streak++;
        if (streak > maxStreak) maxStreak = streak;

        // Bonus points for streaks
        int points = 10;
        if (streak >= 5) points += 10;
        if (streak >= 10) points += 20;

        score += points;
      });

      // Quick transition to next question
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && isGameActive) {
          _loadNextQuestion();
        }
      });
    } else {
      setState(() {
        wrongAnswers++;
        streak = 0;
      });

      // Short delay before next question
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && isGameActive) {
          _loadNextQuestion();
        }
      });
    }
  }

  void _clearErrorMessage() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  void _gameOver() {
    if (!mounted) return;

    setState(() {
      isGameActive = false;
      isAudioPlaying = false;
      canAnswer = false;
      errorMessage = null;
    });

    gameTimer?.cancel();
    _timerController.stop();

    // Stop audio if still playing
    try {
      context.read<AudioCubit>().pauseAudio();
    } catch (e) {
      // Audio cubit might not be available
      print('Could not stop audio: $e');
    }

    // Calculate stars based on correct answers
    int stars = 1;
    if (correctAnswers >= 30) {
      stars = 3;
    } else if (correctAnswers >= 20) {
      stars = 2;
    }

    final coinsEarned = score + (stars * 10);

    // Update game stats
    context.read<GameBloc>().add(UpdateGameStars(
          gameType: GameType.speedChallengeGame,
          stars: stars,
          coinsEarned: coinsEarned,
        ));

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GameResultDialog(
          title: 'Time\'s Up! ⚡',
          score: score,
          stars: stars,
          coinsEarned: coinsEarned,
          message:
              'Correct: $correctAnswers | Wrong: $wrongAnswers\nMax Streak: $maxStreak',
          onPlayAgain: () {
            Navigator.pop(context);
            _resetGame();
          },
          onExit: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  void _resetGame() {
    _timerController.reset();
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        GameLayout(
          title: 'Speed Challenge',
          scoreCards: [
            GameScoreCard(label: 'Score', value: score.toString(), icon: Icons.star),
            GameScoreCard(label: 'Correct', value: correctAnswers.toString(), icon: Icons.check),
            GameScoreCard(label: 'Wrong', value: wrongAnswers.toString(), icon: Icons.close),
          ],
          topWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time: ${timeRemaining}s',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Streak: $streak 🔥',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: ApplicationUtil.getBoxDecorationTwo(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: timeRemaining / timeLimit,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timeRemaining <= 10 ? Colors.red.shade400 : Theme.of(context).primaryColorLight,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          gameContent: Column(
            children: [
              // Question - Listen to character with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isAudioPlaying
                      ? Theme.of(context).primaryColorLight
                      : Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: const Offset(-5, -3),
                      spreadRadius: isAudioPlaying ? -2 : -4,
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: isAudioPlaying ? Colors.greenAccent.withOpacity(0.5) : Colors.white24,
                      offset: const Offset(5, 5),
                      spreadRadius: isAudioPlaying ? 5 : 3,
                      blurRadius: isAudioPlaying ? 15 : 10,
                    ),
                  ],
                ),
                child: Icon(
                  isAudioPlaying ? Icons.hearing : Icons.headphones,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // Audio status indicator
              AnimatedOpacity(
                opacity: isAudioPlaying ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Text(
                  '🎵 Playing...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Error message overlay
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Options grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return _buildOptionCard(index);
                  },
                ),
              ),
            ],
          ),
        ),

        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 10,
            gravity: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(int index) {
    final isSelected = selectedOption == index;
    final isCorrect = selectedOption != null &&
        options[index].fileName == currentQuestion!.fileName;
    final isWrong = isSelected && !isCorrect;
    final isDisabled = isAudioPlaying || !canAnswer || selectedOption != null;

    BoxDecoration decoration;
    Color textColor;

    if (isCorrect) {
      decoration = BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
        ],
      );
      textColor = Colors.white;
    } else if (isWrong) {
      decoration = BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
        ],
      );
      textColor = Colors.white;
    } else if (isDisabled) {
      decoration = BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(-2, -2), blurRadius: 4),
          BoxShadow(color: Colors.white12, offset: Offset(2, 2), blurRadius: 4),
        ],
      );
      textColor = Colors.grey.shade600;
    } else {
      decoration = ApplicationUtil.getBoxDecorationTwo(context);
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: decoration,
        child: Stack(
          children: [
            Center(
              child: Text(
                options[index].alphabetName,
                style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'jomolhari',
                  color: textColor,
                ),
              ),
            ),
            // Show lock icon when disabled
            if (isDisabled && selectedOption == null)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.lock,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
