import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _buttonOpacity = 0;
  bool isExtended = false;
  late BannerAd myBanner;
  late BannerAdListener listener;
  late AdWidget adWidget;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      _buttonOpacity = 1;
      setState(() {});
    });

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _getBackgroundImage(),
            _getButtons(),
            _getBottomSheetButton(),
            _topBannerAds(),
          ],
        ),
        floatingActionButton: _getHomeFab());
  }

  _getButtons() => Positioned(
        bottom: 100,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getLearnButtons(),
              SizedBox(
                height: 30,
              ),
              _getPracticeButtons(),
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
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Text(
              'སྐད་ཡིག་སྦྱོང།',
              style: TextStyle(fontSize: 22, color: Colors.white),
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
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: Text(
              'སྦྱོང་བརྡར་བྱེད།',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),
      );

  _getHomeFab() => FloatingActionButton.extended(
        onPressed: () {
          isExtended = !isExtended;
          setState(() {});
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
                      "རྩེད་མོ་རྩེ།",
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
                showAboutUs();
              }
            },
            onTap: () {
              showAboutUs();
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
  void showAboutUs() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(10),
                    child: DefaultTextStyle(
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).primaryColor),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Made With ❤ by KharagEdition',
                            speed: Duration(milliseconds: 300),
                            textStyle: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'jomolhari',
                            ),
                            colors: [
                              Theme.of(context).primaryColor,
                              Colors.blue,
                              Colors.red,
                              Colors.black,
                            ],
                          ),
                        ],
                        isRepeatingAnimation: false,
                        onTap: () {},
                      ),
                    )
                    /*Text(
                    'Made With ❤️ by KharagEdition',
                    style: TextStyle(fontSize: 18),
                  ),*/
                    ),
                ListTile(
                  leading: new Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: new Text(AppConstant.CONTACT_US),
                  onTap: () {
                    _launchEmail(AppConstant.EMAIL, AppConstant.SUBJECT);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: new Icon(
                    Icons.share,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: new Text('Share'),
                  onTap: () {
                    Share.share(AppConstant.SHARE_URL,
                        subject:
                            'Check out this Tibetan Language Learning  App.');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: new Icon(
                    Icons.star_rate,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: new Text('Rate Us'),
                  onTap: () {
                    ApplicationUtil.launchInBrowser(AppConstant.APP_URL);

                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: new Icon(
                    Icons.apps,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: new Text('More App from Kharag'),
                  onTap: () {
                    ApplicationUtil.launchInBrowser(AppConstant.MORE_URL);

                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: new Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: new Text('Exit'),
                  onTap: () {
                    SystemNavigator.pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  void _launchEmail(email, sub) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: '$email',
      query: 'subject=$sub', //add subject and body here
    );
    if (await canLaunch(params.toString())) {
      await launch(params.toString());
    } else {
      throw 'Could not launch $params';
    }
  }

  _topBannerAds() => !kIsWeb
      ? Positioned(
          top: 40,
          child: Container(
            alignment: Alignment.center,
            child: adWidget,
            width: myBanner.size.width.toDouble(),
            height: myBanner.size.height.toDouble(),
          ),
        )
      : Container();
}
