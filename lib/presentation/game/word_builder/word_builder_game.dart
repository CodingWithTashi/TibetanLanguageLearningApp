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

class WordBuilderGame extends StatefulWidget {
  const WordBuilderGame({Key? key}) : super(key: key);

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;

  List<Verb> allVerbs = [];
  Verb? currentWord;
  List<String> availableCharacters = [];
  List<String> selectedCharacters = [];

  int currentWordIndex = 0;
  int totalWords = 10;
  int score = 0;
  int correctWords = 0;
  int hints = 3;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _initializeGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    allVerbs = AppConstant.verbsList;
    if (allVerbs.isNotEmpty) {
      _loadNextWord();
    }
  }

  void _loadNextWord() {
    if (currentWordIndex >= totalWords) {
      _gameComplete();
      return;
    }

    final random = Random();
    final shuffledVerbs = List<Verb>.from(allVerbs)..shuffle(random);

    setState(() {
      currentWord = shuffledVerbs[0];
      availableCharacters = List<String>.from(currentWord!.characterList);
      availableCharacters.shuffle(random);
      selectedCharacters = [];
    });

    // Play audio
    Future.delayed(const Duration(milliseconds: 500), () {
      _playWordAudio();
    });
  }

  void _playWordAudio() {
    if (currentWord != null) {
      context.read<AudioCubit>().loadAudio(
        fileName: currentWord!.fileName
      );
      context.read<AudioCubit>().playAudio();
    }
  }

  void _selectCharacter(int index) {
    if (index >= availableCharacters.length) return;

    setState(() {
      selectedCharacters.add(availableCharacters[index]);
      availableCharacters.removeAt(index);
    });

    // Auto-check when all characters are selected
    if (availableCharacters.isEmpty) {
      _checkWord();
    }
  }

  void _removeCharacter(int index) {
    if (index >= selectedCharacters.length) return;

    setState(() {
      availableCharacters.add(selectedCharacters[index]);
      selectedCharacters.removeAt(index);
    });
  }

  void _checkWord() {
    final builtWord = selectedCharacters.join();
    final correctWord = currentWord!.word;

    if (builtWord == correctWord) {
      _confettiController.play();
      setState(() {
        correctWords++;
        score += 15;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          currentWordIndex++;
        });
        _loadNextWord();
      });
    } else {
      _showFeedback('Not quite right. Try again!', Colors.orange);
    }
  }

  void _useHint() {
    if (hints <= 0 || currentWord == null) return;

    // Find the next correct character
    final correctChars = currentWord!.characterList;
    final nextCorrectIndex = selectedCharacters.length;

    if (nextCorrectIndex < correctChars.length) {
      final nextChar = correctChars[nextCorrectIndex];
      final availableIndex = availableCharacters.indexOf(nextChar);

      if (availableIndex != -1) {
        setState(() {
          hints--;
          selectedCharacters.add(availableCharacters[availableIndex]);
          availableCharacters.removeAt(availableIndex);
        });

        // Auto-check if complete
        if (availableCharacters.isEmpty) {
          _checkWord();
        }
      }
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

  void _skip() {
    setState(() {
      currentWordIndex++;
    });
    _loadNextWord();
  }

  void _gameComplete() {
    // Calculate stars based on correct words
    int stars = 1;
    final percentage = (correctWords / totalWords) * 100;
    if (percentage >= 90) {
      stars = 3;
    } else if (percentage >= 70) {
      stars = 2;
    }

    final coinsEarned = score + (stars * 10);

    // Update game stats
    context.read<GameBloc>().add(UpdateGameStars(
          gameType: GameType.wordBuilderGame,
          stars: stars,
          coinsEarned: coinsEarned,
        ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Fantastic! 🎯',
        score: score,
        stars: stars,
        coinsEarned: coinsEarned,
        message: 'You built $correctWords out of $totalWords words!',
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
      currentWordIndex = 0;
      score = 0;
      correctWords = 0;
      hints = 3;
      selectedCharacters = [];
      availableCharacters = [];
    });
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    if (currentWord == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Word Builder'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Word ${currentWordIndex + 1}/$totalWords',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreCard('Score', score.toString(), Icons.star),
                        _buildScoreCard('Correct', correctWords.toString(), Icons.check),
                        _buildScoreCard('Hints', hints.toString(), Icons.lightbulb),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Listen button
                  GestureDetector(
                    onTap: _playWordAudio,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: ApplicationUtil.getBoxDecorationOne(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Listen to Word',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Selected characters (word being built)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(minHeight: 100),
                    decoration: ApplicationUtil.getBoxDecorationTwo(context),
                    child: selectedCharacters.isEmpty
                        ? const Center(
                            child: Text(
                              'Build the word here',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              selectedCharacters.length,
                              (index) => GestureDetector(
                                onTap: () => _removeCharacter(index),
                                child: _buildCharacterChip(
                                  selectedCharacters[index],
                                  true,
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Available Characters:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Available characters
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                          availableCharacters.length,
                          (index) => GestureDetector(
                            onTap: () => _selectCharacter(index),
                            child: _buildCharacterChip(
                              availableCharacters[index],
                              false,
                            ),
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
                            onTap: hints > 0 ? _useHint : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: hints > 0 ? ApplicationUtil.getBoxDecorationOne(context) : ApplicationUtil.getBoxDecorationTwo(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lightbulb_outline, color: hints > 0 ? Colors.white : Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('Hint ($hints)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: hints > 0 ? Colors.white : Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _skip,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: ApplicationUtil.getBoxDecorationOne(context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.skip_next, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Skip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildCharacterChip(String character, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isSelected
        ? ApplicationUtil.getBoxDecorationOne(context)
        : ApplicationUtil.getBoxDecorationTwo(context),
      child: Text(
        character,
        style: TextStyle(
          fontSize: 36,
          fontFamily: 'jomolhari',
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
