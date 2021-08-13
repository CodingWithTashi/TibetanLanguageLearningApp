import 'package:flutter/material.dart';

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

  static getAudioAssetPath({required String audioName}) {
    return 'assets/audio/$audioName.mp3';
  }
}
