import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibetan_language_learning_app/cubit/language_cubit.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';
import 'package:tibetan_language_learning_app/l10n/localization_delegate.dart';
import 'package:tibetan_language_learning_app/model/book_item.dart';
import 'package:tibetan_language_learning_app/presentation/shop/book_detail_page.dart';
import 'package:tibetan_language_learning_app/presentation/shop/shop_page.dart';
import 'package:tibetan_language_learning_app/presentation/shop/widgets/book_cover.dart';
import 'package:tibetan_language_learning_app/presentation/shop/widgets/page_viewer.dart';
import 'package:tibetan_language_learning_app/presentation/widget/parallax_background.dart';
import 'package:tibetan_language_learning_app/service/book_catalog_repository.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/amazon_link_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:tibetan_language_learning_app/util/route_generator.dart';
import 'package:url_launcher/url_launcher.dart';

const _phone = Size(390, 844);
const _usTime = Duration(hours: -5);
const _indiaTime = Duration(hours: 5, minutes: 30);

final _world = Uri.parse('https://www.amazon.com/dp/WORLD00001');
final _india = Uri.parse('https://www.amazon.in/dp/INDIA00001');

final _bothBook = BookItem(
  id: 'both',
  title: 'Book On Both',
  publisher: 'KharagEdition',
  cover: 'assets/books/square.jpg',
  ages: '3–7',
  pages: 40,
  links: {'world': _world, 'in': _india},
);
final _worldBook = BookItem(
  id: 'world',
  title: 'Book Only Abroad',
  cover: 'assets/books/tall.jpg',
  links: {'world': _world},
);
const _soonBook = BookItem(id: 'soon', title: 'Book Coming Later');

Stream<List<BookItem>> _fakeBooks() =>
    Stream.value([_bothBook, _worldBook, _soonBook]);

/// The real catalog (assets/books/books.json), with Firestore empty.
Stream<List<BookItem>> _builtInBooks() =>
    BookCatalogRepository(fetchRemote: () async => const []).watch();

String _builtInJson() => File('assets/books/books.json').readAsStringSync();

/// A 1×1 transparent PNG, standing in for downloaded pictures.
final _noPicture = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=');

/// Every call the shop made to open a link.
final _launches = <MapEntry<Uri, LaunchMode>>[];

/// What the phone reports for its SIM and mobile network (Android).
void _phoneCountries(String sim, String network) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(AmazonLinkUtil.channel, (call) async {
    return {'sim': sim, 'network': network};
  });
}

Future<GlobalKey<NavigatorState>> _openShop(
  WidgetTester tester, {
  Size screen = _phone,
  Locale locale = const Locale('en'),
  Stream<List<BookItem>> Function()? books = _builtInBooks,
}) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final navigator = GlobalKey<NavigatorState>();
  final observer = ParallaxDepthObserver();
  await tester.pumpWidget(BlocProvider<LanguageCubit>(
    create: (_) => LanguageCubit(locale, AppConstant.ROBOTO_FAMILY),
    child: MaterialApp(
      navigatorKey: navigator,
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
      home: ShopPage(books: books),
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  ));
  // Covers never finish decoding in widget tests, so this waits out the
  // cover preload's time limit too.
  await _frames(tester, 1600);
  return navigator;
}

Future<void> _frames(WidgetTester tester, [int ms = 600]) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapBook(WidgetTester tester, String id) async {
  final tile = find.byKey(ValueKey('book-$id'));
  await tester.scrollUntilVisible(tile, 200,
      scrollable: find.byType(Scrollable).first);
  await tester.tap(tile);
  await _frames(tester, 900);
}

Future<void> _buy(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('buy-button')),
      warnIfMissed: false);
  await _frames(tester, 300);
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back'));
  await _frames(tester, 900);
}

