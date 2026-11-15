class BookItem {
  final String title;
  final String author;

  /// ASIN from the Amazon product URL (.../dp/<ASIN>). For older paperbacks
  /// this is the ISBN-10.
  final String asin;

  /// Optional cover image, e.g. "assets/books/book1.jpg".
  /// Declare the folder in pubspec.yaml.
  final String? coverAsset;

  /// Only needed when a marketplace uses a different ASIN,
  /// e.g. {'amazon.co.uk': 'B0XXXXXXXX'}.
  final Map<String, String> asinByDomain;

  const BookItem({
    required this.title,
    required this.asin,
    this.author = '',
    this.coverAsset,
    this.asinByDomain = const {},
  });

  /// ASIN to use for the given marketplace domain (e.g. "amazon.ca").
  String asinFor(String domain) => asinByDomain[domain] ?? asin;
}