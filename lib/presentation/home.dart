import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_cases_menu.dart';
import 'package:tibetan_language_learning_app/presentation/widget/language_widget.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double menuFontSize = 22;
  double _buttonOpacity = 0;
  bool isExtended = false;
  late BannerAd myBanner;
  late RewardedAd myRewarded;
  late BannerAdListener listener;
  late AdWidget adWidget;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      _buttonOpacity = 1;
      setState(() {});
    });
    if (!kIsWeb) {
      _loadRewardedAd();
      initBannerAds();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == "bo") {
      menuFontSize = 22;
    } else {
      menuFontSize = 20;
    }
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _getBackgroundImage(),
          _getButtons(),
          _getBottomSheetButton(),
          _topBannerAds(),
          _languageSwitch(),
        ],
      ),
      //floatingActionButton: _getHomeFab(),
    );
  }

  _getButtons() => Positioned(
        bottom: 90,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getLearnButtons(),
              SizedBox(
                height: 20,
              ),
              _getPracticeButtons(),
              SizedBox(
                height: 20,
              ),
              _useCasesButtons(),
            ],
          ),
        ),
      );

  _getLearnButtons() => InkWell(
        onTap: () {
          Navigator.pushNamed(context, LearnMenuPage.routeName);
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: ApplicationUtil.ANIMATION_DURATION),
          opacity: _buttonOpacity,
          child: Container(
            width: 200,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Text(
              AppLocalizations.of(context)!.learnLangauge,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: menuFontSize, color: Colors.white),
            ),
          ),
        ),
      );

  _getPracticeButtons() => InkWell(
        onTap: () {
          Navigator.pushNamed(context, PracticeMenuPage.routeName);
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: ApplicationUtil.ANIMATION_DURATION),
          opacity: _buttonOpacity,
          child: Container(
            width: 200,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Text(
              AppLocalizations.of(context)!.practiceLanguage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: menuFontSize, color: Colors.white),
            ),
          ),
        ),
      );

  _getHomeFab() => FloatingActionButton.extended(
        onPressed: () {
          //isExtended = !isExtended;
          if (!isExtended) {
            playVideoAds();
          }
          playVideoAds();
          //setState(() {});
        },
        label: AnimatedSwitcher(
          duration: Duration(milliseconds: ApplicationUtil.ANIMATION_DURATION),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(
            opacity: animation,
            child: SizeTransition(
              child: child,
              sizeFactor: animation,
              axis: Axis.horizontal,
            ),
          ),
          child: isExtended
              ? Icon(Icons.play_arrow)
              : Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.play_arrow),
                    ),
                    Text(
                      AppLocalizations.of(context)!.playGame,
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
        ),
      );

  _getBackgroundImage() => Hero(
        tag: 'image',
        child: Container(
          child: Image.asset(
            'assets/images/tree.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.centerLeft,
          ),
        ),
      );

  _getBottomSheetButton() => Positioned(
        bottom: 10,
        child: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dy < 0) {
                ApplicationUtil.showAboutUs(context);
              }
            },
            onTap: () {
              ApplicationUtil.showAboutUs(context);
            },
            child: RotatedBox(
              quarterTurns: -1,
              child: Icon(
                Icons.arrow_forward_ios_outlined,
                size: 40,
                color: Theme.of(context).primaryColorLight,
              ),
            )),
      );

  _topBannerAds() => Positioned(
        top: MediaQuery.of(context).padding.top + 70,
        child: !kIsWeb
            ? Container(
                alignment: Alignment.center,
                child: adWidget,
                width: myBanner.size.width.toDouble(),
                height: myBanner.size.height.toDouble(),
              )
            : Container(),
      );

  _useCasesButtons() => InkWell(
        onTap: () {
          Navigator.pushNamed(context, UseCaseMenuPage.routeName);
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: ApplicationUtil.ANIMATION_DURATION),
          opacity: _buttonOpacity,
          child: Container(
            width: 200,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Text(
              AppLocalizations.of(context)!.useCases,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: menuFontSize, color: Colors.white),
            ),
          ),
        ),
      );

  _languageSwitch() => Positioned(
        top: MediaQuery.of(context).padding.top,
        right: 20,
        child: LanguageWidget(),
      );

  void playVideoAds() {
    myRewarded.show(onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {
      print('user earned');
      Navigator.pushNamed(context, LearnMenuPage.routeName);
    }).catchError((e) => print("error in showing ad: ${e.toString()}"));
    myRewarded.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            this.myRewarded = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _loadRewardedAd();
          },
        ));
  }

  void initBannerAds() {
    listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    );
    myBanner = BannerAd(
      adUnitId: AppConstant.BANNER_AD_HOME_UNIT_ID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    if (!kIsWeb) {
      adWidget = AdWidget(ad: myBanner);
      myBanner.load();
    }
  }
}
