import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drag.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drop.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/fly_in_animation.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  @override
  void initState() {
    //_generateWord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  borderRadius: 1.0,

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
}
