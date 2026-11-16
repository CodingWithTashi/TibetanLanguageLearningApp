import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/book_item.dart';
import '../servie_locater.dart';

typedef LinkLauncher = Future<bool> Function(Uri uri, LaunchMode mode);

/// The country a reader is in, and how the app found out.
class CountryGuess {
  const CountryGuess(this.code, this.source);

  /// Two lowercase letters, e.g. "in" or "ca".
  final String code;

  /// Where it came from: "mobile network", "internet", "last time", "SIM",
  /// "time zone" or "region".
  final String source;

  @override
  String toString() => '$code (from $source)';
}

/// Works out which country the reader is in, and opens a book on that
/// country's Amazon site (see [BookItem.linksFor]).
class AmazonLinkUtil {
  AmazonLinkUtil._();

  @visibleForTesting
  static const channel = MethodChannel('tibetan_language_learning_app/region');

  static const _indiaTime = Duration(hours: 5, minutes: 30);

  /// The last country found from the network or the internet.
  static const savedKey = 'shop_country';

  static CountryGuess? _detected;
  static Future<CountryGuess?>? _detecting;

  /// The reader's country, worked out once per app run (see [countryFor]).
  /// Waits at most [wait]; after that it answers a quick guess and keeps
  /// working in the background, for the next time it's asked.
  static Future<String?> detectCountry(
      {Duration wait = const Duration(milliseconds: 1500)}) async {
    final known = _detected;
    if (known != null) return known.code;
    final detecting = _detecting ??= _detect();
    final guess = await detecting.timeout(wait, onTimeout: _quickGuess);
    return guess?.code;
  }

  /// Picks the country from what the phone knows, most telling first:
  ///
  /// 1. the mobile network it's on: where the phone is right now, even
  ///    with a SIM from home (Android);
  /// 2. the internet connection, Wi-Fi or mobile data, looked up from its
  ///    address;
  /// 3. what 1 or 2 said last time, for when neither answers now;
  /// 4. the SIM card's country (Android);
  /// 5. India's time zone, since many phones there are set to the US;
  /// 6. the phone's region setting.
  static CountryGuess? countryFor({
    String? network,
    String? internet,
    String? saved,
    String? sim,
    String? region,
    required Duration utcOffset,
  }) {
    final sources = {
      'mobile network': network,
      'internet': internet,
      'last time': saved,
      'SIM': sim,
    };
    for (final source in sources.entries) {
      final code = _code(source.value);
      if (code != null) return CountryGuess(code, source.key);
    }
    if (utcOffset == _indiaTime) return const CountryGuess('in', 'time zone');
    final code = _code(region);
    return code == null ? null : CountryGuess(code, 'region');
  }

  /// Opens [book] for the reader's country. If a link won't open, tries the
  /// next one, ending with the book's Amazon.com link. False if none
  /// opened.
  static Future<bool> openBook(BookItem book) async {
    final country = await detectCountry();
    for (final uri in book.linksFor(country)) {
      debugPrint('Shop: opening $uri for ${_detected ?? country}');
      if (await open(uri)) return true;
    }
    return false;
  }

  /// Opens the link in the Amazon app when it's installed, otherwise in the
  /// browser. Returns false if neither worked.
  static Future<bool> open(Uri uri) async {
    if (await _launch(uri, LaunchMode.externalNonBrowserApplication)) {
      return true;
    }
    return _launch(uri, LaunchMode.externalApplication);
  }

  @visibleForTesting
  static LinkLauncher launcher = (uri, mode) => launchUrl(uri, mode: mode);

  /// The country of the phone's internet address; null when unknown.
  @visibleForTesting
  static Future<String?> Function() internetCountry = _internetCountry;

  @visibleForTesting
  static String? Function() deviceRegion = _deviceRegion;

  @visibleForTesting
  static Duration Function() utcOffset = () => DateTime.now().timeZoneOffset;

  @visibleForTesting
  static void debugReset() {
    _detected = null;
    _detecting = null;
  }

  static Future<CountryGuess?> _detect() async {
    // Ask the phone and the internet at the same time.
    final internet = _safeInternetCountry();
    final phone = await _phoneCountries().timeout(const Duration(seconds: 1),
        onTimeout: () => const <String, String?>{});
    final onNetwork = _code(phone['network']) != null;
    final guess = countryFor(
      network: phone['network'],
      internet: onNetwork ? null : await internet,
      saved: _prefs?.getString(savedKey),
      sim: phone['sim'],
      region: deviceRegion(),
      utcOffset: utcOffset(),
    );
    if (guess != null &&
        (guess.source == 'mobile network' || guess.source == 'internet')) {
      await _prefs?.setString(savedKey, guess.code);
    }
    debugPrint('Shop: reader is in ${guess ?? 'an unknown country'}');
    return _detected = guess;
  }

  static Future<String?> _safeInternetCountry() async {
    try {
      return await internetCountry();
    } catch (_) {
      return null;
    }
  }

  /// What can be said without waiting.
  static CountryGuess? _quickGuess() => countryFor(
        saved: _prefs?.getString(savedKey),
        region: deviceRegion(),
        utcOffset: utcOffset(),
      );

  static SharedPreferences? get _prefs =>
      getIt.isRegistered<SharedPreferences>()
          ? getIt<SharedPreferences>()
          : null;

  static Future<bool> _launch(Uri uri, LaunchMode mode) async {
    try {
      return await launcher(uri, mode);
    } catch (_) {
      return false;
    }
  }

  /// SIM and network country from Android; nothing elsewhere.
  static Future<Map<String, String?>> _phoneCountries() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const {};
    }
    try {
      final result = await channel.invokeMapMethod<String, String>('countries');
      return result ?? const {};
    } catch (_) {
      return const {};
    }
  }

  /// Asks Cloudflare, then country.is, which country the phone's internet
  /// address is in. Each gets three seconds.
  static Future<String?> _internetCountry() async {
    final lookups = {
      'https://www.cloudflare.com/cdn-cgi/trace': countryFromTrace,
      'https://api.country.is/': countryFromJson,
    };
    for (final lookup in lookups.entries) {
      try {
        final response = await http
            .get(Uri.parse(lookup.key))
            .timeout(const Duration(seconds: 3));
        if (response.statusCode != 200) continue;
        final code = lookup.value(response.body);
        if (code != null) return code;
      } catch (_) {
        // Offline, blocked or slow: try the next one.
      }
    }
    return null;
  }

  /// The "loc=CA" line of Cloudflare's trace.
  @visibleForTesting
  static String? countryFromTrace(String body) {
    for (final line in const LineSplitter().convert(body)) {
      if (line.startsWith('loc=')) return _code(line.substring(4));
    }
    return null;
  }

  /// country.is's {"country": "CA"}.
  @visibleForTesting
  static String? countryFromJson(String body) {
    try {
      final data = jsonDecode(body);
      return data is Map ? _code('${data['country']}') : null;
    } catch (_) {
      return null;
    }
  }

  /// Two lowercase letters, or null. "XX" (unknown) and "T1" (Tor) count as
  /// unknown.
  static String? _code(String? value) {
    final code = value?.trim().toLowerCase();
    if (code == null || !RegExp(r'^[a-z]{2}$').hasMatch(code)) return null;
    return code == 'xx' ? null : code;
  }

  static String? _deviceRegion() {
    for (final locale in ui.PlatformDispatcher.instance.locales) {
      final code = locale.countryCode;
      if (code != null && code.isNotEmpty) return code;
    }
    return null;
  }
}
