
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_detail_page.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class PracticeMenuPage extends StatefulWidget {
  static const routeName = "/practice-menu-page";
  const PracticeMenuPage({Key? key}) : super(key: key);

  @override
  _PracticeMenuPageState createState() => _PracticeMenuPageState();
}

class _PracticeMenuPageState extends State<PracticeMenuPage> {
/*  late BannerAd myBanner;
  late BannerAdListener listener;
  late AdWidget adWidget;*/
  double menuFontSize = 30;
  List<Alphabet> alphabetList = [];
  @override
  void initState() {
    if (!kIsWeb) {
    /*  listener = BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
        onAdImpression: (Ad ad) => print('Ad impression.'),
      );
      final adUnitId = kReleaseMode
          ? Platform.isAndroid
              ? AppConstant.BANNER_AD_PRACTICE_MENU_UNIT_ID
              : AppConstant.BANNER_AD_PRACTICE_MENU_UNIT_ID_IOS
          : AppConstant.TEST_UNIT_ID;
      myBanner = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: AdRequest(),
        listener: listener,
      );
      adWidget = AdWidget(ad: myBanner);
      myBanner.load();*/
    }
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
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              _getBannerAds(),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  constraints: BoxConstraints(maxWidth: 500),
                  child: GridView.count(
                    physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    children: List.generate(
                      alphabetList.length,
                      (int index) => _getGridViewItem(alphabetList[index]),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  _getBannerAds() => !kIsWeb
      ? Container(
          alignment: Alignment.center,
         /* child: adWidget,
          width: myBanner.size.width.toDouble(),
          height: myBanner.size.height.toDouble(),*/
        )
      : Container();
}
