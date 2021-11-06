import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/presentation/draw_page.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class PracticeDetailPage extends StatefulWidget {
  static const routeName = "/practice-detail-page";
  final Alphabet alphabet;
  const PracticeDetailPage({Key? key, required this.alphabet})
      : super(key: key);

  @override
  _PracticeDetailPageState createState() => _PracticeDetailPageState();
}

class _PracticeDetailPageState extends State<PracticeDetailPage> {
  var controller;
  var selectedPageIndex = 0;
  var pageView;
  double screenHeight = 0.0;

  List<Alphabet> alphabetList =
      AppConstant.getAlphabetList(getIt<AlphabetType>().type);
  @override
  void initState() {
    selectedPageIndex = alphabetList.indexOf(widget.alphabet);
    controller = PageController(
      initialPage: selectedPageIndex,
    );
    initPageView();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Container(
                    height: screenHeight / 3,
                    child: pageView,
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    height: screenHeight / 2 + 10,
                    decoration: ApplicationUtil.getBoxDecorationOne(context),
                    child: DrawingPage(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  void initPageView() {
    pageView = PageView.builder(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: alphabetList.length,
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Hero(
          tag: alphabetList[index],
          //center and scrollview is for hero animation
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    decoration: ApplicationUtil.getBoxDecorationOne(context),
                    child: Text(
                      alphabetList[index].alphabetName,
                      style: TextStyle(fontSize: 80, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onPageChanged: (index) => setState(() => selectedPageIndex = index),
    );
  }
}
