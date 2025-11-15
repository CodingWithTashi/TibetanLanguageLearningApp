import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
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
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timerController.dispose();
    _correctAnimController.dispose();
    gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    allAlphabets = AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET)
        .toList();

    if (allAlphabets.length >= 4) {
      _showStartDialog();
    }
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
    final random = Random();
    final shuffled = List<Alphabet>.from(allAlphabets)..shuffle(random);

    setState(() {
      currentQuestion = shuffled[0];
      options = shuffled.take(4).toList()..shuffle(random);
      selectedOption = null;
    });

    // Play audio
    context.read<AudioCubit>().loadAudio(fileName: currentQuestion!.fileName);
    context.read<AudioCubit>().playAudio();
  }

  void _selectOption(int index) {
    if (!isGameActive || selectedOption != null) return;

    setState(() {
      selectedOption = index;
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
        if (isGameActive) {
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
        if (isGameActive) {
          _loadNextQuestion();
        }
      });
    }
  }

  void _gameOver() {
    setState(() {
      isGameActive = false;
    });

    gameTimer?.cancel();
    _timerController.stop();

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
              // Question - Listen to character
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(-5, -3),
                      spreadRadius: -4,
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.white24,
                      offset: Offset(5, 5),
                      spreadRadius: 3,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.headphones,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

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

    BoxDecoration decoration;
    if (isCorrect) {
      decoration = BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
        ],
      );
    } else if (isWrong) {
      decoration = BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
        ],
      );
    } else {
      decoration = ApplicationUtil.getBoxDecorationTwo(context);
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: decoration,
        child: Center(
          child: Text(
            options[index].alphabetName,
            style: TextStyle(
              fontSize: 60,
              fontFamily: 'jomolhari',
              color: (isCorrect || isWrong) ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
