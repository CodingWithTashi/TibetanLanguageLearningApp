import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs/verb_detail_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class VerbListPage extends StatefulWidget {
  static const routeName = "/verbs-list";

  @override
  _VerbListPageState createState() => _VerbListPageState();
}

class _VerbListPageState extends State<VerbListPage> {
  List<Verb> verbsList = [];
  @override
  void initState() {
    verbsList = AppConstant.verbsList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          // Keeps the Stack full-screen; the image is in ParallaxBackground.
          const SizedBox.expand(),
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: GridView.count(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              crossAxisSpacing: 30,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: List.generate(
                verbsList.length,
                (int index) => _getGridViewItem(verbsList[index]),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  _getGridViewItem(Verb verb) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, VerbDetailPage.routeName, arguments: verb);
      },
      child: Hero(
        flightShuttleBuilder: ApplicationUtil.flightShuttleBuilder,
        tag: verb.word,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          width: 50,
          height: 50,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    ApplicationUtil.getImagePath(verb.fileName),
                    height: 40,
                    width: 40,
                  ),
                ),
                Expanded(
                  child: Text(
                    verb.word,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
