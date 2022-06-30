import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CarouselSlider(
                items: _getGameWidgetList(),
                options: CarouselOptions(
                  scrollPhysics: BouncingScrollPhysics(),
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  aspectRatio: orientation == Orientation.portrait ? 1.8 : 3,
                  viewportFraction:
                      orientation == Orientation.portrait ? 0.7 : 0.5,
                ),
                carouselController: _controller,
              )
            ],
          ),
        );
      }),
    );
  }

  _getGameWidgetList() => Game.gameList()
      .map((item) => Container(
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            margin: EdgeInsets.all(20.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Lottie.network(item.gameIcon),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Text(
                            'No. ${item.name} game',
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
                Center(
                  child: IconButton(
                    onPressed: () {
                      _navigateToGameScreen(gameType: item.gameType);
                    },
                    icon: Icon(
                      Icons.play_circle_fill_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                )
              ],
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
