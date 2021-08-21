import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/model/word.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class UseCaseItemList extends StatefulWidget {
  static const routeName = "use-case-detail-list";
  final UseCaseType type;
  const UseCaseItemList({Key? key, required this.type}) : super(key: key);

  @override
  _UseCaseItemListState createState() => _UseCaseItemListState();
}

class _UseCaseItemListState extends State<UseCaseItemList> {
  late List<Word> wordList;
  @override
  void initState() {
    wordList = AppConstant.getWordList(widget.type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [_getBackgroundImage(), _getAnimatedAlphabetListWidget()],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  _getBackgroundImage() => Hero(
        tag: 'image',
        child: Container(
          child: Image.asset(
            'assets/images/tree.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.centerRight,
          ),
        ),
      );
  _getAnimatedAlphabetListWidget() => Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: AnimationLimiter(
            child: Padding(
              padding: EdgeInsets.only(right: 20, left: 20, top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(
                      milliseconds: ApplicationUtil.ANIMATION_DURATION),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: _getWordList(),
                ),
              ),
            ),
          ),
        ),
      );
  _getWordList() {
    List<Widget> widgetList = [];
    wordList.forEach((word) {
      widgetList.add(Column(
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: ApplicationUtil.getBoxDecorationOne(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        word.english,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              word.tibetan,
                              style:
                                  TextStyle(fontSize: 28, color: Colors.white),
                            ),
                          ),
                          Container(
                            child: Text(
                              word.englishSound,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ));
    });
    return widgetList;
  }
}
