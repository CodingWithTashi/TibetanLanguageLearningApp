import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drag.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drop.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/fly_in_animation.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import '../widgets/game_layout.dart';
import '../widgets/game_score_card.dart';

class SpellingBeePage extends StatefulWidget {
  static const routeName = 'spelling-bee';
  const SpellingBeePage({Key? key}) : super(key: key);

  @override
  State<SpellingBeePage> createState() => _SpellingBeePageState();
}

class _SpellingBeePageState extends State<SpellingBeePage> {
  List<Verb> _tempList = List.from(AppConstant.verbsList);
  late Verb selectedVerb;
  late Verb shuffledVerb;
  late ConfettiController _controllerTopCenter;
  late ConfettiController _controllerTopRight;
  late ConfettiController _controllerTopLeft;
  late ConfettiController _controllerBottomCenter;
  final _gravity = 0.4;
  final _duration = 4;

  @override
  void initState() {
    //_generateWord();
    _controllerTopCenter =
        ConfettiController(duration: Duration(seconds: _duration));
    _controllerTopRight =
        ConfettiController(duration: Duration(seconds: _duration));
    _controllerTopLeft =
        ConfettiController(duration: Duration(seconds: _duration));
    _controllerBottomCenter =
        ConfettiController(duration: Duration(seconds: 1));

    super.initState();
  }

  @override
  void dispose() {
    _controllerTopCenter.dispose();
    _controllerTopRight.dispose();
    _controllerTopLeft.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showWarningDialog(),
      child: Selector<SpellingBeeProvider, bool>(
        selector: (_, controller) => controller.generateWord,
        builder: (_, generate, __) {
          if (generate) {
            if (_tempList.isNotEmpty) {
              _generateWord();
            }
          }

          final provider = context.watch<SpellingBeeProvider>();
          final totalWords = AppConstant.verbsList.length;
          final wordsCompleted = provider.wordAnswered;
          final progress = wordsCompleted / totalWords;

          return Stack(
            children: [
              GameLayout(
                title: 'Spelling Bee Contest 🐝',
                scoreCards: [
                  GameScoreCard(
                    label: 'Words',
                    value: '$wordsCompleted/$totalWords',
                    icon: Icons.check_circle,
                  ),
                  GameScoreCard(
                    label: 'Progress',
                    value: '${(progress * 100).toInt()}%',
                    icon: Icons.trending_up,
                  ),
                  GameScoreCard(
                    label: 'Letters',
                    value: '${provider.lettersAnswered}/${provider.totalLetters}',
                    icon: Icons.text_fields,
                  ),
                ],
                gameContent: Column(
                  children: [
                    const SizedBox(height: 10),
                    _getDropContent(),
                    const SizedBox(height: 20),
                    _getImageForWord(),
                    const SizedBox(height: 20),
                    _getDragContent(),
                    const SizedBox(height: 20),
                    _getProgressBar(progress, wordsCompleted, totalWords),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              _getFinishCelebAnimation(),
              _getCelebAnimationOnCorrectAnswer(),
            ],
          );
        },
      ),
    );
  }

  void _generateWord() {
    final randomNumber = Random().nextInt(_tempList.length);
    selectedVerb = _tempList[randomNumber];

    if (_tempList[randomNumber].characterList.isNotEmpty) {
      List<String> characterList =
          List.from(_tempList[randomNumber].characterList)..shuffle();

      shuffledVerb = Verb(
          fileName: _tempList[randomNumber].fileName,
          word: _tempList[randomNumber].word,
          characterList: characterList);
    }
    _tempList.removeAt(randomNumber);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<SpellingBeeProvider>(context, listen: false)
          .setUp(total: shuffledVerb.characterList.length);
      Provider.of<SpellingBeeProvider>(context, listen: false)
          .requestWord(request: false);
    });
  }


  Widget _getDropContent() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: selectedVerb.characterList
              .map((e) => FlyInAnimation(animate: true, child: Drop(letter: e)))
              .toList(),
        ),
      ),
    );
  }

  Widget _getImageForWord() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        ApplicationUtil.getImagePath(selectedVerb.fileName),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _getDragContent() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: shuffledVerb.characterList
              .map((e) => FlyInAnimation(
                    animate: true,
                    child: Drag(letter: e),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _getProgressBar(double progress, int completed, int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: ApplicationUtil.getBoxDecorationTwo(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Game Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getTopCelebrateAnimation() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _controllerTopCenter,
        blastDirection: pi / 2,
        maxBlastForce: 5, // set a lower max blast force
        minBlastForce: 2, // set a lower min blast force
        emissionFrequency: 0.05,
        numberOfParticles: 50, // a lot of particles at once
        gravity: _gravity,
      ),
    );
  }

  _getTopRightCelebrateAnimation() {
    return Align(
      alignment: Alignment.topRight,
      child: ConfettiWidget(
        confettiController: _controllerTopRight,
        blastDirection: pi / 2,
        maxBlastForce: 5, // set a lower max blast force
        minBlastForce: 2, // set a lower min blast force
        emissionFrequency: 0.05,
        numberOfParticles: 50, // a lot of particles at once
        gravity: _gravity,
      ),
    );
  }

  _getTopLeftCelebrateAnimation() {
    return Align(
      alignment: Alignment.topLeft,
      child: ConfettiWidget(
        confettiController: _controllerTopLeft,
        blastDirection: pi / 2,
        maxBlastForce: 5, // set a lower max blast force
        minBlastForce: 2, // set a lower min blast force
        emissionFrequency: 0.05,
        numberOfParticles: 50, // a lot of particles at once
        gravity: _gravity,
      ),
    );
  }

  _getFinishCelebAnimation() {
    return Selector<SpellingBeeProvider, bool>(
      selector: (_, controller) => controller.sessionCompleted,
      builder: (_, sessionCompleted, __) {
        if (sessionCompleted) {
          _controllerTopCenter.play();
          _controllerTopRight.play();
          _controllerTopLeft.play();
        }
        return Stack(
          children: [
            _getTopCelebrateAnimation(),
            _getTopRightCelebrateAnimation(),
            _getTopLeftCelebrateAnimation(),
          ],
        );
      },
    );
  }

  _getCelebAnimationOnCorrectAnswer() {
    return Selector<SpellingBeeProvider, bool>(
      selector: (_, controller) => controller.generateWord,
      builder: (_, generateWord, __) {
        if (generateWord == true &&
            AppConstant.verbsList.length != (_tempList.length + 1)) {
          _controllerBottomCenter.play();
        }
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _controllerBottomCenter,
            blastDirection: -pi / 2,
            emissionFrequency: 0.01,
            numberOfParticles: 50,
            maxBlastForce: 80,
            minBlastForce: 40,
            gravity: _gravity,
            blastDirectionality: BlastDirectionality.explosive,
          ),
        );
      },
    );
  }

  Future<bool> _showWarningDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Exit Game?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your progress will be lost!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: ApplicationUtil.getBoxDecorationTwo(context),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: ApplicationUtil.getBoxDecorationOne(context),
                          child: const Center(
                            child: Text(
                              'Exit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }
}
