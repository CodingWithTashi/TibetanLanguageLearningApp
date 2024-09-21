import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:tibetan_language_learning_app/presentation/game/snake_game/snake_game.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/util/game_model.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class GameHomePage extends StatefulWidget {
  static const routeName = 'game-home';

  const GameHomePage({Key? key}) : super(key: key);

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  late final CarouselSliderController _controller;

  @override
  initState() {
    super.initState();
    _controller = CarouselSliderController();
    ApplicationUtil.setScreenOrientation(disabledLandscape: true);
  }

  @override
  dispose() {
    super.dispose();
    ApplicationUtil.setScreenOrientation(disabledLandscape: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CarouselSlider(
              items: _getGameWidgetList(),
              options: CarouselOptions(
                scrollPhysics: BouncingScrollPhysics(),
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                aspectRatio: 1.5,
                viewportFraction: 0.7,
              ),
              carouselController: _controller,
            )
          ],
        ),
      ),
    );
  }

  _getGameWidgetList() => Game.gameList()
      .map((item) => InkResponse(
            onTap: () => _navigateToGameScreen(gameType: item.gameType),
            child: Container(
              decoration: ApplicationUtil.getBoxDecorationOne(context),
              margin: EdgeInsets.all(20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.network(
                    item.gameIcon,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_fill_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(80, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        '${item.name}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))
      .toList();

  void _navigateToGameScreen({required GameType gameType}) {
    switch (gameType) {
      case GameType.spellingBeeGame:
        Navigator.pushNamed(context, SpellingBeePage.routeName);
        break;
      case GameType.snakeGame:
        Navigator.pushNamed(context, SnakeGamePage.routeName);
        break;
    }
  }
}

class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    path.lineTo(0.0, size.height / 2 - 4);
    path.relativeArcToPoint(const Offset(0, 30),
        radius: const Radius.circular(10.0), largeArc: true);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height / 2 + 26);
    path.arcToPoint(Offset(size.width, size.height / 2 - 4),
        radius: const Radius.circular(10.0), clockwise: true);
    path.lineTo(size.width, 0);
    path.lineTo(0.0, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
