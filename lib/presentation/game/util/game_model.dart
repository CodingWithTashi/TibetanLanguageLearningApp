import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Game {
  String _name;
  String _description;
  String _gameIcon;
  GameType _gameType;

  Game({
    required String name,
    required String description,
    required String gameIcon,
    required GameType gameType,
  })  : _name = name,
        _description = description,
        _gameIcon = gameIcon,
        _gameType = gameType;

  GameType get gameType => _gameType;

  String get gameIcon => _gameIcon;

  String get description => _description;

  String get name => _name;
  static List<Game> gameList(BuildContext context) {
    return [
      Game(
          name: AppLocalizations.of(context)!.spellingBee,
          description: AppLocalizations.of(context)!.spellingBee,
          gameIcon: 'https://assets6.lottiefiles.com/packages/lf20_yU09RI.json',
          gameType: GameType.spellingBeeGame),
      Game(
          name: AppLocalizations.of(context)!.snakeGame,
          description: AppLocalizations.of(context)!.snakeGame,
          gameIcon:
              'https://assets6.lottiefiles.com/packages/lf20_qoo3cyxi.json',
          gameType: GameType.snakeGame),
    ];
  }
}

enum GameType { snakeGame, spellingBeeGame }
