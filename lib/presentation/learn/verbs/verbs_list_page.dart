import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs/verb_detail_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

import '../../../util/route_generator.dart';

class VerbListPage extends StatefulWidget {
  static const routeName = "/verbs-list";
  final UseCaseType type;
  const VerbListPage({Key? key, required this.type}) : super(key: key);

  @override
  _VerbListPageState createState() => _VerbListPageState();
}

class _VerbListPageState extends State<VerbListPage> {
  List<Verb> itemList = [];
  @override
  void initState() {
    itemList = AppConstant.gridItemList(widget.type);

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
            constraints: BoxConstraints(maxWidth: 500),
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
                crossAxisCount: 2,
                children: List.generate(
                  itemList.length,
                  (int index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(
                          milliseconds: ApplicationUtil.ANIMATION_DURATION),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: _getGridViewItem(itemList[index]),
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

  _getGridViewItem(Verb verb) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, VerbDetailPage.routeName, arguments: RouteParam(type: widget.type,verb: verb));
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
                    ApplicationUtil.getImagePath(widget.type,verb.fileName),
                    height: 40,
                    width: 40,
                  ),
                ),
                Expanded(
                  child: Text(
                    verb.word,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
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
