import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs/verbs_list_page.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_case_item_list.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class UseCaseMenuPage extends StatefulWidget {
  static const routeName = "/use-cases-menu";
  const UseCaseMenuPage({Key? key}) : super(key: key);

  @override
  _UseCaseMenuPageState createState() => _UseCaseMenuPageState();
}

class _UseCaseMenuPageState extends State<UseCaseMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(
                        milliseconds: ApplicationUtil.ANIMATION_DURATION),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: -50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: _getWidgetList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  List<Widget> _getWidgetList() {
    List<Widget> widgetList = [
      SizedBox(
        height: MediaQuery.of(context).padding.top + 20,
      ),
      InkWell(
          onTap: () => Navigator.pushNamed(context, VerbListPage.routeName),
          child: Container(
            width: 220,
            padding: EdgeInsets.symmetric(vertical: 30),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/apple.png',
                  width: 80,
                  height: 80,
                ),
                Text(
                  'མིང་ཚིག།',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          )),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, UseCaseItemList.routeName,
              arguments: UseCaseType.PRONOUN);
        },
        child: Container(
          width: 220,
          padding: EdgeInsets.symmetric(vertical: 30),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Column(
            children: [
              Image.asset(
                'assets/others/pronoun.png',
                width: 80,
                height: 80,
              ),
              Text(
                //'Pronouns',
                'མིང་ཚབ།',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, UseCaseItemList.routeName,
              arguments: UseCaseType.GREETING);
        },
        child: Container(
          width: 220,
          padding: EdgeInsets.symmetric(vertical: 30),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Column(
            children: [
              Image.asset(
                'assets/others/greeting.png',
                width: 80,
                height: 80,
              ),
              Text(
                //'Greetings',
                'འཚམས་འདྲི།',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, UseCaseItemList.routeName,
              arguments: UseCaseType.COLORS);
        },
        child: Container(
          width: 220,
          padding: EdgeInsets.symmetric(vertical: 30),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Column(
            children: [
              Image.asset(
                'assets/others/color.png',
                width: 80,
                height: 80,
              ),
              Text(
                //'Colors',
                'ཚོན་མདོག།',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, UseCaseItemList.routeName,
              arguments: UseCaseType.FAMILY);
        },
        child: Container(
          width: 220,
          padding: EdgeInsets.symmetric(vertical: 30),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Column(
            children: [
              Image.asset(
                'assets/others/family.png',
                width: 80,
                height: 80,
              ),
              Text(
                //'Family',
                'ནང་ཚང།',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, UseCaseItemList.routeName,
              arguments: UseCaseType.NUMBERS);
        },
        child: Container(
          width: 220,
          padding: EdgeInsets.symmetric(vertical: 30),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Column(
            children: [
              Image.asset(
                'assets/others/number.png',
                width: 80,
                height: 80,
              ),
              Text(
                //'Numbers',
                'ཨང་ཀི།',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
    ];
    return widgetList;
  }
}
