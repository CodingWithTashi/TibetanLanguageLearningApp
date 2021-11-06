import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet/alphabet_list_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs/verbs_list_page.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  double menuFontSize = 30;
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
        adUnitId: AppConstant.BANNER_AD_LEARN_MENU_UNIT_ID,
        size: AdSize.banner,
        request: AdRequest(),
        listener: listener,
      );
      adWidget = AdWidget(ad: myBanner);
      myBanner.load();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == "bo") {
      menuFontSize = 30;
    } else {
      menuFontSize = 24;
    }
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
            constraints: BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: AnimationLimiter(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: 40,
                      left: 50,
                      top: MediaQuery.of(context).padding.top + 20),
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
          getIt<AlphabetType>().type = AlphabetCategoryType.ALPHABET;

          Navigator.pushNamed(context, AlphabetListPage.routeName);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.thirtyConsonant,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => _navigateToAlphabetDetailPage(AlphabetCategoryType.VOWEL),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.fourVowels,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () =>
            _navigateToAlphabetDetailPage(AlphabetCategoryType.FIVE_PREFIX),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.fivePrefixes,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () =>
            _navigateToAlphabetDetailPage(AlphabetCategoryType.TEN_SUFFIX),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.tenSuffixes,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () =>
            _navigateToAlphabetDetailPage(AlphabetCategoryType.TWO_POSTFIX),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.twoPostFixes,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => _navigateToAlphabetDetailPage(AlphabetCategoryType.RAGO),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.ragoSurmounted,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => _navigateToAlphabetDetailPage(AlphabetCategoryType.LAGO),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.lagoSurmounted,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => _navigateToAlphabetDetailPage(AlphabetCategoryType.SAGO),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.sagoSarmounted,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => _navigateToAlphabetDetailPage(AlphabetCategoryType.YATAK),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.yatakSubJoin,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => _navigateToAlphabetDetailPage(AlphabetCategoryType.RATAK),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.ratakSubJoined,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => _navigateToAlphabetDetailPage(AlphabetCategoryType.LATAK),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          child: Text(
            AppLocalizations.of(context)!.latakSubJoined,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: menuFontSize, color: Colors.white),
          ),
        ),
      ),
      SizedBox(
        height: 20,
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

  _navigateToAlphabetDetailPage(AlphabetCategoryType type) {
    getIt<AlphabetType>().type = type;

    Navigator.pushNamed(context, AlphabetListPage.routeName);
  }
}
