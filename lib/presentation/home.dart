import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _buttonOpacity = 0;
  bool isExtended = false;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      _buttonOpacity = 1;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _getBackgroundImage(),
            _getButtons(),
          ],
        ),
        floatingActionButton: _getHomeFab());
  }

  _getButtons() => Positioned(
        bottom: 100,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getLearnButtons(),
              SizedBox(
                height: 30,
              ),
              _getPracticeButtons(),
            ],
          ),
        ),
      );

  _getLearnButtons() => InkWell(
        onTap: () {
          Navigator.pushNamed(context, LearnMenuPage.routeName);
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: ApplicationUtil.ANIMATION_DURATION),
          opacity: _buttonOpacity,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Text(
              'སྐད་ཡིག་སྦྱོང།',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),
      );

  _getPracticeButtons() => InkWell(
        onTap: () {
          Navigator.pushNamed(context, PracticeMenuPage.routeName);
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: ApplicationUtil.ANIMATION_DURATION),
          opacity: _buttonOpacity,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Text(
              'སྦྱོང་བརྡར་བྱེད།',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),
      );

  _getHomeFab() => FloatingActionButton.extended(
        onPressed: () {
          isExtended = !isExtended;
          setState(() {});
        },
        label: AnimatedSwitcher(
          duration: Duration(milliseconds: ApplicationUtil.ANIMATION_DURATION),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(
            opacity: animation,
            child: SizeTransition(
              child: child,
              sizeFactor: animation,
              axis: Axis.horizontal,
            ),
          ),
          child: isExtended
              ? Icon(Icons.play_arrow)
              : Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.play_arrow),
                    ),
                    Text(
                      "རྩེད་མོ་རྩེ།",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
        ),
      );

  _getBackgroundImage() => Hero(
        tag: 'image',
        child: Container(
          child: Image.asset(
            'assets/images/tree.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.centerLeft,
          ),
        ),
      );
}
