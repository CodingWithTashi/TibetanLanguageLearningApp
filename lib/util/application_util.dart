import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationUtil {
  static const ANIMATION_DURATION = 500;

  static getBoxDecorationOne(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Theme.of(context).primaryColorLight.withOpacity(0.3),
            offset: Offset(5, 5),
            spreadRadius: 3,
            blurRadius: 20),
        BoxShadow(
            color: Colors.black,
            offset: Offset(-5, -3),
            spreadRadius: -4,
            blurRadius: 15),
      ],
    );
  }

  static getBoxDecorationTwo(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Colors.black,
            offset: Offset(5, 3),
            spreadRadius: 4,
            blurRadius: 15),
        BoxShadow(
            color: Theme.of(context).primaryColorLight.withOpacity(0.3),
            offset: Offset(-5, -5),
            spreadRadius: -3,
            blurRadius: 20),
      ],
    );
  }

  static getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Container(
          padding: EdgeInsets.only(left: 8), child: Icon(Icons.arrow_back_ios)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  static Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static getAudioAssetPath({required pathName, required String audioName}) {
    return '$pathName$audioName.mp3';
  }

  static getImagePath(String verb) {
    return 'assets/images/' + verb + ".png";
  }

  static Future<void> launchInBrowser(url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static void showAboutUs(BuildContext context) {
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
                    launchEmail(AppConstant.EMAIL, AppConstant.SUBJECT);
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

  static void launchEmail(email, sub) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: '$email',
      query: 'subject=$sub',
    );
    if (await canLaunch(params.toString())) {
      await launch(params.toString());
    } else {
      throw 'Could not launch $params';
    }
  }
}
