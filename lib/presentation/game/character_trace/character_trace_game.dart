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

class CharacterTraceGame extends StatefulWidget {
  const CharacterTraceGame({Key? key}) : super(key: key);

  @override
  State<CharacterTraceGame> createState() => _CharacterTraceGameState();
}

class _CharacterTraceGameState extends State<CharacterTraceGame> {
  late ConfettiController _confettiController;

  List<Offset> drawnPoints = [];
  List<Alphabet> alphabets = [];
  int currentIndex = 0;
  int score = 0;
  int completedCharacters = 0;
  int totalCharacters = 10;
  bool hasDrawn = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initializeGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final random = Random();
    final allAlphabets = AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET)
        .toList()
      ..shuffle(random);

    alphabets = allAlphabets.take(totalCharacters).toList();
    _playCurrentCharacterAudio();
  }

  void _playCurrentCharacterAudio() {
    if (currentIndex < alphabets.length) {
      final current = alphabets[currentIndex];
      context.read<AudioCubit>().loadAudio(
        fileName: current.fileName
      );
      context.read<AudioCubit>().playAudio();
    }
  }

  void _checkDrawing() {
    if (!hasDrawn) return;

    // Simple validation - check if user drew something
    final isValid = drawnPoints.length > 10;

    if (isValid) {
      _confettiController.play();
      setState(() {
        completedCharacters++;
        score += 15;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (completedCharacters >= totalCharacters) {
          _gameComplete();
        } else {
          setState(() {
            currentIndex++;
            drawnPoints.clear();
            hasDrawn = false;
          });
          _playCurrentCharacterAudio();
        }
      });
    } else {
      _showFeedback('Try tracing the character!', Colors.orange);
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _gameComplete() {
    // Calculate stars based on completion
    int stars = 3;
    if (score < 100) {
      stars = 1;
    } else if (score < 130) {
      stars = 2;
    }

    final coinsEarned = score + (stars * 10);

    // Update game stats
    context.read<GameBloc>().add(UpdateGameStars(
          gameType: GameType.characterTraceGame,
          stars: stars,
          coinsEarned: coinsEarned,
        ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Well Done! 🎨',
        score: score,
        stars: stars,
        coinsEarned: coinsEarned,
        message: 'You traced $completedCharacters characters!',
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
      drawnPoints.clear();
      currentIndex = 0;
      score = 0;
      completedCharacters = 0;
      hasDrawn = false;
    });
    _initializeGame();
  }

  void _clearDrawing() {
    setState(() {
      drawnPoints.clear();
      hasDrawn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAlphabet = currentIndex < alphabets.length
        ? alphabets[currentIndex]
        : alphabets.last;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Character Trace'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Progress: $completedCharacters/$totalCharacters',
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

                  // Score display
                  GameScoreRow(
                    cards: [
                      GameScoreCard(label: 'Score', value: score.toString(), icon: Icons.star),
                      GameScoreCard(label: 'Traced', value: '$completedCharacters', icon: Icons.check_circle),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Instruction
                  const Text(
                    'Trace the character below:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Character to trace (reference)
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: ApplicationUtil.getBoxDecorationTwo(context),
                    child: Center(
                      child: Text(
                        currentAlphabet.alphabetName,
                        style: const TextStyle(
                          fontSize: 80,
                          fontFamily: 'jomolhari',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Drawing area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: ApplicationUtil.getBoxDecorationTwo(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: GestureDetector(
                          onPanStart: (details) {
                            setState(() {
                              hasDrawn = true;
                              drawnPoints.add(details.localPosition);
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              drawnPoints.add(details.localPosition);
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              drawnPoints.add(Offset.infinite);
                            });
                          },
                          child: CustomPaint(
                            painter: DrawingPainter(drawnPoints),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _clearDrawing,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: ApplicationUtil.getBoxDecorationOne(context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.clear, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Clear', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _checkDrawing,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: ApplicationUtil.getBoxDecorationOne(context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Check', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].isFinite && points[i + 1].isFinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
