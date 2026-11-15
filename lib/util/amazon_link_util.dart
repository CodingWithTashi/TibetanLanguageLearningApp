import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

/// An Amazon storefront, e.g. `amazon.ca`.
class AmazonMarketplace {
  final String domain;

  const AmazonMarketplace(this.domain);

  String get host => 'www.$domain';
}

class AmazonLinkUtil {
  AmazonLinkUtil._();

  /// Used when the device region is unknown or has no Amazon storefront.
  static const AmazonMarketplace _fallback = AmazonMarketplace('amazon.com');

  /// ISO country code -> Amazon domain. Add more countries as needed.
  static const Map<String, String> _domainByCountry = {
    'US': 'amazon.com',
    'CA': 'amazon.ca',
    'MX': 'amazon.com.mx',
    'BR': 'amazon.com.br',
    'GB': 'amazon.co.uk',
    'IE': 'amazon.ie',
    'DE': 'amazon.de',
    'AT': 'amazon.de',
    'CH': 'amazon.de',
    'FR': 'amazon.fr',
    'IT': 'amazon.it',
    'ES': 'amazon.es',
    'NL': 'amazon.nl',
    'BE': 'amazon.com.be',
    'SE': 'amazon.se',
    'PL': 'amazon.pl',
    'TR': 'amazon.com.tr',
    'AE': 'amazon.ae',
    'SA': 'amazon.sa',
    'EG': 'amazon.eg',
    'IN': 'amazon.in',
    'JP': 'amazon.co.jp',
    'SG': 'amazon.sg',
    'AU': 'amazon.com.au',
  };

  /// Optional Amazon Associates tracking ids, keyed by marketplace domain.
  /// Each marketplace needs its own tag, e.g. {'amazon.ca': 'yourtag-20'}.
  static const Map<String, String> affiliateTags = {};

  /// Marketplace for the device's region (not the app language, which is
  /// just "en" / "bo" and carries no country).
  static AmazonMarketplace currentMarketplace() =>
      marketplaceForCountry(_deviceCountryCode());

  static AmazonMarketplace marketplaceForCountry(String? countryCode) {
    final domain = _domainByCountry[countryCode?.toUpperCase()];
    return domain == null ? _fallback : AmazonMarketplace(domain);
  }

  static Uri productUri(String asin, AmazonMarketplace marketplace) {
    final tag = affiliateTags[marketplace.domain];
    return Uri.https(
      marketplace.host,
      '/dp/$asin',
      tag == null ? null : {'tag': tag},
    );
  }

  /// Opens the link outside the app. Returns false if it could not be opened.
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static String? _deviceCountryCode() {
    for (final locale in ui.PlatformDispatcher.instance.locales) {
      final code = locale.countryCode;
      if (code != null && code.isNotEmpty) return code;
    }
    return null;
  }
}