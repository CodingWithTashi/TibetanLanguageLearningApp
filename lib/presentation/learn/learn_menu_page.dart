import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet/alphabet_list_page.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:tibetan_language_learning_app/util/app_theme.dart';

class LearnMenuPage extends StatefulWidget {
  static const routeName = "/learn-menu-page";
  const LearnMenuPage({Key? key}) : super(key: key);

  @override
  _LearnMenuPageState createState() => _LearnMenuPageState();
}

class _LearnMenuPageState extends State<LearnMenuPage> {
  late BannerAd myBanner;
  late BannerAdListener listener;
  late AdWidget adWidget;
  double menuFontSize = 30;
  @override
  void initState() {
    if (!kIsWeb) {
      listener = BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
        onAdImpression: (Ad ad) => print('Ad impression.'),
      );
      final adUnitId = kReleaseMode
          ? Platform.isAndroid
              ? AppConstant.BANNER_AD_LEARN_MENU_UNIT_ID
              : AppConstant.BANNER_AD_LEARN_MENU_UNIT_ID_IOS
          : AppConstant.TEST_UNIT_ID;
      myBanner = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: AdRequest(),
        listener: listener,
      );
      adWidget = AdWidget(ad: myBanner);
      myBanner.load();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == "bo") {
      menuFontSize = 28;
    } else {
      menuFontSize = 22;
    }
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Hero(
            tag: 'image',
            child: Container(
              child: Image.asset(
                'assets/images/tree.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              _getBannerAds(),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    child: AnimationLimiter(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 40,
                            left: 50,
                            top: MediaQuery.of(context).padding.top + 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(
                                milliseconds:
                                    ApplicationUtil.ANIMATION_DURATION),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: _getWidgetList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  List<Widget> _getWidgetList() {
    final menuItems = [
      (AlphabetCategoryType.ALPHABET, AppLocalizations.of(context)!.thirtyConsonant, Icons.abc_rounded),
      (AlphabetCategoryType.VOWEL, AppLocalizations.of(context)!.fourVowels, Icons.text_fields_rounded),
      (AlphabetCategoryType.FIVE_PREFIX, AppLocalizations.of(context)!.fivePrefixes, Icons.format_color_text_rounded),
      (AlphabetCategoryType.TEN_SUFFIX, AppLocalizations.of(context)!.tenSuffixes, Icons.format_underlined_rounded),
      (AlphabetCategoryType.TWO_POSTFIX, AppLocalizations.of(context)!.twoPostFixes, Icons.format_size_rounded),
      (AlphabetCategoryType.RAGO, AppLocalizations.of(context)!.ragoSurmounted, Icons.superscript_rounded),
      (AlphabetCategoryType.LAGO, AppLocalizations.of(context)!.lagoSurmounted, Icons.subscript_rounded),
      (AlphabetCategoryType.SAGO, AppLocalizations.of(context)!.sagoSarmounted, Icons.format_italic_rounded),
      (AlphabetCategoryType.YATAK, AppLocalizations.of(context)!.yatakSubJoin, Icons.format_bold_rounded),
      (AlphabetCategoryType.RATAK, AppLocalizations.of(context)!.ratakSubJoined, Icons.title_rounded),
      (AlphabetCategoryType.LATAK, AppLocalizations.of(context)!.latakSubJoined, Icons.font_download_rounded),
    ];

    return menuItems.map((item) {
      final (type, label, icon) = item;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
        child: _EnhancedLearnMenuItem(
          label: label,
          icon: icon,
          fontSize: menuFontSize,
          onTap: () {
            if (type == AlphabetCategoryType.ALPHABET) {
              getIt<AlphabetType>().type = type;
              Navigator.pushNamed(context, AlphabetListPage.routeName);
            } else {
              _navigateToAlphabetDetailPage(type);
            }
          },
        ),
      );
    }).toList();
  }

  _getBannerAds() => !kIsWeb
      ? Container(
          alignment: Alignment.center,
          child: adWidget,
          width: myBanner.size.width.toDouble(),
          height: myBanner.size.height.toDouble(),
        )
      : Container();

  _navigateToAlphabetDetailPage(AlphabetCategoryType type) {
    getIt<AlphabetType>().type = type;
    Navigator.pushNamed(context, AlphabetListPage.routeName);
  }
}

/// Enhanced learn menu item with modern design
class _EnhancedLearnMenuItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final double fontSize;
  final VoidCallback onTap;

  const _EnhancedLearnMenuItem({
    required this.label,
    required this.icon,
    required this.fontSize,
    required this.onTap,
  });

  @override
  State<_EnhancedLearnMenuItem> createState() => _EnhancedLearnMenuItemState();
}

class _EnhancedLearnMenuItemState extends State<_EnhancedLearnMenuItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.animationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceL,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
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
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceS),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spaceM),
              Expanded(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
