import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../game_bloc/game_bloc.dart';
import '../../../cubit/audio_cubit.dart';
import '../../../util/constant.dart';
import '../util/game_model.dart';
import '../widgets/game_result_dialog.dart';

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
  int totalPairs = 6;
  int score = 0;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    // Get random alphabets from the constants
    final random = Random();
    final alphabets = AppConstant.alphabetList
        .where((a) => a.type == AlphabetType.ALPHABET)
        .toList()
      ..shuffle(random);

    final selectedAlphabets = alphabets.take(totalPairs).toList();

    // Create pairs - one with Tibetan character, one with sound name
    cards.clear();
    for (var alphabet in selectedAlphabets) {
      // Tibetan character card
      cards.add(MatchCard(
        id: alphabet.fileName,
        displayText: alphabet.alphabetName,
        isCharacter: true,
        audioFileName: alphabet.fileName,
      ));

      // Sound name card (romanized)
      cards.add(MatchCard(
        id: alphabet.fileName,
        displayText: alphabet.fileName.toUpperCase(),
        isCharacter: false,
        audioFileName: alphabet.fileName,
      ));
    }

    cards.shuffle(random);
    setState(() {});
  }

  void _onCardTap(int index) {
    if (isProcessing ||
        selectedIndices.contains(index) ||
        matchedIndices.contains(index) ||
        selectedIndices.length >= 2) {
      return;
    }

    setState(() {
      selectedIndices.add(index);
      moves++;
    });

    // Play audio for the card
    final card = cards[index];
    context.read<AudioCubit>().loadAudio(card.audioFileName);
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
      // Match found!
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

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
      // No match
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

    // Calculate stars based on moves
    int stars = 3;
    if (moves > totalPairs * 2.5) {
      stars = 1;
    } else if (moves > totalPairs * 2) {
      stars = 2;
    }

    final coinsEarned = score + (stars * 10);

    // Update game stats
    context.read<GameBloc>().add(UpdateGameStars(
          gameType: GameType.alphabetMatchGame,
          stars: stars,
          coinsEarned: coinsEarned,
        ));

    // Show result dialog
    Future.delayed(const Duration(seconds: 1), () {
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
      appBar: AppBar(
        title: const Text('Alphabet Match'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Moves: $moves | Matches: $matches/$totalPairs',
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
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreCard('Score', score.toString(), Icons.star, Colors.amber),
                        _buildScoreCard('Moves', moves.toString(), Icons.touch_app, Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedIndices.contains(index);
                        final isMatched = matchedIndices.contains(index);

                        return _buildCard(cards[index], isSelected, isMatched, index);
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
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(MatchCard card, bool isSelected, bool isMatched, int index) {
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isMatched
                ? [Colors.green.shade300, Colors.green.shade500]
                : isSelected
                    ? [Colors.blue.shade300, Colors.blue.shade500]
                    : [Colors.white, Colors.grey.shade100],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isSelected || isMatched
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected || isMatched ? 15 : 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            card.displayText,
            style: TextStyle(
              fontSize: card.isCharacter ? 48 : 20,
              fontWeight: FontWeight.bold,
              color: isMatched || isSelected ? Colors.white : Colors.black87,
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

  MatchCard({
    required this.id,
    required this.displayText,
    required this.isCharacter,
    required this.audioFileName,
  });
}
