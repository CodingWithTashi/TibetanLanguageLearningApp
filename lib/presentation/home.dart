import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/presentation/game/game_home_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/shop/shop_page.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_cases_menu.dart';
import 'package:tibetan_language_learning_app/presentation/widget/language_widget.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double menuFontSize = 22;
  bool isExtended = false;
/*  late BannerAd myBanner;
  late BannerAdListener listener;
  late AdWidget adWidget;*/

  @override
  void initState() {
    if (!kIsWeb) {
      initBannerAds();
    }

    super.initState();
  }

  @override
  void dispose() {
    // myBanner.dispose();
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
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Keeps the Stack full-screen; the image is in ParallaxBackground.
          const SizedBox.expand(),
          _getButtons(),
          _topBannerAds(),
          _languageSwitch(),
          _getBottomSheetButton(),
        ],
      ),
      //floatingActionButton: _getHomeFab(),
    );
  }

  // Four sections as a 2×2 grid of icon tiles, with Shop as a wide bar under
  // them so the learning sections read first. When the screen is too short
  // for that (a phone in landscape), all five go in one row instead.
  Widget _getButtons() {
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    // Badge colors come from the app's green seed color, so they stay in
    // the same family as the tiles and the background.
    final scheme = Theme.of(context).colorScheme;
    const gap = 14.0;
    const bottom = 90.0;

    final learn = _MenuItem(
      label: l10n.learnLangauge,
      icon: Icons.menu_book_rounded,
      badge: scheme.primaryContainer,
      onBadge: scheme.onPrimaryContainer,
      routeName: LearnMenuPage.routeName,
    );
    final practice = _MenuItem(
      label: l10n.practiceLanguage,
      icon: Icons.draw_rounded,
      badge: scheme.tertiaryContainer,
      onBadge: scheme.onTertiaryContainer,
      routeName: PracticeMenuPage.routeName,
    );
    final useCases = _MenuItem(
      label: l10n.useCases,
      icon: Icons.forum_rounded,
      badge: scheme.secondaryContainer,
      onBadge: scheme.onSecondaryContainer,
      routeName: UseCaseMenuPage.routeName,
    );
    final game = _MenuItem(
      label: l10n.playGame,
      icon: Icons.sports_esports_rounded,
      badge: scheme.primaryFixedDim,
      onBadge: scheme.onPrimaryContainer,
      routeName: GameHomePage.routeName,
    );
    final shop = _MenuItem(
      label: l10n.shop,
      icon: Icons.shopping_bag_rounded,
      badge: scheme.tertiaryFixedDim,
      onBadge: scheme.onTertiaryContainer,
      routeName: ShopPage.routeName,
    );

    Widget tile(_MenuItem item) => Expanded(
          child: _MenuTile(item: item, fontSize: menuFontSize),
        );
    Widget row(List<_MenuItem> items) => Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              tile(items[i]),
            ],
          ],
        );

    // Space between the language switch at the top and [bottom].
    final room = media.size.height - media.padding.top - 64 - bottom;
    final oneRow = room < _MenuTile.height * 2 + _MenuBar.height + gap * 2;

    return Positioned(
      left: 24 + media.padding.left,
      right: 24 + media.padding.right,
      bottom: bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: oneRow ? 760 : 420),
          child: oneRow
              ? row([learn, practice, useCases, game, shop])
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    row([learn, practice]),
                    const SizedBox(height: gap),
                    row([useCases, game]),
                    const SizedBox(height: gap),
                    _MenuBar(item: shop, fontSize: menuFontSize),
                  ],
                ),
        ),
      ),
    );
  }

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
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            )),
      );

  _topBannerAds() => Positioned(
        top: MediaQuery.of(context).padding.top + 70,
        child: !kIsWeb
            ? Container(
                alignment: Alignment.center,
                // child: adWidget,
                // width: myBanner.size.width.toDouble(),
                // height: myBanner.size.height.toDouble(),
              )
            : Container(),
      );

  _languageSwitch() => Positioned(
        top: MediaQuery.of(context).padding.top,
        right: 20,
        child: LanguageWidget(),
      );

  void initBannerAds() {
    /* listener = BannerAdListener(
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
    }*/
  }
}

class _MenuItem {
  const _MenuItem({
    required this.label,
    required this.icon,
    required this.badge,
    required this.onBadge,
    required this.routeName,
  });

  final String label;
  final IconData icon;
  final Color badge;
  final Color onBadge;
  final String routeName;
}

const _menuRadius = BorderRadius.all(Radius.circular(18));

/// Olive card with the app's usual shadow and a ripple on tap.
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.routeName,
    required this.height,
    required this.child,
  });

  final String routeName;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final decoration =
        (ApplicationUtil.getBoxDecorationOne(context) as BoxDecoration)
            .copyWith(borderRadius: _menuRadius);
    // The decoration sits outside the Material: ink is clipped to the
    // Material's rectangle, which would cut the shadow into square corners.
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _menuRadius,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          onTap: () => Navigator.pushNamed(context, routeName),
          child: SizedBox(height: height, child: child),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: iconColor, size: size * 0.55),
    );
  }
}

/// One-line label that shrinks rather than overflows (long Tibetan words,
/// large accessibility text).
class _MenuLabel extends StatelessWidget {
  const _MenuLabel(this.text, {required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize, color: Colors.white),
      ),
    );
  }
}

/// Square-ish tile: icon on top, label underneath.
class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.fontSize});

  static const height = 128.0;

  final _MenuItem item;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return _MenuCard(
      routeName: item.routeName,
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBadge(
              icon: item.icon,
              color: item.badge,
              iconColor: item.onBadge,
              size: 52,
            ),
            const SizedBox(height: 8),
            Flexible(child: _MenuLabel(item.label, fontSize: fontSize)),
          ],
        ),
      ),
    );
  }
}

/// Full-width bar: icon on the left of the label.
class _MenuBar extends StatelessWidget {
  const _MenuBar({required this.item, required this.fontSize});

  static const height = 64.0;

  final _MenuItem item;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return _MenuCard(
      routeName: item.routeName,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBadge(
              icon: item.icon,
              color: item.badge,
              iconColor: item.onBadge,
              size: 40,
            ),
            const SizedBox(width: 12),
            Flexible(child: _MenuLabel(item.label, fontSize: fontSize)),
          ],
        ),
      ),
    );
  }
}
