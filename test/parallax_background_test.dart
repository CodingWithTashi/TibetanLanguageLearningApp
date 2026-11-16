import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibetan_language_learning_app/cubit/language_cubit.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/main.dart';
import 'package:tibetan_language_learning_app/presentation/widget/parallax_background.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

const _screen = Size(390, 844);

void _useScreen(WidgetTester tester) {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Route<void> _page() => ParallaxPageRoute<void>(
      builder: (_) => const Scaffold(backgroundColor: Colors.transparent),
    );

/// Left edge of the background image on screen.
double _imageLeft(WidgetTester tester) => tester
    .getTopLeft(find.descendant(
        of: find.byType(ParallaxBackground), matching: find.byType(Image)))
    .dx;

void main() {
  group('ParallaxDepthObserver', () {
    late ParallaxDepthObserver observer;
    late GlobalKey<NavigatorState> navigator;

    Future<void> pumpApp(WidgetTester tester) async {
      _useScreen(tester);
      observer = ParallaxDepthObserver();
      addTearDown(observer.dispose);
      navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigator,
        navigatorObservers: [observer],
        builder: (context, child) =>
            ParallaxBackground(observer: observer, child: child!),
        home: const Scaffold(backgroundColor: Colors.transparent),
      ));
    }

    testWidgets('follows the page stack, mid-transition included',
        (tester) async {
      await pumpApp(tester);
      expect(observer.depth, 0);

      navigator.currentState!.push(_page());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(observer.depth, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(observer.depth, 1);

      navigator.currentState!.push(_page());
      await tester.pumpAndSettle();
      expect(observer.depth, 2);

      navigator.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(observer.depth, inExclusiveRange(1, 2));
      await tester.pumpAndSettle();
      expect(observer.depth, 1);

      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(observer.depth, 0);
    });

    testWidgets(
        'the page underneath is off screen before the transition ends, '
        'so nothing vanishes on the last frame', (tester) async {
      await pumpApp(tester);
      navigator.currentState!.push(ParallaxPageRoute<void>(
        builder: (_) => const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: Text('first page')),
        ),
      ));
      await tester.pumpAndSettle();
      final restingLeft = tester.getTopLeft(find.text('first page')).dx;

      navigator.currentState!.push(_page());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      final halfway = tester.getTopLeft(find.text('first page')).dx;
      // Moves with the page coming in, not a third as fast.
      expect(restingLeft - halfway, greaterThan(_screen.width / 2));

      await tester.pump(const Duration(milliseconds: 200));
      final nearEnd = tester.getTopLeft(find.text('first page')).dx;
      expect(nearEnd + 100, lessThan(0)); // the text is fully off screen
      await tester.pumpAndSettle();
      expect(find.text('first page'), findsNothing);
    });

    testWidgets('dialogs and bottom sheets do not move the background',
        (tester) async {
      await pumpApp(tester);
      showDialog<void>(
        context: navigator.currentContext!,
        builder: (_) => const AlertDialog(content: Text('hi')),
      );
      await tester.pumpAndSettle();
      expect(observer.depth, 0);

      navigator.currentState!.pop();
      showModalBottomSheet<void>(
        context: navigator.currentContext!,
        builder: (_) => const SizedBox(height: 100),
      );
      await tester.pumpAndSettle();
      expect(observer.depth, 0);
    });

    testWidgets('replacing a page keeps the depth steady', (tester) async {
      await pumpApp(tester);
      navigator.currentState!.push(_page());
      await tester.pumpAndSettle();

      navigator.currentState!.pushReplacement(_page());
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 60));
        expect(observer.depth, closeTo(1, 0.001));
      }
      await tester.pumpAndSettle();
      expect(observer.depth, 1);

      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(observer.depth, 0);
    });

    testWidgets('iOS back swipe still works and the background follows it',
        (tester) async {
      await pumpApp(tester);
      navigator.currentState!.push(_page());
      await tester.pumpAndSettle();
      expect(observer.depth, 1);

      final gesture = await tester.startGesture(const Offset(5, 400));
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();
      // Dragged roughly a third of the way back.
      expect(observer.depth, inExclusiveRange(0.5, 0.9));

      await gesture.moveBy(const Offset(150, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(observer.depth, 0);
      expect(navigator.currentState!.canPop(), isFalse);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('pans the image from its left edge to its right edge',
        (tester) async {
      await pumpApp(tester);
      // The square image is as tall as the screen, so it overhangs by
      // 844 - 390 = 454 px horizontally.
      expect(_imageLeft(tester), 0);

      navigator.currentState!.push(_page());
      await tester.pumpAndSettle();
      expect(_imageLeft(tester), closeTo(-227, 0.5));

      navigator.currentState!.push(_page());
      await tester.pumpAndSettle();
      expect(_imageLeft(tester), closeTo(-454, 0.5));

      // Deeper pages stay on the right edge.
      navigator.currentState!.push(_page());
      await tester.pumpAndSettle();
      expect(_imageLeft(tester), closeTo(-454, 0.5));
    });
  });

  group('app navigation', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      getIt.registerSingleton<SharedPreferences>(
          await SharedPreferences.getInstance());
      getIt.registerSingleton<AlphabetType>(AlphabetType());
    });

    testWidgets('menus share one background that pans with each level',
        (tester) async {
      _useScreen(tester);
      await tester.pumpWidget(BlocProvider<LanguageCubit>(
        create: (_) =>
            LanguageCubit(const Locale('en'), AppConstant.ROBOTO_FAMILY),
        child: const StartPage(),
      ));
      await tester.pump();
      final observer = tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .navigatorObservers!
          .whereType<ParallaxDepthObserver>()
          .single;
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));

      // Language picker -> Home replaces the first page: still level 0.
      await tester.tap(find.text('Learn Umê'));
      await tester.pumpAndSettle();
      expect(observer.depth, 0);

      await tester.tap(find.text(l10n.learnLangauge));
      await tester.pumpAndSettle();
      expect(observer.depth, 1);

      await tester.tap(find.text(l10n.thirtyConsonant));
      await tester.pumpAndSettle();
      expect(observer.depth, 2);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(observer.depth, 1);
      navigator.pop();
      await tester.pumpAndSettle();
      expect(observer.depth, 0);
      expect(find.text(l10n.learnLangauge), findsOneWidget);

      // The En/Tb switch rebuilds the whole MaterialApp; the background
      // must keep following the pages afterwards.
      final cubit = BlocProvider.of<LanguageCubit>(
          tester.element(find.byType(StartPage)));
      cubit.updateLocale(const Locale('bo'), AppConstant.JOMAHALI_FAMILY);
      await tester.pumpAndSettle();
      final bo = await AppLocalizations.delegate.load(const Locale('bo'));
      expect(find.text(bo.learnLangauge), findsOneWidget);
      expect(
          tester
              .widget<MaterialApp>(find.byType(MaterialApp))
              .navigatorObservers!
              .single,
          same(observer));

      await tester.tap(find.text(bo.learnLangauge));
      await tester.pumpAndSettle();
      expect(observer.depth, 1);
      expect(_imageLeft(tester), closeTo(-227, 0.5));
      navigator.pop();
      await tester.pumpAndSettle();
      expect(observer.depth, 0);
      expect(_imageLeft(tester), 0);
    });
  });
}
