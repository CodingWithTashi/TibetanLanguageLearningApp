import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../game_bloc/game_bloc.dart';
import '../../../cubit/audio_cubit.dart';
import '../../../util/constant.dart';
import '../../../util/application_util.dart';
import '../util/game_model.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/game_score_card.dart';

class AlphabetMatchGame extends StatefulWidget {
  const AlphabetMatchGame({Key? key}) : super(key: key);

  @override
  State<AlphabetMatchGame> createState() => _AlphabetMatchGameState();
}

class _AlphabetMatchGameState extends State<AlphabetMatchGame>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;

  List<MatchCard> cards = [];
  List<int> selectedIndices = [];
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
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _initializeGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final random = Random();
    final alphabets = AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET).toList()..shuffle(random);
    final selectedAlphabets = alphabets.take(totalPairs).toList();

    cards.clear();
    for (var alphabet in selectedAlphabets) {
      cards.add(MatchCard(id: alphabet.fileName, displayText: alphabet.alphabetName, isCharacter: true, audioFileName: alphabet.fileName));
      cards.add(MatchCard(id: alphabet.fileName, displayText: alphabet.fileName.toUpperCase(), isCharacter: false, audioFileName: alphabet.fileName));
    }
    cards.shuffle(random);
    setState(() {});
  }

  void _onCardTap(int index) {
    if (isProcessing || selectedIndices.contains(index) || matchedIndices.contains(index) || selectedIndices.length >= 2) return;

    setState(() {
      selectedIndices.add(index);
      moves++;
    });

    context.read<AudioCubit>().loadAudio(fileName: cards[index].audioFileName);
    context.read<AudioCubit>().playAudio();

    if (selectedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    isProcessing = true;
    final firstCard = cards[selectedIndices[0]];
    final secondCard = cards[selectedIndices[1]];

    if (firstCard.id == secondCard.id) {
      _animationController.forward().then((_) => _animationController.reverse());

      setState(() {
        matchedIndices.addAll(selectedIndices);
        matches++;
        score += 10;
        selectedIndices.clear();
        isProcessing = false;
      });

      if (matches == totalPairs) {
        _gameComplete();
      }
    } else {
      Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          selectedIndices.clear();
          isProcessing = false;
        });
      });
    }
  }

  void _gameComplete() {
    _confettiController.play();

    int stars = moves <= 12 ? 3 : (moves <= 16 ? 2 : 1);
    final coinsEarned = score + (stars * 15);

    context.read<GameBloc>().add(UpdateGameStars(gameType: GameType.alphabetMatchGame, stars: stars, coinsEarned: coinsEarned));
    context.read<GameBloc>().add(UpdateGameScore(gameType: GameType.alphabetMatchGame, score: score));

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GameResultDialog(
            title: 'Amazing! 🎉',
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
      selectedIndices.clear();
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
                      const Text('Alphabet Match', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                GameScoreRow(
                  cards: [
                    GameScoreCard(label: 'Moves', value: moves.toString(), icon: Icons.touch_app),
                    GameScoreCard(label: 'Pairs', value: '$matches/$totalPairs', icon: Icons.check_circle),
                    GameScoreCard(label: 'Score', value: score.toString(), icon: Icons.star),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedIndices.contains(index);
                        final isMatched = matchedIndices.contains(index);
                        return _buildCard(cards[index], isSelected, isMatched, index);
                      },
                    ),
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
              numberOfParticles: 25,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(MatchCard card, bool isSelected, bool isMatched, int index) {
    BoxDecoration decoration;
    Color textColor;

    if (isMatched) {
      decoration = BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
        ],
      );
      textColor = Colors.white;
    } else if (isSelected) {
      decoration = ApplicationUtil.getBoxDecorationTwo(context);
      textColor = Colors.black87;
    } else {
      decoration = ApplicationUtil.getBoxDecorationOne(context);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: decoration,
        child: Center(
          child: Text(
            card.displayText,
            style: TextStyle(
              fontSize: card.isCharacter ? 42 : 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: card.isCharacter ? 'jomolhari' : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MatchCard {
  final String id;
  final String displayText;
  final bool isCharacter;
  final String audioFileName;

  MatchCard({required this.id, required this.displayText, required this.isCharacter, required this.audioFileName});
}
