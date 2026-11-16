import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibetan_language_learning_app/bloc/memory_match/memory_match_bloc.dart';
import 'package:tibetan_language_learning_app/cubit/language_cubit.dart';
import 'package:tibetan_language_learning_app/game_bloc/game_bloc.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';
import 'package:tibetan_language_learning_app/l10n/localization_delegate.dart';
import 'package:tibetan_language_learning_app/presentation/game/game_home_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/memory_match/memory_match_screen.dart';
import 'package:tibetan_language_learning_app/presentation/game/snake_game/snake_game.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drag.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/widget/drop.dart';
import 'package:tibetan_language_learning_app/presentation/game/util/game_model.dart';
import 'package:tibetan_language_learning_app/presentation/game/widget/game_ui.dart';
import 'package:tibetan_language_learning_app/presentation/widget/parallax_background.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:tibetan_language_learning_app/util/route_generator.dart';

const _phone = Size(390, 844);
const _smallPhone = Size(320, 568);
const _landscape = Size(844, 390);

/// Opens [route] the way the app does (home, game list, game) and lets the
/// opening animations run. The previews loop forever, so this pumps frames
/// instead of pumpAndSettle.
Future<GameBloc> _open(
  WidgetTester tester,
  String route, {
  Size screen = _phone,
  Locale locale = const Locale('en'),
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final gameBloc = GameBloc()..add(LoadGames());
  final observer = ParallaxDepthObserver();
  await tester.pumpWidget(MultiBlocProvider(
    providers: [
      BlocProvider<GameBloc>.value(value: gameBloc),
      BlocProvider<LanguageCubit>(
        create: (_) => LanguageCubit(locale, AppConstant.ROBOTO_FAMILY),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: L10n.all,
      localizationsDelegates: [
        MaterialLocalizationTbDelegate(),
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      navigatorObservers: [observer],
      builder: (context, child) =>
          ParallaxBackground(observer: observer, child: child!),
      onGenerateInitialRoutes: (_) => [
        for (final name in [
          if (route != GameHomePage.routeName) GameHomePage.routeName,
          route,
        ])
          RouteGenerator.generateRoute(RouteSettings(name: name)),
      ],
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  ));
  await _frames(tester, 1500);
  return gameBloc;
}

Future<void> _frames(WidgetTester tester, [int ms = 600]) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Unmounts the app so game timers and looping animations stop.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}

const _unlockedAll = <String, Object>{
  'game_unlock_GameType.snakeGame': true,
  'game_unlock_GameType.memoryGame': true,
};

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    getIt.registerSingleton<SharedPreferences>(
        await SharedPreferences.getInstance());
    getIt.registerSingleton<AlphabetType>(AlphabetType());
  });

  group('game list', () {
    for (final screen in [_phone, _smallPhone, _landscape]) {
      testWidgets('shows the three games at ${screen.width.toInt()} wide',
          (tester) async {
        await _open(tester, GameHomePage.routeName, screen: screen);
        for (final name in ['Spelling Bee', 'Snake Game', 'Memory Match']) {
          await tester.scrollUntilVisible(find.text(name), 100);
          expect(find.text(name), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await _close(tester);
      });
    }

    testWidgets('a locked game explains how to unlock it', (tester) async {
      await _open(tester, GameHomePage.routeName);
      await tester.tap(find.text('Snake Game'));
      await _frames(tester);
      expect(find.text('Snake Game is locked'), findsOneWidget);
      expect(
          find.text('Spell 5 words in one round of Spelling Bee to unlock it.'),
          findsWidgets);
      expect(
          find.text('Eat 3 letters in one round of Snake Game to unlock it.'),
          findsOneWidget);

      await tester.tap(find.text('Got it!'));
      await _frames(tester);
      expect(find.text('Snake Game is locked'), findsNothing);
      expect(find.byType(SnakeGamePage), findsNothing);
      await _close(tester);
    });

    testWidgets('an unlocked game opens', (tester) async {
      await _open(tester, GameHomePage.routeName, prefs: _unlockedAll);
      await tester.tap(find.text('Memory Match'));
      await _frames(tester);
      expect(find.byType(MemoryMatchGameScreen), findsOneWidget);
      await _close(tester);
    });
  });

  group('memory match', () {
    const quick = Duration(milliseconds: 20);

    Future<MemoryMatchBloc> started(List<String> cards) async {
      final bloc = MemoryMatchBloc(previewDuration: quick)
        ..add(InitializeGame(cards: cards));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(bloc.state.isPreviewing, isFalse);
      return bloc;
    }

    test('cards show face up first, and taps wait until they turn over',
        () async {
      final bloc = MemoryMatchBloc(previewDuration: quick)
        ..add(InitializeGame(cards: const ['ཀ', 'ག', 'ཀ', 'ག']));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isPreviewing, isTrue);

      bloc.add(FlipCard(index: 0));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.game!.flipped, everyElement(isFalse));
      expect(bloc.state.game!.attempts, 0);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(bloc.state.isPreviewing, isFalse);
      bloc.add(FlipCard(index: 0));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.game!.flipped[0], isTrue);
      await bloc.close();
    });

    test('the last game\'s preview timer does not cut the next one short',
        () async {
      final bloc =
          MemoryMatchBloc(previewDuration: const Duration(milliseconds: 60))
            ..add(InitializeGame(cards: const ['ཀ', 'ཀ']));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      bloc.add(InitializeGame(cards: const ['ག', 'ག']));
      await Future<void>.delayed(const Duration(milliseconds: 45));
      // The first game's timer has fired by now; the new game still shows.
      expect(bloc.state.isPreviewing, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(bloc.state.isPreviewing, isFalse);
      await bloc.close();
    });

    test('a wrong pair turns back over after a second', () async {
      final bloc = await started(const ['ཀ', 'ག', 'ཀ', 'ག']);
      bloc
        ..add(FlipCard(index: 0))
        ..add(FlipCard(index: 1));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.game!.flipped, [true, true, false, false]);

      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(bloc.state.game!.flipped, [false, false, false, false]);
      await bloc.close();
    });

    test('playing again starts a fresh, unfinished game', () async {
      final bloc = await started(const ['ཀ', 'ཀ']);
      bloc
        ..add(FlipCard(index: 0))
        ..add(FlipCard(index: 1));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isGameComplete, isTrue);

      bloc.add(InitializeGame(cards: const ['ག', 'ག']));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isGameComplete, isFalse);
      expect(bloc.state.isPreviewing, isTrue);
      expect(bloc.state.game!.pairsFound, 0);
      await bloc.close();
    });

    for (final screen in [_phone, _smallPhone, _landscape]) {
      testWidgets(
          '3x3 at ${screen.width.toInt()} wide: 8 cards around the score tile',
          (tester) async {
        await _open(tester, MemoryMatchGameScreen.routeName,
            screen: screen, prefs: _unlockedAll);
        Rect at(String key) => tester.getRect(find.byKey(ValueKey(key)));
        final cells = [
          for (var i = 0; i < 8; i++) at('card-$i'),
          at('memory-score'),
        ];
        expect(find.byKey(const ValueKey('card-8')), findsNothing);
        for (final rect in cells) {
          expect(rect.bottom, lessThanOrEqualTo(screen.height));
          expect(rect.right, lessThanOrEqualTo(screen.width));
        }
        expect(cells.map((r) => r.left.round()).toSet(), hasLength(3));
        expect(cells.map((r) => r.top.round()).toSet(), hasLength(3));
        // Middle column and middle row.
        expect(at('memory-score').left, at('card-1').left);
        expect(at('memory-score').top, at('card-3').top);

        final bloc = BlocProvider.of<MemoryMatchBloc>(
            tester.element(find.byKey(const ValueKey('card-0'))));
        final cards = bloc.state.game!.cards;
        final tibetan = RegExp(r'^[ༀ-࿿]+$');
        expect(cards.every(tibetan.hasMatch), isTrue);
        expect(cards.toSet(), hasLength(4));
        expect(tester.takeException(), isNull);
        await _close(tester);
      });
    }

    testWidgets('the cards show for 3 seconds, then turn over', (tester) async {
      await _open(tester, MemoryMatchGameScreen.routeName, prefs: _unlockedAll);
      final bloc = BlocProvider.of<MemoryMatchBloc>(
          tester.element(find.byKey(const ValueKey('card-0'))));
      final letters = bloc.state.game!.cards.toSet();
      expect(find.text('Remember!'), findsOneWidget);
      for (final letter in letters) {
        expect(find.text(letter), findsNWidgets(2));
      }

      // Tapping while they show does nothing.
      await tester.tap(find.byKey(const ValueKey('card-0')));
      await tester.pump();
      expect(bloc.state.game!.attempts, 0);

      await _frames(tester, 2000);
      expect(bloc.state.isPreviewing, isFalse);
      for (final letter in letters) {
        expect(find.text(letter), findsNothing);
      }
      expect(find.text('0/4'), findsOneWidget);
      await _close(tester);
    });

    testWidgets('finding every pair celebrates, and play again restarts',
        (tester) async {
      await _open(tester, MemoryMatchGameScreen.routeName, prefs: _unlockedAll);
      await _frames(tester, 2000);
      final bloc = BlocProvider.of<MemoryMatchBloc>(
          tester.element(find.byKey(const ValueKey('card-0'))));
      final cards = bloc.state.game!.cards;
      final done = <int>{};
      for (var a = 0; a < cards.length; a++) {
        if (done.contains(a)) continue;
        final b = List.generate(cards.length, (i) => i)
            .firstWhere((i) => i != a && cards[i] == cards[a]);
        done.addAll([a, b]);
        await tester.tap(find.byKey(ValueKey('card-$a')));
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('card-$b')));
        await _frames(tester, 400);
      }
      await _frames(tester);
      expect(find.text('Well done!'), findsOneWidget);
      expect(find.text('You found all 4 pairs in 4 moves.'), findsOneWidget);

      await tester.tap(find.text('Play again'));
      await _frames(tester);
      expect(find.text('Well done!'), findsNothing);
      expect(bloc.state.game!.pairsFound, 0);
      expect(bloc.state.isGameComplete, isFalse);
      expect(find.text('Remember!'), findsOneWidget);
      await _close(tester);
    });
  });

  group('snake', () {
    for (final screen in [_phone, _smallPhone]) {
      testWidgets(
          'the whole board is on screen at ${screen.width.toInt()} wide',
          (tester) async {
        await _open(tester, SnakeGamePage.routeName,
            screen: screen, prefs: _unlockedAll);
        final board = tester.getRect(find.byKey(const ValueKey('snake-board')));
        expect(board.bottom, lessThanOrEqualTo(screen.height));
        expect(board.width / board.height, closeTo(20 / 38, 0.03));
        expect(tester.takeException(), isNull);
        await _close(tester);
      });
    }

    testWidgets('ending a game shows one game over dialog', (tester) async {
      await _open(tester, SnakeGamePage.routeName, prefs: _unlockedAll);
      await tester.tap(find.text('Start game'));
      await _frames(tester, 900);
      await tester.tap(find.text('End game'));
      await _frames(tester, 900);
      expect(find.text('Game over'), findsOneWidget);

      await tester.tap(find.text('Play again'));
      await _frames(tester, 300);
      expect(find.text('Game over'), findsNothing);
      expect(find.text('End game'), findsOneWidget);

      // A second game ends the same way.
      await tester.tap(find.text('End game'));
      await _frames(tester, 900);
      expect(find.text('Game over'), findsOneWidget);
      await _close(tester);
    });
  });

  group('spelling bee', () {
    Future<void> place(WidgetTester tester, {int? count}) async {
      final drags = find.byType(Drag).evaluate().toList();
      for (final drag in drags.take(count ?? drags.length)) {
        final letter = (drag.widget as Drag).letter;
        final slot =
            find.byWidgetPredicate((w) => w is Drop && w.letter == letter);
        final gesture = await tester
            .startGesture(tester.getCenter(find.byWidget(drag.widget)));
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        await gesture.moveTo(tester.getCenter(slot));
        await tester.pump();
        await gesture.up();
        await _frames(tester, 500);
      }
    }

    /// Spells [count] words, letting each next word fly in.
    Future<void> spell(WidgetTester tester, int count) async {
      for (var i = 0; i < count; i++) {
        await place(tester);
        await _frames(tester, 700);
      }
    }

    SpellingBeeProvider bee(WidgetTester tester) =>
        Provider.of<SpellingBeeProvider>(
            tester.element(find.byType(SpellingBeePage)),
            listen: false);

    String word() => find
        .byType(Drop)
        .evaluate()
        .map((e) => (e.widget as Drop).letter)
        .join();

    String progress(int done) =>
        '${AppConstant.getTibetanNumberByNumber(number: '$done')} / '
        '${AppConstant.getTibetanNumberByNumber(number: '${AppConstant.verbsList.length}')}';

    final placed = find.byWidgetPredicate((w) => w is LetterTile && w.placed);

    test('all the words are in the round', () {
      expect(AppConstant.verbsList, hasLength(29));
    });

    testWidgets('each spelled word brings the next one', (tester) async {
      await _open(tester, SpellingBeePage.routeName);
      final first = word();
      expect(find.text(progress(0)), findsNWidgets(2));

      await spell(tester, 1);
      expect(bee(tester).wordAnswered, 1);
      expect(word(), isNot(first));
      expect(placed, findsNothing);
      expect(find.text(progress(1)), findsNWidgets(2));
      expect(find.text('Congrats!'), findsNothing);
      await _close(tester);
    });

    testWidgets('Snake unlocks after 5 words, and the round goes on',
        (tester) async {
      final games = await _open(tester, SpellingBeePage.routeName);
      bool snakeOpen() => games.state.games
          .firstWhere((g) => g.gameType == GameType.snakeGame)
          .isUnlocked;

      await spell(tester, kSpellingBeeWordsToUnlock - 1);
      expect(snakeOpen(), isFalse);
      expect(find.text('Snake Game unlocked!'), findsNothing);

      await spell(tester, 1);
      expect(snakeOpen(), isTrue);
      expect(find.text('Snake Game unlocked!'), findsOneWidget);
      expect(find.text('Congrats!'), findsNothing);
      expect(bee(tester).generateWord, isFalse);
      expect(find.byType(Drag), findsWidgets);
      await _close(tester);
    });

    testWidgets('the last word ends the round; play again or exit',
        (tester) async {
      await _open(tester, SpellingBeePage.routeName);
      final total = AppConstant.verbsList.length;
      final seen = <String>{};
      for (var i = 0; i < total; i++) {
        seen.add(word());
        await spell(tester, 1);
      }
      expect(seen, hasLength(total), reason: 'every word once');
      expect(find.text('Congrats!'), findsOneWidget);
      expect(
          find.text('You spelled all $total words. '
              'You just cracked spelling bee contest ❤.'),
          findsOneWidget);

      await tester.tap(find.text('Play again'));
      await _frames(tester, 1200);
      expect(find.text('Congrats!'), findsNothing);
      expect(find.byType(SpellingBeePage), findsOneWidget);
      expect(bee(tester).wordAnswered, 0);
      expect(find.text(progress(0)), findsNWidgets(2));

      for (var i = 0; i < total; i++) {
        await spell(tester, 1);
      }
      await tester.tap(find.text('Exit'));
      await _frames(tester, 1200);
      expect(find.byType(SpellingBeePage), findsNothing);
      expect(find.byType(GameHomePage), findsOneWidget);
      await _close(tester);
    });

    testWidgets('placed letters stay placed when the phone is turned',
        (tester) async {
      await _open(tester, SpellingBeePage.routeName);
      // Words come in random order; some have one letter, which the first
      // drop would finish. Move on to one with at least two.
      while (find.byType(Drop).evaluate().length < 2) {
        await spell(tester, 1);
      }
      final before = bee(tester).wordAnswered;
      final total = find.byType(Drop).evaluate().length;
      final waiting = find
          .byWidgetPredicate((w) => w is LetterTile && !w.placed && !w.lifted);
      await place(tester, count: 1);
      expect(placed, findsOneWidget);
      expect(waiting, findsNWidgets(total - 1));

      tester.view.physicalSize = _landscape;
      await _frames(tester);
      expect(placed, findsOneWidget);
      expect(waiting, findsNWidgets(total - 1));

      // Finishing the word after the turn counts every letter once.
      await place(tester);
      await _frames(tester, 700);
      expect(bee(tester).wordAnswered, before + 1);
      expect(placed, findsNothing);
      await _close(tester);
    });

    testWidgets('back asks before leaving', (tester) async {
      await _open(tester, SpellingBeePage.routeName);
      await tester.tap(find.byTooltip('Back'));
      await _frames(tester);
      expect(find.text('Leave the game?'), findsOneWidget);

      await tester.tap(find.text('Keep playing'));
      await _frames(tester);
      expect(find.byType(SpellingBeePage), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await _frames(tester);
      await tester.tap(find.text('Leave'));
      await _frames(tester);
      expect(find.byType(SpellingBeePage), findsNothing);
      await _close(tester);
    });

    for (final screen in [_smallPhone, _landscape]) {
      testWidgets('fits at ${screen.width.toInt()}x${screen.height.toInt()}',
          (tester) async {
        await _open(tester, SpellingBeePage.routeName, screen: screen);
        for (final element in find.byType(Drag).evaluate()) {
          final rect = tester.getRect(find.byWidget(element.widget));
          expect(rect.bottom, lessThanOrEqualTo(screen.height));
        }
        expect(tester.takeException(), isNull);
        await _close(tester);
      });
    }
  });
}
