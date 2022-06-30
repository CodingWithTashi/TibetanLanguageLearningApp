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
  static List<Game> gameList() {
    return [
      Game(
          name: 'Spelling Bee',
          description: 'Spelling Bee',
          gameIcon: 'https://assets6.lottiefiles.com/packages/lf20_yU09RI.json',
          gameType: GameType.spellingBeeGame),
      Game(
          name: 'Snake Game',
          description: 'Snake Game',
          gameIcon:
              'https://assets6.lottiefiles.com/packages/lf20_qoo3cyxi.json',
          gameType: GameType.snakeGame),
    ];
  }
}

enum GameType { snakeGame, spellingBeeGame }
