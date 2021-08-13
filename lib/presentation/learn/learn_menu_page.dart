import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet_list_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

class LearnMenuPage extends StatefulWidget {
  static const routeName = "/learn-menu-page";
  const LearnMenuPage({Key? key}) : super(key: key);

  @override
  _LearnMenuPageState createState() => _LearnMenuPageState();
}

class _LearnMenuPageState extends State<LearnMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Hero(
            tag: 'image',
            child: Container(
              child: Image.asset(
                'assets/images/tree.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20, right: 40),
            child: SingleChildScrollView(
              child: AnimationLimiter(
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
                    children: _getWidgetList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  List<Widget> _getWidgetList() {
    List<Widget> widgetList = [
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, AlphabetListPage.routeName);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            'Learn Alphabet',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        decoration: ApplicationUtil.getBoxDecorationOne(context),
        child: Text(
          'Learn Word',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: ApplicationUtil.getBoxDecorationOne(context),
        child: Text(
          'Learn Sentence',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        decoration: ApplicationUtil.getBoxDecorationOne(context),
        child: Text(
          'Go back',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    ];
    return widgetList;
  }
}
