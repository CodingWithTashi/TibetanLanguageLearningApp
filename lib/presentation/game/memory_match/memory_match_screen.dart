import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../game_bloc/game_bloc.dart';
import '../../../cubit/audio_cubit.dart';
import '../../../model/verb.dart';
import '../../../util/constant.dart';
import '../../../util/application_util.dart';
import '../util/game_model.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/game_score_card.dart';
import '../widgets/game_layout.dart';

class MemoryMatchGameScreen extends StatefulWidget {
  static const routeName = 'memory-match-game';

  const MemoryMatchGameScreen({Key? key}) : super(key: key);

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _flipController;

  List<MemoryCard> cards = [];
  List<int> flippedIndices = [];
  List<int> matchedIndices = [];
  int moves = 0;
  int matches = 0;
  final int totalPairs = 6;
  int score = 0;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final random = Random();
    final verbs = AppConstant.verbsList.toList()..shuffle(random);
    final selectedVerbs = verbs.take(totalPairs).toList();

    cards.clear();
    for (var verb in selectedVerbs) {
      cards.add(MemoryCard(id: verb.fileName, verb: verb));
      cards.add(MemoryCard(id: verb.fileName, verb: verb));
    }
    cards.shuffle(random);
    setState(() {});
  }

  void _onCardTap(int index) {
    if (isProcessing ||
        flippedIndices.contains(index) ||
        matchedIndices.contains(index) ||
        flippedIndices.length >= 2) return;

    setState(() {
      flippedIndices.add(index);
      if (flippedIndices.length == 1) {
        moves++;
      }
    });

    // Play audio
    context.read<AudioCubit>().loadAudio(fileName: cards[index].verb.fileName);
    context.read<AudioCubit>().playAudio();

    if (flippedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    isProcessing = true;
    final firstCard = cards[flippedIndices[0]];
    final secondCard = cards[flippedIndices[1]];

    if (firstCard.id == secondCard.id) {
      _flipController.forward().then((_) => _flipController.reverse());

      setState(() {
        matchedIndices.addAll(flippedIndices);
        matches++;
        score += 15;
        flippedIndices.clear();
        isProcessing = false;
      });

      if (matches == totalPairs) {
        _gameComplete();
      }
    } else {
      Timer(const Duration(milliseconds: 1200), () {
        setState(() {
          flippedIndices.clear();
          isProcessing = false;
        });
      });
    }
  }

  void _gameComplete() {
    _confettiController.play();

    int stars = moves <= 14 ? 3 : (moves <= 20 ? 2 : 1);
    final coinsEarned = score + (stars * 15);

    context.read<GameBloc>().add(UpdateGameStars(
          gameType: GameType.memoryGame,
          stars: stars,
          coinsEarned: coinsEarned,
        ));

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GameResultDialog(
            title: 'Well Done! 🎊',
            score: score,
            stars: stars,
            coinsEarned: coinsEarned,
            message: 'You matched all pairs in $moves moves!',
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
    });
  }

  void _resetGame() {
    setState(() {
      flippedIndices.clear();
      matchedIndices.clear();
      moves = 0;
      matches = 0;
      score = 0;
      isProcessing = false;
    });
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameLayout(
          title: 'Memory Match',
          scoreCards: [
            GameScoreCard(label: 'Moves', value: moves.toString(), icon: Icons.touch_app),
            GameScoreCard(label: 'Pairs', value: '$matches/$totalPairs', icon: Icons.check_circle),
            GameScoreCard(label: 'Score', value: score.toString(), icon: Icons.star),
          ],
          gameContent: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final isFlipped = flippedIndices.contains(index);
                final isMatched = matchedIndices.contains(index);
                return _buildCard(cards[index], isFlipped, isMatched, index);
              },
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
            numberOfParticles: 25,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(MemoryCard card, bool isFlipped, bool isMatched, int index) {
    BoxDecoration frontDecoration;
    if (isMatched) {
      frontDecoration = BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
        ],
      );
    } else {
      frontDecoration = ApplicationUtil.getBoxDecorationTwo(context);
    }

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: isFlipped || isMatched
            ? frontDecoration
            : ApplicationUtil.getBoxDecorationOne(context),
        child: isFlipped || isMatched
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        ApplicationUtil.getImagePath(card.verb.fileName),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Name below image
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      card.verb.word,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'jomolhari',
                        fontWeight: FontWeight.bold,
                        color: isMatched ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : const Center(
                child: Icon(
                  Icons.help_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class MemoryCard {
  final String id;
  final Verb verb;

  MemoryCard({
    required this.id,
    required this.verb,
  });
}
