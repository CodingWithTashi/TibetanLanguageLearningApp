import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drag.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drop.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/fly_in_animation.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

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
      child: Scaffold(
        body: Selector<SpellingBeeProvider, bool>(
          selector: (_, controller) => controller.generateWord,
          builder: (_, generate, __) {
            if (generate) {
              if (_tempList.isNotEmpty) {
                _generateWord();
              }
            }
            return Stack(
              children: [
                _getBackgroundImage(),
                Column(
                  children: [
                    SizedBox(
                      height: kToolbarHeight,
                    ),
                    _getHeader(),
                    _getDropContent(),
                    _getImageForWord(),
                    _getDragContent(),
                    _getProgressIndicator(),
                  ],
                ),
                _getFinishCelebAnimation(),
                _getCelebAnimationOnCorrectAnswer(),
              ],
            );
          },
        ),
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

  _getBackgroundImage() {
    return Image.asset(
      'assets/images/tree.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.centerLeft,
    );
  }

  _getHeader() => Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          width: double.infinity,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.spellingBeeContest,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  shadows: [
                    Shadow(
                        offset: Offset(2, 2),
                        color: Colors.black38,
                        blurRadius: 10),
                    Shadow(
                        offset: Offset(-2, -2),
                        color: Colors.white.withOpacity(0.35),
                        blurRadius: 10)
                  ],
                  color: Colors.grey.shade300),
            ),
          ),
        ),
      );

  _getDropContent() => Expanded(
        flex: 3,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: selectedVerb.characterList
                .map((e) =>
                    FlyInAnimation(animate: true, child: Drop(letter: e)))
                .toList(),
          ),
        ),
      );

  _getImageForWord() => Expanded(
        flex: 3,
        child: Image.asset(
          ApplicationUtil.getImagePath(selectedVerb.fileName),
        ),
      );

  _getDragContent() => Expanded(
        flex: 3,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: shuffledVerb.characterList
                .map((e) => FlyInAnimation(
                      animate: true,
                      child: Drag(
                        letter: e,
                      ),
                    ))
                .toList(),
          ),
        ),
      );

  _getProgressIndicator() => Expanded(
        flex: 1,
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: LiquidLinearProgressIndicator(
                  value: _getValue(), // Defaults to 0.5.
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).primaryColor,
                  ), // Defaults to the current Theme's accentColor.
                  backgroundColor: Colors
                      .white, // Defaults to the current Theme's backgroundColor.
                  borderColor: Theme.of(context).primaryColor,
                  borderWidth: 4.0,
                  borderRadius: 5,

                  direction: Axis
                      .horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                  center: Text(
                    "${AppConstant.getTibetanNumberByNumber(number: (AppConstant.verbsList.length - (_tempList.length + 1)).toString())} / ${AppConstant.getTibetanNumberByNumber(number: AppConstant.verbsList.length.toString())}",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  _getValue() =>
      (AppConstant.verbsList.length - (_tempList.length + 1)) /
      AppConstant.verbsList.length;

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

  _showWarningDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: Text('Do you really want to exit?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              )
            ],
          );
        });
  }
}
