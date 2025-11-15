import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../game_bloc/game_bloc.dart';
import '../../../cubit/audio_cubit.dart';
import '../../../model/alphabet.dart';
import '../../../util/constant.dart';
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
      appBar: AppBar(
        title: const Text('Sound Quiz'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Question ${currentQuestionIndex + 1}/$totalQuestions',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.shade50,
                  Colors.cyan.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Score cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreCard('Score', score.toString(), Icons.star, Colors.amber),
                        _buildScoreCard('Correct', correctAnswers.toString(), Icons.check_circle, Colors.green),
                        _buildScoreCard('Wrong', wrongAnswers.toString(), Icons.cancel, Colors.red),
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
                      color: Colors.indigo,
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade400, Colors.purple.shade400],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
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

  Widget _buildScoreCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;

    if (isCorrect) {
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green;
    } else if (isWrong) {
      backgroundColor = Colors.red.shade100;
      borderColor = Colors.red;
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
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              options[index].alphabetName,
              style: const TextStyle(
                fontSize: 60,
                fontFamily: 'jomolhari',
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
