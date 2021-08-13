import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet_detail_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class AlphabetListPage extends StatefulWidget {
  static const routeName = "/alphabet-list-page";
  const AlphabetListPage({Key? key}) : super(key: key);

  @override
  _AlphabetListPageState createState() => _AlphabetListPageState();
}

class _AlphabetListPageState extends State<AlphabetListPage> {
  late List<String> alphabetList;
  @override
  void initState() {
    alphabetList = AppConstant.alphabetList;
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
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: AnimationLimiter(
            child: Padding(
              padding: EdgeInsets.only(right: 40, left: 50, top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(
                      milliseconds: ApplicationUtil.ANIMATION_DURATION),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: _getAlphabetList(),
                ),
              ),
            ),
          ),
        ),
      );
  _getAlphabetList() {
    List<Widget> widgetList = [];
    alphabetList.forEach((alphabet) {
      widgetList.add(Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AlphabetDetailPage.routeName,
                  arguments: alphabet);
            },
            child: Hero(
              tag: alphabet,
              flightShuttleBuilder: ApplicationUtil.flightShuttleBuilder,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                decoration: ApplicationUtil.getBoxDecorationOne(context),
                child: Text(
                  alphabet,
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
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
