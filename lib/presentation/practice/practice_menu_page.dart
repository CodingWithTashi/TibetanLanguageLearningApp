import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_detail_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class PracticeMenuPage extends StatefulWidget {
  static const routeName = "/practice-menu-page";
  const PracticeMenuPage({Key? key}) : super(key: key);

  @override
  _PracticeMenuPageState createState() => _PracticeMenuPageState();
}

class _PracticeMenuPageState extends State<PracticeMenuPage> {
  List<Alphabet> alphabetList = [];
  @override
  void initState() {
    alphabetList = AppConstant.alphabetList;
    super.initState();
  }

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
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: AnimationLimiter(
              child: GridView.count(
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                crossAxisSpacing: 30,
                mainAxisSpacing: 10,
                crossAxisCount: kIsWeb ? 3 : 2,
                children: List.generate(
                  alphabetList.length,
                  (int index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(
                          milliseconds: ApplicationUtil.ANIMATION_DURATION),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: _getGridViewItem(alphabetList[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  _getGridViewItem(Alphabet alphabet) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, PracticeDetailPage.routeName,
            arguments: alphabet);
      },
      child: Hero(
        flightShuttleBuilder: ApplicationUtil.flightShuttleBuilder,
        tag: alphabet,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          width: 50,
          height: 50,
          child: Center(
            child: Text(
              alphabet.alphabetName,
              style: TextStyle(fontSize: 70, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
