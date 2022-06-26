import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  late BannerAd myBanner;
  late BannerAdListener listener;
  late AdWidget adWidget;
  double menuFontSize = 30;
  List<Alphabet> alphabetList = [];
  @override
  void initState() {
    if (!kIsWeb) {
      listener = BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
        onAdImpression: (Ad ad) => print('Ad impression.'),
      );
      myBanner = BannerAd(
        adUnitId: AppConstant.BANNER_AD_PRACTICE_MENU_UNIT_ID,
        size: AdSize.banner,
        request: AdRequest(),
        listener: listener,
      );
      adWidget = AdWidget(ad: myBanner);
      myBanner.load();
    }
    alphabetList = AppConstant.getAlphabetList(getIt<AlphabetType>().type);
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
          ),
          _getBannerAds()
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

  _getBannerAds() => !kIsWeb
      ? Positioned.fill(
          bottom: 80,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.center,
              child: adWidget,
              width: myBanner.size.width.toDouble(),
              height: myBanner.size.height.toDouble(),
            ),
          ),
        )
      : Container();
}
