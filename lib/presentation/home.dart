import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/presentation/game/game_home_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_cases_menu.dart';
import 'package:tibetan_language_learning_app/presentation/widget/language_widget.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:tibetan_language_learning_app/util/app_theme.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  double menuFontSize = 22;
  late BannerAd myBanner;
  late BannerAdListener listener;
  late AdWidget adWidget;
  late AnimationController _animationController;
  late List<Animation<double>> _buttonAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for each button
    _buttonAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (index * 0.15),
            0.5 + (index * 0.15),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _slideAnimations = List.generate(
      4,
      (index) => Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (index * 0.15),
            0.5 + (index * 0.15),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();

    if (!kIsWeb) {
      initBannerAds();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (!kIsWeb) {
      myBanner.dispose();
    }
    super.dispose();
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
          _topBannerAds(),
          _languageSwitch(),
          _getBottomSheetButton(),
        ],
      ),
      //floatingActionButton: _getHomeFab(),
    );
  }

  _getButtons() => Positioned(
        bottom: 90,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedButton(
                index: 0,
                label: AppLocalizations.of(context)!.learnLangauge,
                icon: Icons.school_rounded,
                onTap: () => Navigator.pushNamed(context, LearnMenuPage.routeName),
              ),
              const SizedBox(height: AppTheme.spaceM),
              _buildAnimatedButton(
                index: 1,
                label: AppLocalizations.of(context)!.practiceLanguage,
                icon: Icons.edit_note_rounded,
                onTap: () => Navigator.pushNamed(context, PracticeMenuPage.routeName),
              ),
              const SizedBox(height: AppTheme.spaceM),
              _buildAnimatedButton(
                index: 2,
                label: AppLocalizations.of(context)!.useCases,
                icon: Icons.category_rounded,
                onTap: () => Navigator.pushNamed(context, UseCaseMenuPage.routeName),
              ),
              const SizedBox(height: AppTheme.spaceM),
              _buildAnimatedButton(
                index: 3,
                label: AppLocalizations.of(context)!.playGame,
                icon: Icons.videogame_asset_rounded,
                onTap: () => Navigator.pushNamed(context, GameHomePage.routeName),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentDark,
                    AppTheme.accentColor,
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAnimatedButton({
    required int index,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Gradient? gradient,
  }) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _buttonAnimations[index],
        child: _EnhancedMenuButton(
          label: label,
          icon: icon,
          onTap: onTap,
          fontSize: menuFontSize,
          gradient: gradient,
        ),
      ),
    );
  }


  Widget _getBackgroundImage() => Hero(
        tag: 'image',
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.darken,
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
        bottom: 20,
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
                size: 30,
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


  Widget _languageSwitch() => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        right: 20,
        child: FadeTransition(
          opacity: _buttonAnimations[0],
          child: const LanguageWidget(),
        ),
      );

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
    final adUnitId = kReleaseMode
        ? Platform.isAndroid
            ? AppConstant.BANNER_AD_HOME_UNIT_ID
            : AppConstant.BANNER_AD_HOME_UNIT_ID_IOS
        : AppConstant.TEST_UNIT_ID;
    myBanner = BannerAd(
      adUnitId: adUnitId,
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

/// Enhanced menu button with modern design and smooth animations
class _EnhancedMenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double fontSize;
  final Gradient? gradient;

  const _EnhancedMenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.fontSize = 20,
    this.gradient,
  });

  @override
  State<_EnhancedMenuButton> createState() => _EnhancedMenuButtonState();
}

class _EnhancedMenuButtonState extends State<_EnhancedMenuButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppTheme.animationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceL,
            vertical: AppTheme.spaceM,
          ),
          decoration: BoxDecoration(
            gradient: widget.gradient ??
                LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColorDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: _isPressed ? AppTheme.shadowSmall : AppTheme.shadowMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
