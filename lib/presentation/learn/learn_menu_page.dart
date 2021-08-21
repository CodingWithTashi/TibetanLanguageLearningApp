import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet/alphabet_list_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs/verbs_list_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class LearnMenuPage extends StatefulWidget {
  static const routeName = "/learn-menu-page";
  const LearnMenuPage({Key? key}) : super(key: key);

  @override
  _LearnMenuPageState createState() => _LearnMenuPageState();
}

class _LearnMenuPageState extends State<LearnMenuPage> {
  late BannerAd myBanner;
  late BannerAdListener listener;
  late AdWidget adWidget;
  @override
  void initState() {
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
      adUnitId: AppConstant.TEST_UNIT_ID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    if (!kIsWeb) {
      adWidget = AdWidget(ad: myBanner);
      myBanner.load();
    }
    super.initState();
  }

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
          ),
          _getBannerAds()
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
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            'ཀ་མད་གསུམ་བཅུ།',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => Navigator.pushNamed(context, VerbListPage.routeName),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            'མིང་ཚིག།',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        decoration: ApplicationUtil.getBoxDecorationOne(context),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    ];
    return widgetList;
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