bool _isAmazonHost(String host) =>
    RegExp(r'(^|\.)amazon\.[a-z.]+$').hasMatch(host) ||
    const {'amzn.to', 'amzn.eu', 'amzn.in', 'a.co'}.contains(host);

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  });

  setUp(() async {
    await prefs.clear();
    _launches.clear();
    AmazonLinkUtil.debugReset();
    AmazonLinkUtil.deviceRegion = () => 'US';
    AmazonLinkUtil.utcOffset = () => _usTime;
    AmazonLinkUtil.internetCountry = () async => null;
    // Pictures can't be downloaded in tests (and never finish loading).
    networkBookImage = (url) => MemoryImage(_noPicture);
    _phoneCountries('', '');
    AmazonLinkUtil.launcher = (uri, mode) async {
      _launches.add(MapEntry(uri, mode));
      return true;
    };
  });

  group('books.json', () {
    final source = File('assets/books/books.json').readAsStringSync();
    final raw = jsonDecode(source) as Map<String, dynamic>;
    final entries = (raw['books'] as List).cast<Map<String, dynamic>>();
    final books = BookCatalog.parse(source);

    test('lists every book, each with its own id', () {
      expect(books, hasLength(entries.length),
          reason: 'a book without an id or title is left out of the Shop');
      expect(books.map((b) => b.id).toSet(), hasLength(books.length));
      expect(
        books.map((b) => b.title),
        containsAll([
          'My First Tibetan Alphabet',
          'Trace & Write Tibetan Alphabet',
          'Tibetan Language Learning: Fruits & Vegetables',
          'Tibetan Alphabet Coloring Book for Kids',
        ]),
      );
    });

    test('every picture is in Firebase Storage, not in the app', () {
      expect(File('pubspec.yaml').readAsStringSync(),
          contains('    - assets/books/\n'));
      expect(
          Directory('assets/books')
              .listSync()
              .map((f) => f.uri.pathSegments.last)
              .toList(),
          ['books.json'],
          reason: 'pictures live in Firebase Storage, so new books need no '
              'app release; keep the files in tool/shop_pictures/');
      for (final book in books) {
        expect(book.cover, isNotNull, reason: '${book.id} has no cover');
        for (final path in book.gallery) {
          expect(
              path,
              allOf(
                startsWith('https://firebasestorage.googleapis.com/v0/b/'),
                contains('token='),
              ),
              reason: '${book.id}: run python3 tool/upload_shop_books.py to '
                  'upload $path');
        }
      }
    });

    test('every link is a full https Amazon address, or left empty', () {
      for (final entry in entries) {
        final id = entry['id'];
        final links = entry['links'] as Map<String, dynamic>;
        expect(links.keys, containsAll(['world', 'india']),
            reason: '$id: every book keeps a world and an india link');
        for (final key in links.keys) {
          expect(key, matches(RegExp(r'^(world|india|[a-z]{2})$')),
              reason: '$id: links are world, india or a country code');
        }
        links.forEach((store, value) {
          expect(value, isA<String>(), reason: '$id $store');
          if ((value as String).isEmpty) return;
          final uri = Uri.parse(value);
          expect(uri.scheme, 'https', reason: '$id $store: $value');
          expect(_isAmazonHost(uri.host), isTrue,
              reason: '$id $store: $value is not an Amazon link');
          if (store == 'india') {
            expect(uri.host.endsWith('.com'), isFalse,
                reason: '$id: the india link should be an amazon.in link');
          }
        });
        if (entry['pages'] != null) {
          expect(entry['pages'], isA<int>(), reason: '$id pages');
        }
      }
    });
  });

  group('BookItem', () {
    test('reads books.json fields, treating empty values as missing', () {
      final book = BookItem.fromJson({
        'id': ' my-book ',
        'title': 'My Book',
        'cover': '',
        'previews': ['assets/books/a.jpg', '', 3],
        'pages': '12',
        'links': {
          'world': 'https://www.amazon.com/dp/X',
          'india': '',
        },
      });
      expect(book.id, 'my-book');
      expect(book.cover, isNull);
      expect(book.previews, ['assets/books/a.jpg']);
      expect(book.gallery, ['assets/books/a.jpg']);
      expect(book.pages, 12, reason: 'a number typed as text still counts');
      expect(book.links.keys, ['world']);
    });

    test('ignores a link that is not a web address', () {
      final book = BookItem.fromJson({
        'id': 'b',
        'title': 'B',
        'links': {
          'world': 'amazon.com/dp/X',
          'india': 'https://www.amazon.in/dp/Y'
        },
      });
      expect(book.links.keys, ['in'], reason: '"india" is read as "in"');
    });

    List<String> links(BookItem book, String? country) =>
        [for (final uri in book.linksFor(country)) '$uri'];

    test('India: its own edition, else Amazon.com', () {
      expect(links(_bothBook, 'in'), ['$_india', '$_world']);
      expect(links(_worldBook, 'in'), ['$_world'],
          reason: 'never guesses an amazon.in link');
    });

    test('elsewhere: the same book on the local Amazon, then Amazon.com', () {
      expect(links(_bothBook, 'ca'),
          ['https://www.amazon.ca/dp/WORLD00001', '$_world']);
      expect(links(_worldBook, 'GB'),
          ['https://www.amazon.co.uk/dp/WORLD00001', '$_world']);
      expect(links(_worldBook, 'uk'),
          ['https://www.amazon.co.uk/dp/WORLD00001', '$_world']);
      expect(links(_worldBook, 'jp'),
          ['https://www.amazon.co.jp/dp/WORLD00001', '$_world']);
    });

    test('the US, countries without their own Amazon, and unknown: .com', () {
      for (final country in ['us', 'np', 'br', null, '', 'nowhere']) {
        expect(links(_bothBook, country), ['$_world'], reason: '$country');
      }
    });

    test('a link for one country wins over the built one', () {
      final book = BookItem.fromJson({
        'id': 'b',
        'title': 'B',
        'links': {
          'world': 'https://www.amazon.com/dp/WORLD00001',
          'india': '',
          'ca': 'https://www.amazon.ca/dp/CANADA0001',
        },
      });
      expect(links(book, 'ca'), [
        'https://www.amazon.ca/dp/CANADA0001',
        'https://www.amazon.ca/dp/WORLD00001',
        'https://www.amazon.com/dp/WORLD00001',
      ]);
    });

    test('nothing to buy until a book has a link', () {
      expect(_soonBook.linksFor('us'), isEmpty);
      expect(_soonBook.isAvailable, isFalse);
      final indiaOnly = BookItem(
          id: 'i', title: 'I', links: {'in': _india}); // e.g. not on .com yet
      expect(links(indiaOnly, 'us'), ['$_india']);
    });

    test('reads the book code from long and tagged Amazon.com links', () {
      Uri? local(String world, String country) =>
          AmazonSites.local(Uri.parse(world), country);
      expect(
          local(
              'https://www.amazon.com/Tibetan-language-learning-book/dp/'
                  'B0C2MWLY61/ref=sr_1_1?tag=mytag-20',
              'de'),
          Uri.parse('https://www.amazon.de/dp/B0C2MWLY61'),
          reason: 'drops the Associates tag, which only works on .com');
      expect(local('https://amazon.com/gp/product/b0hr4lj42t', 'au'),
          Uri.parse('https://www.amazon.com.au/dp/B0HR4LJ42T'));
      expect(local('https://amzn.to/3abcdef', 'ca'), isNull,
          reason: 'short links have no code to read');
      expect(local('https://www.amazon.in/dp/B0HR4LJ42T', 'ca'), isNull,
          reason: 'only Amazon.com links are copied to other sites');
      expect(local('https://www.amazon.com/dp/B0HR4LJ42T', 'in'), isNull,
          reason: 'India has its own editions');
    });

    test('skips books without an id or a title', () {
      final books = BookCatalog.parse(jsonEncode({
        'books': [
          {'id': 'a', 'title': 'A'},
          {'id': '', 'title': 'No id'},
          {'id': 'c'},
          'not a book',
        ],
      }));
      expect(books.map((b) => b.id), ['a']);
    });
  });

  group('BookCatalogRepository', () {
    final t0 = DateTime(2026, 11, 16, 9);
    final remoteBook = {
      'id': 'remote',
      'title': 'Remote Book',
      'links': {'world': 'https://www.amazon.com/dp/REMOTE0001', 'india': ''},
    };

    BookCatalogRepository repo(
      DateTime now, {
      List<Map<String, dynamic>>? remote,
      Object? error,
      void Function()? onFetch,
    }) =>
        BookCatalogRepository(
          prefs: prefs,
          clock: () => now,
          bundledJson: () async => _builtInJson(),
          fetchRemote: () async {
            onFetch?.call();
            if (error != null) throw error;
            return remote ?? const [];
          },
        );

    List<String> titles(List<BookItem> books) =>
        [for (final b in books) b.title];
    final builtIn = titles(BookCatalog.parse(_builtInJson()));

    test('first time: the books in the app, then Firestore\'s', () async {
      final shown = await repo(t0, remote: [remoteBook]).watch().toList();
      expect(shown.map(titles), [
        builtIn,
        ['Remote Book'],
      ]);
    });

    test('opens with the saved list, and skips Firestore within the hour',
        () async {
      await repo(t0, remote: [remoteBook]).watch().drain<void>();
      var asked = false;
      final shown = await repo(t0.add(const Duration(minutes: 59)),
          onFetch: () => asked = true).watch().toList();
      expect(shown.map(titles), [
        ['Remote Book'],
      ]);
      expect(asked, isFalse);
    });

    test('after an hour, shows the saved list and then the new one', () async {
      await repo(t0, remote: [remoteBook]).watch().drain<void>();
      final updated = {...remoteBook, 'title': 'Remote Book, 2nd edition'};
      final shown =
          await repo(t0.add(const Duration(hours: 2)), remote: [updated])
              .watch()
              .toList();
      expect(shown.map(titles), [
        ['Remote Book'],
        ['Remote Book, 2nd edition'],
      ]);
    });

    test('an unchanged list is not shown twice', () async {
      await repo(t0, remote: [remoteBook]).watch().drain<void>();
      final shown =
          await repo(t0.add(const Duration(hours: 2)), remote: [remoteBook])
              .watch()
              .toList();
      expect(shown, hasLength(1));
    });

    test('offline: keeps the saved list', () async {
      await repo(t0, remote: [remoteBook]).watch().drain<void>();
      final shown = await repo(t0.add(const Duration(hours: 2)),
              error: Exception('offline'))
          .watch()
          .toList();
      expect(shown.map(titles), [
        ['Remote Book'],
      ]);
      expect(prefs.getString('shop_books_cache'), contains('Remote Book'));
    });

    test('offline the very first time: the books in the app', () async {
      final shown =
          await repo(t0, error: Exception('offline')).watch().toList();
      expect(shown.map(titles), [builtIn]);
    });

    test('an empty Firestore means the books in the app', () async {
      await repo(t0, remote: [remoteBook]).watch().drain<void>();
      final shown = await repo(t0.add(const Duration(hours: 2)), remote: [])
          .watch()
          .toList();
      expect(shown.map(titles), [
        ['Remote Book'],
        builtIn,
      ]);
      expect(prefs.getString('shop_books_cache'), isNull);
    });

    test('reads Firestore documents into books', () {
      final entries = BookCatalogRepository.entriesFrom([
        const MapEntry('c-book', {'title': 'C', 'order': 30}),
        MapEntry('a-book', {
          'title': 'A',
          'order': 10,
          'updated': DateTime(2026),
          'links': {'world': 'https://www.amazon.com/dp/A', 'india': ''},
        }),
        const MapEntry('no-order', {'title': 'Last'}),
        const MapEntry('hidden', {'title': 'Hidden', 'hidden': true}),
        const MapEntry('doc-id', {'id': 'own-id', 'title': 'B', 'order': 20}),
      ]);
      expect([for (final e in entries) e['id']],
          ['a-book', 'own-id', 'c-book', 'no-order']);
      expect(entries.first.containsKey('updated'), isFalse,
          reason: 'timestamps are dropped');
      final books = BookCatalog.parse(jsonEncode({'books': entries}));
      expect(
          books.first.links['world'].toString(), 'https://www.amazon.com/dp/A');
    });

    test('page counts typed as decimals or text still show', () {
      final books = BookCatalog.parse(jsonEncode({
        'books': [
          {'id': 'a', 'title': 'A', 'pages': 78.0},
          {'id': 'b', 'title': 'B', 'pages': ' 64 '},
          {'id': 'c', 'title': 'C', 'pages': 'many'},
        ],
      }));
      expect(books.map((b) => b.pages), [78, 64, 0]);
    });

    test('books.json can hide a book', () {
      final books = BookCatalog.parse(jsonEncode({
        'books': [
          {'id': 'a', 'title': 'A'},
          {'id': 'b', 'title': 'B', 'hidden': true},
        ],
      }));
      expect(books.map((b) => b.id), ['a']);
    });
  });

  group('AmazonLinkUtil', () {
    String? country({
      String? network,
      String? internet,
      String? saved,
      String? sim,
      String? region,
      Duration offset = _usTime,
    }) =>
        AmazonLinkUtil.countryFor(
          network: network,
          internet: internet,
          saved: saved,
          sim: sim,
          region: region,
          utcOffset: offset,
        )?.code;

    test('the mobile network says where the phone is, whatever the SIM', () {
      expect(country(network: 'ca', sim: 'in', internet: 'in'), 'ca',
          reason: 'an Indian SIM roaming in Canada is in Canada');
      expect(country(network: 'IN', sim: 'us'), 'in');
    });

    test('then the internet connection (Wi-Fi or mobile data)', () {
      expect(country(internet: 'ca', sim: 'in', saved: 'in'), 'ca');
      expect(country(internet: 'XX', sim: 'in'), 'in',
          reason: 'XX means the lookup did not know');
    });

    test('then last time\'s answer, the SIM, India time, the region', () {
      expect(country(saved: 'ca', sim: 'in'), 'ca');
      expect(country(sim: 'in', region: 'US'), 'in');
      expect(country(region: 'US', offset: _indiaTime), 'in');
      expect(country(region: 'IN'), 'in');
      expect(country(region: 'CA', offset: const Duration(hours: -4)), 'ca');
      expect(country(), isNull);
      expect(country(network: '', sim: ' ', internet: '-'), isNull);
    });

    test('reads the internet lookups', () {
      expect(
          AmazonLinkUtil.countryFromTrace(
              'fl=12f\nh=www.cloudflare.com\nip=203.0.113.9\nloc=CA\ntls=TLSv1.3'),
          'ca');
      expect(AmazonLinkUtil.countryFromTrace('loc=XX\n'), isNull);
      expect(AmazonLinkUtil.countryFromTrace('loc=T1\n'), isNull,
          reason: 'Tor');
      expect(AmazonLinkUtil.countryFromTrace('<html>blocked</html>'), isNull);
      expect(
          AmazonLinkUtil.countryFromJson('{"ip":"203.0.113.9","country":"IN"}'),
          'in');
      expect(AmazonLinkUtil.countryFromJson('Bad Request'), isNull);
      expect(AmazonLinkUtil.countryFromJson('{"error":"x"}'), isNull);
    });

    test('asks the phone, then remembers the answer', () async {
      _phoneCountries('in', 'ca');
      expect(await AmazonLinkUtil.detectCountry(), 'ca');
      expect(prefs.getString(AmazonLinkUtil.savedKey), 'ca');
    });

    test('asks the internet when there is no mobile network', () async {
      AmazonLinkUtil.internetCountry = () async => 'ca';
      expect(await AmazonLinkUtil.detectCountry(), 'ca');
      expect(prefs.getString(AmazonLinkUtil.savedKey), 'ca');
    });

    test('only remembers real answers, not guesses', () async {
      AmazonLinkUtil.utcOffset = () => _indiaTime;
      expect(await AmazonLinkUtil.detectCountry(), 'in');
      expect(prefs.getString(AmazonLinkUtil.savedKey), isNull);
    });

    test('offline, it uses last time\'s answer', () async {
      await prefs.setString(AmazonLinkUtil.savedKey, 'ca');
      _phoneCountries('in', '');
      AmazonLinkUtil.internetCountry = () async => throw Exception('offline');
      expect(await AmazonLinkUtil.detectCountry(), 'ca');
    });

    test('copes with phones that cannot say', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AmazonLinkUtil.channel, null);
      AmazonLinkUtil.utcOffset = () => _indiaTime;
      expect(await AmazonLinkUtil.detectCountry(), 'in');
    });

    test('tries the Amazon app first, then the browser', () async {
      AmazonLinkUtil.launcher = (uri, mode) async {
        _launches.add(MapEntry(uri, mode));
        return mode == LaunchMode.externalApplication;
      };
      expect(await AmazonLinkUtil.open(_world), isTrue);
      expect(_launches.map((e) => e.value), [
        LaunchMode.externalNonBrowserApplication,
        LaunchMode.externalApplication,
      ]);
    });

    test('stops after the Amazon app opens', () async {
      expect(await AmazonLinkUtil.open(_world), isTrue);
      expect(_launches.map((e) => e.value),
          [LaunchMode.externalNonBrowserApplication]);
    });

    test('reports failure when nothing can open the link', () async {
      AmazonLinkUtil.launcher = (uri, mode) async {
        _launches.add(MapEntry(uri, mode));
        if (mode == LaunchMode.externalNonBrowserApplication) {
          throw Exception('no app');
        }
        return false;
      };
      expect(await AmazonLinkUtil.open(_world), isFalse);
      expect(_launches, hasLength(2));
    });
  });

  group('Shop', () {
    testWidgets('shows every book from books.json', (tester) async {
      await _openShop(tester);
      final books =
          BookCatalog.parse(File('assets/books/books.json').readAsStringSync());
      expect(find.text('Coming soon'), findsWidgets,
          reason: 'books without links yet');
      for (final book in books) {
        final tile = find.byKey(ValueKey('book-${book.id}'));
        await tester.scrollUntilVisible(tile, 200,
            scrollable: find.byType(Scrollable).first);
        expect(find.descendant(of: tile, matching: find.text(book.title)),
            findsWidgets,
            reason: book.title);
      }
    });

    testWidgets('never shows the author\'s name, only KharagEdition',
        (tester) async {
      final navigator = await _openShop(tester);
      expect(find.textContaining('Kunchok'), findsNothing);
      for (final book in BookCatalog.parse(_builtInJson())) {
        navigator.currentState!
            .pushNamed(BookDetailPage.routeName, arguments: book);
        await _frames(tester, 900);
        expect(find.textContaining('Kunchok'), findsNothing,
            reason: book.title);
        expect(find.text('KharagEdition'), findsWidgets, reason: book.title);
        navigator.currentState!.pop();
        await _frames(tester, 900);
      }
    });

    testWidgets('every cover is the same size, square or tall', (tester) async {
      AssetAspect.debugRemember(_bothBook.cover!, 1.0); // square book
      AssetAspect.debugRemember(_worldBook.cover!, 0.77); // tall workbook
      final navigator = await _openShop(tester, books: _fakeBooks);

      Size coverOf(String id) => tester.getSize(find.descendant(
          of: find.byKey(ValueKey('book-$id')),
          matching: find.byType(BookCover)));
      final square = coverOf(_bothBook.id);
      final tall = coverOf(_worldBook.id);
      final plain = coverOf(_soonBook.id);
      for (final other in [tall, plain]) {
        expect(other.width, moreOrLessEquals(square.width));
        expect(other.height, moreOrLessEquals(square.height));
      }
      expect(square.width / square.height,
          moreOrLessEquals(BookCover.frameAspect, epsilon: 0.001));

      final sizes = <Size>[];
      for (final book in [_bothBook, _worldBook, _soonBook]) {
        navigator.currentState!
            .pushNamed(BookDetailPage.routeName, arguments: book);
        await _frames(tester, 900);
        sizes.add(tester.getSize(find.descendant(
            of: find.byType(BookDetailPage),
            matching: find.byType(BookCover))));
        navigator.currentState!.pop();
        await _frames(tester, 900);
      }
      expect(sizes.toSet(), hasLength(1), reason: '$sizes');
    });

    testWidgets('opens a book and buys it in the Amazon app or browser',
        (tester) async {
      AmazonLinkUtil.launcher = (uri, mode) async {
        _launches.add(MapEntry(uri, mode));
        return mode == LaunchMode.externalApplication; // no Amazon app
      };
      await _openShop(tester, books: _fakeBooks);
      await _tapBook(tester, _bothBook.id);

      expect(find.byType(BookDetailPage), findsOneWidget);
      // Beside the cover (and on the stand-in cover, as the test picture
      // can't load).
      expect(find.text('KharagEdition'), findsWidgets);
      expect(find.text('Ages 3–7 · 40 pages'), findsOneWidget);
      expect(find.text('Buy on Amazon'), findsOneWidget);

      await _buy(tester);
      expect(_launches.map((e) => '${e.value.name} ${e.key}'), [
        'externalNonBrowserApplication $_world',
        'externalApplication $_world',
      ]);
      expect(find.byType(SnackBar), findsNothing);

      await _back(tester);
      expect(find.byType(BookDetailPage), findsNothing);
    });

    testWidgets('never names an Amazon store', (tester) async {
      await _openShop(tester, books: _fakeBooks);
      for (final book in [_bothBook, _worldBook, _soonBook]) {
        await _tapBook(tester, book.id);
        expect(find.textContaining(RegExp(r'[Aa]mazon\.[a-z]')), findsNothing,
            reason: book.title);
        await _back(tester);
      }
      expect(find.textContaining(RegExp(r'[Aa]mazon\.[a-z]')), findsNothing);
    });

    testWidgets('a phone in India buys India\'s edition, else Amazon.com',
        (tester) async {
      _phoneCountries('in', 'in');
      await _openShop(tester, books: _fakeBooks);

      await _tapBook(tester, _bothBook.id);
      await _buy(tester);
      expect(_launches.map((e) => e.key), [_india]);
      await _back(tester);

      // Not on Amazon.in yet: still sold, from Amazon.com.
      await _tapBook(tester, _worldBook.id);
      expect(find.text('Buy on Amazon'), findsOneWidget);
      await _buy(tester);
      expect(_launches.map((e) => e.key), [_india, _world]);
      await _back(tester);

      // Not on Amazon at all.
      await _tapBook(tester, _soonBook.id);
      expect(find.text('Coming soon'), findsOneWidget);
      await _buy(tester);
      expect(_launches, hasLength(2));
    });

    testWidgets('a phone in India time without a SIM buys on Amazon.in',
        (tester) async {
      AmazonLinkUtil.utcOffset = () => _indiaTime;
      await _openShop(tester, books: _fakeBooks);
      await _tapBook(tester, _bothBook.id);
      await _buy(tester);
      expect(_launches.map((e) => e.key), [_india]);
    });

    testWidgets('elsewhere buys on the local Amazon site', (tester) async {
      _phoneCountries('gb', 'gb');
      await _openShop(tester, books: _fakeBooks);
      await _tapBook(tester, _bothBook.id);
      await _buy(tester);
      expect(_launches.map((e) => '${e.key}'),
          ['https://www.amazon.co.uk/dp/WORLD00001']);
    });

    testWidgets('countries without their own Amazon buy on Amazon.com',
        (tester) async {
      _phoneCountries('np', 'np');
      await _openShop(tester, books: _fakeBooks);
      await _tapBook(tester, _bothBook.id);
      await _buy(tester);
      expect(_launches.map((e) => e.key), [_world]);
    });

    testWidgets('an Indian SIM roaming in Canada buys on amazon.ca',
        (tester) async {
      _phoneCountries('in', 'ca'); // the Pixel 8 this was tested on
      await _openShop(tester);
      await _tapBook(tester, 'my-first-tibetan-alphabet');
      await _buy(tester);
      expect(_launches.map((e) => '${e.key}'),
          ['https://www.amazon.ca/dp/B0HR4LJ42T']);
    });

    testWidgets('on Wi-Fi, the internet connection gives the country',
        (tester) async {
      AmazonLinkUtil.internetCountry = () async => 'ca';
      await _openShop(tester, books: _fakeBooks);
      await _tapBook(tester, _worldBook.id);
      await _buy(tester);
      expect(_launches.map((e) => '${e.key}'),
          ['https://www.amazon.ca/dp/WORLD00001']);
    });

    testWidgets('if the India link will not open, Amazon.com opens instead',
        (tester) async {
      _phoneCountries('in', 'in');
      AmazonLinkUtil.launcher = (uri, mode) async {
        _launches.add(MapEntry(uri, mode));
        return uri.host != 'www.amazon.in';
      };
      await _openShop(tester, books: _fakeBooks);
      await _tapBook(tester, _bothBook.id);
      await _buy(tester);
      expect(_launches.map((e) => '${e.value.name} ${e.key}'), [
        'externalNonBrowserApplication $_india',
        'externalApplication $_india',
        'externalNonBrowserApplication $_world',
      ]);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets(
        'shows the books and still sells them if the phone never '
        'says where it is', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              AmazonLinkUtil.channel, (call) => Completer<Object?>().future);
      AmazonLinkUtil.utcOffset = () => _indiaTime;
      await _openShop(tester, books: _fakeBooks);
      expect(find.byKey(ValueKey('book-${_bothBook.id}')), findsOneWidget);

      await _tapBook(tester, _bothBook.id);
      await tester.tap(find.byKey(const ValueKey('buy-button')));
      await _frames(tester, 1200);
      expect(_launches.map((e) => e.key), [_india],
          reason: 'falls back to the time zone');
    });

    testWidgets('says so when the link cannot be opened', (tester) async {
      AmazonLinkUtil.launcher = (uri, mode) async => false;
      await _openShop(tester, books: _fakeBooks);
      await _tapBook(tester, _bothBook.id);
      await _buy(tester);
      expect(find.text('Could not open the link'), findsOneWidget);
    });

    testWidgets('look inside: open the cover or a page full screen',
        (tester) async {
      await _openShop(tester);
      await _tapBook(tester, 'my-first-tibetan-alphabet');
      final counter = find.byKey(const ValueKey('viewer-counter'));

      // Cover first, then the four pages.
      await tester.tap(find.byKey(const ValueKey('preview-1')));
      await _frames(tester, 600);
      expect(tester.widget<Text>(counter).data, '3 / 5');

      await tester.drag(
        find.descendant(
            of: find.byType(PageViewer), matching: find.byType(PageView)),
        const Offset(-300, 0),
      );
      await _frames(tester, 600);
      expect(tester.widget<Text>(counter).data, '4 / 5');

      await tester.tap(find.byTooltip('Close'));
      await _frames(tester, 600);
      expect(find.byType(PageViewer), findsNothing);

      await tester.tap(find.byKey(const ValueKey('book-cover')));
      await _frames(tester, 600);
      expect(tester.widget<Text>(counter).data, '1 / 5');
    });

    testWidgets('offers to try again when the books cannot be loaded',
        (tester) async {
      var calls = 0;
      await _openShop(tester, books: () {
        calls++;
        if (calls == 1) return Stream.error(const FormatException('bad'));
        return _fakeBooks();
      });
      expect(find.text("The books couldn't be loaded."), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await _frames(tester, 1600);
      expect(find.byKey(ValueKey('book-${_bothBook.id}')), findsOneWidget);
    });

    for (final locale in L10n.all) {
      for (final screen in const [
        Size(320, 568),
        _phone,
        Size(844, 390),
        Size(640, 360),
        Size(768, 1024),
        Size(1024, 768),
      ]) {
        testWidgets(
            'fits on ${screen.width.toInt()}x${screen.height.toInt()} '
            'in ${locale.languageCode}', (tester) async {
          final navigator =
              await _openShop(tester, screen: screen, locale: locale);
          final books = BookCatalog.parse(
              File('assets/books/books.json').readAsStringSync());
          await tester.drag(
              find.byType(Scrollable).first, const Offset(0, -3000));
          await _frames(tester, 600);

          for (final book in books) {
            navigator.currentState!
                .pushNamed(BookDetailPage.routeName, arguments: book);
            await _frames(tester, 900);
            expect(find.byType(BookDetailPage), findsOneWidget);
            await tester.drag(
                find.descendant(
                    of: find.byType(BookDetailPage),
                    matching: find.byType(SingleChildScrollView)),
                const Offset(0, -2000));
            await _frames(tester, 600);
            navigator.currentState!.pop();
            await _frames(tester, 900);
          }
        });
      }
    }
  });
}
