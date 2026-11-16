import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/book_item.dart';
import '../servie_locater.dart';

/// Raw book entries from Firestore, in display order.
typedef RemoteBooks = Future<List<Map<String, dynamic>>> Function();

/// The Shop's books: kept in Firestore so they can change without an app
/// update, saved on the phone so the Shop opens instantly and works offline.
///
/// Firestore: collection [collection], one document per book (see
/// docs/shop-books.md).
class BookCatalogRepository {
  BookCatalogRepository({
    RemoteBooks? fetchRemote,
    SharedPreferences? prefs,
    Future<String> Function()? bundledJson,
    DateTime Function()? clock,
  })  : _fetchRemote = fetchRemote ?? firestoreBooks,
        _prefs = prefs ?? getIt<SharedPreferences>(),
        _bundledJson = bundledJson ??
            (() => rootBundle.loadString(BookCatalog.asset, cache: false)),
        _clock = clock ?? DateTime.now;

  static const collection = 'shop_books';

  /// How long a saved list is used before Firestore is asked again.
  static const maxAge = Duration(hours: 1);

  static const _cacheKey = 'shop_books_cache';
  static const _cacheTimeKey = 'shop_books_cache_time';

  final RemoteBooks _fetchRemote;
  final SharedPreferences _prefs;
  final Future<String> Function() _bundledJson;
  final DateTime Function() _clock;

  /// The books to show straight away (the list saved last time, or the copy
  /// built into the app), then Firestore's list when it differs. Firestore
  /// is asked at most once per [maxAge].
  Stream<List<BookItem>> watch() async* {
    String? shown = _prefs.getString(_cacheKey);
    final saved = shown == null ? null : _tryParse(shown);
    if (saved != null) {
      yield saved;
    } else {
      shown = null;
      yield BookCatalog.parse(await _bundledJson());
    }

    final savedAt = _prefs.getInt(_cacheTimeKey);
    final fresh = savedAt != null &&
        _clock().difference(DateTime.fromMillisecondsSinceEpoch(savedAt)) <
            maxAge;
    if (saved != null && fresh) return;

    final List<Map<String, dynamic>> entries;
    try {
      entries = await _fetchRemote().timeout(const Duration(seconds: 10));
    } catch (error) {
      // Offline, or Firestore not set up: keep what is showing.
      debugPrint('Shop: books not loaded from Firestore: $error');
      return;
    }
    if (entries.isEmpty) {
      // Nothing in Firestore: the copy in the app is the list.
      await _prefs.remove(_cacheKey);
      await _prefs.remove(_cacheTimeKey);
      if (shown != null) yield BookCatalog.parse(await _bundledJson());
      return;
    }
    final json = jsonEncode({'books': entries});
    await _prefs.setString(_cacheKey, json);
    await _prefs.setInt(_cacheTimeKey, _clock().millisecondsSinceEpoch);
    if (json != shown) yield BookCatalog.parse(json);
  }

  static List<BookItem>? _tryParse(String json) {
    try {
      return BookCatalog.parse(json);
    } catch (_) {
      return null;
    }
  }

  /// Every book document in [collection], straight from the server.
  static Future<List<Map<String, dynamic>>> firestoreBooks() async {
    // The web build doesn't start Firebase.
    if (Firebase.apps.isEmpty) return const [];
    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .get(const GetOptions(source: Source.server));
    return entriesFrom([
      for (final doc in snapshot.docs) MapEntry(doc.id, doc.data()),
    ]);
  }

  /// Book documents as books.json entries: the document id is the book id
  /// unless the document has its own, "hidden" books are left out, and
  /// books are sorted by their "order" number (books without one go last).
  @visibleForTesting
  static List<Map<String, dynamic>> entriesFrom(
      List<MapEntry<String, Map<String, dynamic>>> docs) {
    final entries = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final data = _jsonSafe(doc.value) as Map<String, dynamic>;
      if (data['hidden'] == true) continue;
      entries.add({'id': doc.key, ...data});
    }
    num orderOf(Map<String, dynamic> e) {
      final order = e['order'];
      return order is num ? order : double.infinity;
    }

    final position = {
      for (var i = 0; i < entries.length; i++) entries[i]: i,
    };
    entries.sort((a, b) {
      final byOrder = orderOf(a).compareTo(orderOf(b));
      return byOrder != 0 ? byOrder : position[a]!.compareTo(position[b]!);
    });
    return entries;
  }

  /// Keeps only what JSON can hold (drops timestamps, references…).
  static Object? _jsonSafe(Object? value) {
    if (value == null || value is String || value is bool) return value;
    if (value is num) return value.isFinite ? value : null;
    if (value is List) return [for (final v in value) _jsonSafe(v)];
    if (value is Map) {
      return <String, dynamic>{
        for (final e in value.entries)
          if (e.key is String && _isJson(e.value))
            e.key as String: _jsonSafe(e.value),
      };
    }
    return null;
  }

  static bool _isJson(Object? value) =>
      value == null ||
      value is String ||
      value is bool ||
      value is num ||
      value is List ||
      value is Map;
}
