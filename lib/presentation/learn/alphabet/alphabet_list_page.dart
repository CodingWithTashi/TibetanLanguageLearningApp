import 'package:material_ui/material_ui.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet/alphabet_detail_page.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class AlphabetListPage extends StatefulWidget {
  static const routeName = "/alphabet-list-page";
  const AlphabetListPage({
    Key? key,
  }) : super(key: key);

  @override
  _AlphabetListPageState createState() => _AlphabetListPageState();
}

class _AlphabetListPageState extends State<AlphabetListPage> {
  late List<Alphabet> alphabetList;
  @override
  void initState() {
    alphabetList = AppConstant.getAlphabetList(getIt<AlphabetType>().type);
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
          _getAnimatedAlphabetListWidget(),
        ],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  _getAnimatedAlphabetListWidget() => Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Padding(
            padding: EdgeInsets.only(right: 40, left: 50, top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _getAlphabetList(),
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
              tag: alphabet.alphabetName,
              flightShuttleBuilder: ApplicationUtil.flightShuttleBuilder,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                decoration: ApplicationUtil.getBoxDecorationOne(context),
                child: Text(
                  alphabet.alphabetName,
                  style: TextStyle(fontSize: 60, color: Colors.white),
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
