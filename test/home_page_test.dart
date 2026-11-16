import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibetan_language_learning_app/cubit/language_cubit.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';
import 'package:tibetan_language_learning_app/l10n/localization_delegate.dart';
import 'package:tibetan_language_learning_app/presentation/game/game_home_page.dart';
import 'package:tibetan_language_learning_app/presentation/home.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/shop/shop_page.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_cases_menu.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

const _phone = Size(320, 568); // smallest phone we support (iPhone SE 1st gen)
const _tablet = Size(1024, 768);
const _landscape = Size(844, 390); // phone turned sideways
const _smallLandscape = Size(640, 360);

Future<void> _pumpHome(WidgetTester tester, Locale locale, Size screen) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(BlocProvider<LanguageCubit>(
    create: (_) => LanguageCubit(locale, AppConstant.ROBOTO_FAMILY),
    child: MaterialApp(
      locale: locale,
      supportedLocales: L10n.all,
      localizationsDelegates: [
        MaterialLocalizationTbDelegate(),
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: const HomePage(),
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => Scaffold(body: Text('route ${settings.name}')),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    getIt.registerSingleton<SharedPreferences>(
        await SharedPreferences.getInstance());
  });

  final entries = <IconData, String>{
    Icons.menu_book_rounded: LearnMenuPage.routeName,
    Icons.draw_rounded: PracticeMenuPage.routeName,
    Icons.forum_rounded: UseCaseMenuPage.routeName,
    Icons.sports_esports_rounded: GameHomePage.routeName,
    Icons.shopping_bag_rounded: ShopPage.routeName,
  };

  for (final locale in L10n.all) {
    for (final screen in [_phone, _tablet, _landscape, _smallLandscape]) {
      testWidgets(
          'shows all five sections with icons, '
          '${locale.languageCode} at ${screen.width.toInt()}x${screen.height.toInt()}',
          (tester) async {
        await _pumpHome(tester, locale, screen);
        final l10n = await AppLocalizations.delegate.load(locale);

        for (final label in [
          l10n.learnLangauge,
          l10n.practiceLanguage,
          l10n.useCases,
          l10n.playGame,
          l10n.shop,
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
        for (final icon in entries.keys) {
          expect(find.byIcon(icon), findsOneWidget);
        }

        // The whole menu is on screen, below the language switch.
        final switchBottom = tester.getBottomLeft(find.byType(Switch)).dy;
        for (final icon in entries.keys) {
          final rect = tester.getRect(find.byIcon(icon));
          expect(rect.top, greaterThan(switchBottom), reason: '$icon');
          expect(rect.left, greaterThanOrEqualTo(0), reason: '$icon');
          expect(rect.right, lessThanOrEqualTo(screen.width), reason: '$icon');
        }

        // Overflow would have thrown during layout.
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('each tile opens its section', (tester) async {
    await _pumpHome(tester, const Locale('en'), _phone);

    for (final entry in entries.entries) {
      await tester.tap(find.byIcon(entry.key));
      await tester.pumpAndSettle();
      expect(find.text('route ${entry.value}'), findsOneWidget);

      Navigator.of(tester.element(find.text('route ${entry.value}'))).pop();
      await tester.pumpAndSettle();
    }
  });
}
