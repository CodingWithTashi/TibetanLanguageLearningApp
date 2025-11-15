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

class SoundQuizGame extends StatefulWidget {
  const SoundQuizGame({Key? key}) : super(key: key);

  @override
  State<SoundQuizGame> createState() => _SoundQuizGameState();
}

class _SoundQuizGameState extends State<SoundQuizGame>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;

  List<Alphabet> allAlphabets = [];
  Alphabet? currentQuestion;
  List<Alphabet> options = [];

  int currentQuestionIndex = 0;
  int totalQuestions = 15;
  int score = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  bool hasAnswered = false;
  int? selectedOption;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    allAlphabets = AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET)
        .toList();

    if (allAlphabets.length >= 4) {
      _loadNextQuestion();
    }
  }

  void _loadNextQuestion() {
    if (currentQuestionIndex >= totalQuestions) {
      _gameComplete();
      return;
    }

    final random = Random();
    final shuffled = List<Alphabet>.from(allAlphabets)..shuffle(random);

    setState(() {
      currentQuestion = shuffled[0];
      options = shuffled.take(4).toList()..shuffle(random);
      hasAnswered = false;
      selectedOption = null;
    });

    // Play the sound after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _playSound();
    });
  }

  void _playSound() {
    if (currentQuestion != null) {
      context.read<AudioCubit>().loadAudio(
        fileName: currentQuestion!.fileName
      );
      context.read<AudioCubit>().playAudio();
    }
  }

  void _selectOption(int index) {
    if (hasAnswered) return;

    setState(() {
      selectedOption = index;
      hasAnswered = true;
    });

    final isCorrect = options[index].fileName == currentQuestion!.fileName;

    if (isCorrect) {
      _confettiController.play();
      setState(() {
        correctAnswers++;
        score += 10;
      });
    } else {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      setState(() {
        wrongAnswers++;
      });
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        currentQuestionIndex++;
      });
      _loadNextQuestion();
    });
  }

  void _gameComplete() {
    // Calculate stars based on correct answers
    int stars = 1;
    final percentage = (correctAnswers / totalQuestions) * 100;
    if (percentage >= 90) {
      stars = 3;
    } else if (percentage >= 70) {
      stars = 2;
    }

    final coinsEarned = score + (stars * 10);

    // Update game stats
    context.read<GameBloc>().add(UpdateGameStars(
          gameType: GameType.soundQuizGame,
          stars: stars,
          coinsEarned: coinsEarned,
        ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Excellent! 🎧',
        score: score,
        stars: stars,
        coinsEarned: coinsEarned,
        message:
            'You got $correctAnswers out of $totalQuestions questions right!',
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
  }

  void _resetGame() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      correctAnswers = 0;
      wrongAnswers = 0;
      hasAnswered = false;
      selectedOption = null;
    });
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Sound Quiz'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Question ${currentQuestionIndex + 1}/$totalQuestions',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Score cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreCard('Score', score.toString(), Icons.star),
                        _buildScoreCard('Correct', correctAnswers.toString(), Icons.check_circle),
                        _buildScoreCard('Wrong', wrongAnswers.toString(), Icons.cancel),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Listen instruction
                  const Text(
                    'Listen carefully and select the character',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Play sound button
                  GestureDetector(
                    onTap: _playSound,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: ApplicationUtil.getBoxDecorationOne(context).copyWith(shape: BoxShape.circle),
                      child: const Icon(
                        Icons.volume_up,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Options
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
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ApplicationUtil.getBoxDecorationOne(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final isSelected = selectedOption == index;
    final isCorrect = hasAnswered &&
        options[index].fileName == currentQuestion!.fileName;
    final isWrong = hasAnswered && isSelected && !isCorrect;

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

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = isWrong
            ? sin(_shakeController.value * pi * 4) * 10
            : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _selectOption(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
      ),
    );
  }
}
