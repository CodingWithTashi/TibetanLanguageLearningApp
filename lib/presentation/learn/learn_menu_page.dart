import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet_list_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs_list_page.dart';
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
            'ཀ་མད་གསུམ་བཅུ།',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => Navigator.pushNamed(context, VerbListPage.routeName),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            'མིང་ཚིག།',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "དར་རྒྱས་གཏོང་བཞིན་ཡོད།",
                style: TextStyle(fontFamily: 'jomolhari'),
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            'ཚིག་གྲུབ།',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: ApplicationUtil.getBoxDecorationOne(context),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    ];
    return widgetList;
  }
}
