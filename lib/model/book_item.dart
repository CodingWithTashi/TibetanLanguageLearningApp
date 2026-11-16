import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Amazon's own site in each country where a book's Amazon.com code
/// (ASIN) also works, so one link reaches readers everywhere.
///
/// India is left out on purpose: books there are a separate edition with
/// their own link ("india" in links).
class AmazonSites {
  AmazonSites._();

  /// Country code → Amazon site. Countries not listed buy on Amazon.com.
  static const byCountry = {
    'us': 'amazon.com',
    'ca': 'amazon.ca',
    'gb': 'amazon.co.uk',
    'de': 'amazon.de',
    'fr': 'amazon.fr',
    'es': 'amazon.es',
    'it': 'amazon.it',
    'nl': 'amazon.nl',
    'jp': 'amazon.co.jp',
    'au': 'amazon.com.au',
  };

  static final _bookCode = RegExp(
    r'/(?:dp|gp/product)/([A-Z0-9]{10})(?:[/?#]|$)',
    caseSensitive: false,
  );

  /// The same book as the Amazon.com link [world], on [country]'s own
  /// Amazon site. Null when the country has none (or is the US), or the
  /// link has no book code (short links such as amzn.to).
  static Uri? local(Uri world, String country) {
    final site = byCountry[country];
    if (site == null || site == 'amazon.com') return null;
    if (world.host != 'amazon.com' && !world.host.endsWith('.amazon.com')) {
      return null;
    }
    final code = _bookCode.firstMatch(world.path)?.group(1);
    if (code == null) return null;
    // Without the query: an Associates tag only works on its own site.
    return Uri.https('www.$site', '/dp/${code.toUpperCase()}');
  }

  /// A country as a two-letter lowercase code ("in", "ca"). Also takes
  /// "india" and "uk". Null for anything else.
  static String? country(String? value) {
    final code = value?.trim().toLowerCase();
    if (code == 'india') return 'in';
    if (code == 'uk') return 'gb';
    return code != null && RegExp(r'^[a-z]{2}$').hasMatch(code) ? code : null;
  }
}

/// One book in the Shop, from Firestore or assets/books/books.json; see
/// docs/shop-books.md for every field.
class BookItem {
  const BookItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.author = '',
    this.publisher = '',
    this.badge = '',
    this.description = '',
    this.ages = '',
    this.pages = 0,
    this.format = '',
    this.cover,
    this.previews = const [],
    this.links = const {},
  });

  final String id;
  final String title;
  final String subtitle;
  final String author;
  final String publisher;

  /// Short label on the cover, e.g. "New" or "Level 1". Empty for none.
  final String badge;
  final String description;

  /// Age range, e.g. "3–7". Empty when not given.
  final String ages;

  /// Number of pages; 0 when not given.
  final int pages;
  final String format;

  /// The front cover: an asset path or an https link. Null shows a plain
  /// title card.
  final String? cover;

  /// Sample inside pages (asset paths or https links), in order.
  final List<String> previews;

  /// Where to buy: [worldLink] for the main Amazon.com link, and a country
  /// code for a country's own edition (books.json's "india" is "in").
  final Map<String, Uri> links;

  static const worldLink = 'world';

  /// On Amazon in at least one store.
  bool get isAvailable => links.isNotEmpty;

  /// Who the book is from, shown under the title: the publisher, or the
  /// author when there is no publisher.
  String get byline => publisher.isNotEmpty ? publisher : author;

  /// Everything the reader can flip through: cover first, then the pages.
  List<String> get gallery => [if (cover != null) cover!, ...previews];

  /// The links to try, best first, for a reader in [country] (a
  /// two-letter code, or null when unknown):
  ///
  /// 1. the book's own link for that country (India's edition);
  /// 2. the same book on that country's Amazon site (amazon.ca, …);
  /// 3. the Amazon.com link, which is always the last resort.
  ///
  /// Empty when the book isn't on Amazon yet.
  List<Uri> linksFor(String? country) {
    final code = AmazonSites.country(country);
    final world = links[worldLink];
    final result = <Uri>[];
    void add(Uri? uri) {
      if (uri != null && !result.contains(uri)) result.add(uri);
    }

    if (code != null) {
      add(links[code]);
      if (world != null) add(AmazonSites.local(world, code));
    }
    add(world);
    // No Amazon.com link: any link beats none.
    if (result.isEmpty && links.isNotEmpty) add(links.values.first);
    return result;
  }

  factory BookItem.fromJson(Map<String, dynamic> json) {
    String text(String key) {
      final value = json[key];
      return value is String ? value.trim() : '';
    }

    final rawLinks = json['links'];
    final links = <String, Uri>{};
    if (rawLinks is Map) {
      rawLinks.forEach((key, value) {
        if (value is! String || value.trim().isEmpty) return;
        final name = key == worldLink ? worldLink : AmazonSites.country('$key');
        final uri = Uri.tryParse(value.trim());
        if (name != null &&
            uri != null &&
            uri.hasScheme &&
            uri.host.isNotEmpty) {
          links[name] = uri;
        } else {
          debugPrint('books.json: "${text('id')}" has a broken $key link: '
              '$value');
        }
      });
    }

    final previews = json['previews'];
    final pages = json['pages'];
    final cover = text('cover');
    return BookItem(
      id: text('id'),
      title: text('title'),
      subtitle: text('subtitle'),
      author: text('author'),
      publisher: text('publisher'),
      badge: text('badge'),
      description: text('description'),
      ages: text('ages'),
      // Firestore may send 78.0, and a console field typed as text "78".
      pages: pages is num
          ? pages.toInt()
          : int.tryParse('${pages ?? ''}'.trim()) ?? 0,
      format: text('format'),
      cover: cover.isEmpty ? null : cover,
      previews: previews is List
          ? [
              for (final p in previews)
                if (p is String && p.trim().isNotEmpty) p.trim()
            ]
          : const [],
      links: links,
    );
  }
}

/// Reads the Shop's book list ({"books": [...]}, as in
/// assets/books/books.json).
class BookCatalog {
  BookCatalog._();

  /// The copy built into the app, used until Firestore has answered.
  static const asset = 'assets/books/books.json';

  /// Books in order. Entries without an id or title, and entries marked
  /// "hidden": true, are skipped, so one half-written book doesn't break
  /// the whole Shop.
  static List<BookItem> parse(String source) {
    final data = jsonDecode(source);
    final list = data is Map ? data['books'] : data;
    if (list is! List) return const [];
    final books = <BookItem>[];
    for (final entry in list) {
      if (entry is! Map<String, dynamic>) continue;
      if (entry['hidden'] == true) continue;
      final book = BookItem.fromJson(entry);
      if (book.id.isEmpty || book.title.isEmpty) {
        debugPrint('books.json: skipped a book without an id or title');
        continue;
      }
      books.add(book);
    }
    return books;
  }
}
