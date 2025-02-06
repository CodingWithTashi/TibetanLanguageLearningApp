import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:tibetan_language_learning_app/presentation/game/snake_game/snake_game.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/util/game_model.dart';

import '../../game_bloc/game_bloc.dart';
import '../../util/application_util.dart';

class GameHomePage extends StatelessWidget {
  static const routeName = 'game-home';
  double height = 0.0;
  double width = 0.0;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarouselSlider(
                    items: state.games
                        .map((game) => _buildGameCard(context, game))
                        .toList(),
                    options: CarouselOptions(
                      scrollPhysics: BouncingScrollPhysics(),
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      height: height * 0.35,
                      viewportFraction: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameCard(BuildContext context, Game game) {
    return InkResponse(
      onTap: () => game.isUnlocked
          ? _navigateToGameScreen(context, game.gameType)
          : _showUnlockRequirements(context, game),
      child: Opacity(
        opacity: game.isUnlocked ? 1.0 : 0.7,
        child: Container(
          decoration: ApplicationUtil.getBoxDecorationOne(context),
          margin: EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Opacity(
                opacity: game.isUnlocked ? 1.0 : 0.6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Lottie.network(
                        game.gameIcon,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: Stack(
                        children: <Widget>[],
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
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
                        child: Column(
                          children: [
                            Text(
                              '${game.name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            _buildLevelBadge(game),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  top: 0,
                  child: game.isUnlocked
                      ? Icon(
                          Icons.play_circle_fill_outlined,
                          color: Colors.white,
                          size: 40,
                        )
                      : Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 50,
                        ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(Game game) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        'Level ${game.level}',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameContent(Game game) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Lottie.network(
        game.gameIcon,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildGameInfo(Game game) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            game.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            game.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          if (game.currentScore > 0) ...[
            SizedBox(height: 8),
            Text(
              'Best Score: ${game.currentScore}',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUnlockRequirements(BuildContext context, Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Level ${game.level} Locked'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_ybeqpj5r.json',
              height: 100,
              repeat: true,
            ),
            SizedBox(height: 16),
            Text(
              'Score ${game.requiredScoreInPreviousLevelToUnlock} points in Level ${game.level - 1} to unlock ${game.name}!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _navigateToGameScreen(BuildContext context, GameType gameType) {
    print("GameType: $gameType");
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
