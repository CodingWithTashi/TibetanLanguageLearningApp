import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:tibetan_language_learning_app/presentation/game/snake_game/snake_game.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/util/game_model.dart';

import '../../game_bloc/game_bloc.dart';
import '../../util/application_util.dart';
import '../../util/app_theme.dart';
import 'memory_match/memory_match_screen.dart';

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
    return _EnhancedGameCard(
      game: game,
      onTap: () => game.isUnlocked
          ? _navigateToGameScreen(context, game.gameType)
          : _showUnlockRequirements(context, game),
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
            Lottie.asset(
              'assets/json/unlock.json',
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
      case GameType.memoryGame:
        Navigator.pushNamed(context, MemoryMatchGameScreen.routeName);
        break;
    }
  }
}

/// Enhanced game card with modern design and smooth interactions
class _EnhancedGameCard extends StatefulWidget {
  final Game game;
  final VoidCallback onTap;

  const _EnhancedGameCard({
    required this.game,
    required this.onTap,
  });

  @override
  State<_EnhancedGameCard> createState() => _EnhancedGameCardState();
}

class _EnhancedGameCardState extends State<_EnhancedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.animationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceM,
            vertical: AppTheme.spaceS,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.game.isUnlocked
                  ? [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark,
                    ]
                  : [
                      Theme.of(context).primaryColor.withOpacity(0.6),
                      Theme.of(context).primaryColorDark.withOpacity(0.6),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: _isPressed ? AppTheme.shadowSmall : AppTheme.shadowLarge,
          ),
          child: Stack(
            children: [
              // Lottie Animation
              Center(
                child: Opacity(
                  opacity: widget.game.isUnlocked ? 1.0 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceXL),
                    child: Lottie.network(
                      widget.game.gameIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Game info overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceM),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppTheme.radiusL),
                      bottomRight: Radius.circular(AppTheme.radiusL),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.game.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spaceS),
                      _buildLevelBadge(widget.game),
                      if (widget.game.currentScore > 0) ...[
                        const SizedBox(height: AppTheme.spaceS),
                        Text(
                          'Best: ${widget.game.currentScore}',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Lock/Play icon
              Center(
                child: Icon(
                  widget.game.isUnlocked
                      ? Icons.play_circle_fill_rounded
                      : Icons.lock_rounded,
                  color: Colors.white.withOpacity(widget.game.isUnlocked ? 0.9 : 1.0),
                  size: widget.game.isUnlocked ? 60 : 70,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(Game game) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceM,
        vertical: AppTheme.spaceS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Text(
        'Level ${game.level}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
