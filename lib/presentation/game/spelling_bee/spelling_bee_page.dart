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

class SpellingBeePage extends StatefulWidget {
  static const routeName = 'spelling-bee';
  const SpellingBeePage({Key? key}) : super(key: key);

  @override
  State<SpellingBeePage> createState() => _SpellingBeePageState();
}

class _SpellingBeePageState extends State<SpellingBeePage> {
  List<Verb> _verbList = AppConstant.verbsList;
  late List<String> _characterList, _dropCharacterList;
  late Verb selectedVerb;
  double total = 10.0;
  double currentValue = 0.0;
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
            if (_verbList.isNotEmpty) {
              _generateWord();
            }
          }
          return Stack(
            children: [
              _getBackgroundImage(),
              Column(
                children: [
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
    final r = Random().nextInt(_verbList.length);
    _characterList = _verbList[r].characterList;
    _dropCharacterList = List.from(_characterList);
    selectedVerb = _verbList[r];
    _verbList.removeAt(r);
    if (_characterList.isNotEmpty) {
      _characterList.shuffle();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<SpellingBeeProvider>(context, listen: false)
          .setUp(total: _characterList.length);
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
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          width: double.infinity,
          height: 80,
          child: Center(
            child: Text(
              'Spelling BEE!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  shadows: [
                    Shadow(
                        offset: Offset(3, 3),
                        color: Colors.black38,
                        blurRadius: 10),
                    Shadow(
                        offset: Offset(-3, -3),
                        color: Colors.white.withOpacity(0.65),
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
            children: _dropCharacterList
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
            children: _characterList
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
        child: Container(
          child: LiquidLinearProgressIndicator(
            value: 0.5, // Defaults to 0.5.
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).primaryColorDark,
            ), // Defaults to the current Theme's accentColor.
            backgroundColor: Colors
                .white, // Defaults to the current Theme's backgroundColor.
            borderColor: Theme.of(context).primaryColor,
            borderWidth: 2.0,
            //borderRadius: 10.0,
            direction: Axis
                .horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
            center: Text("Loading..."),
          ),
        ),
      );
}
