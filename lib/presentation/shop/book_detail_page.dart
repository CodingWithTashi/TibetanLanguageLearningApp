import 'package:material_ui/material_ui.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/model/book_item.dart';
import 'package:tibetan_language_learning_app/util/amazon_link_util.dart';

import '../game/widget/game_ui.dart';
import 'widgets/book_cover.dart';
import 'widgets/page_viewer.dart';

/// One book: cover and details, a Buy button, a look inside, and about.
class BookDetailPage extends StatefulWidget {
  static const routeName = "/shop/book";

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  final BookItem book;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _opening = false;

  BookItem get book => widget.book;

  void _openViewer(int page) {
    if (book.gallery.isEmpty) return;
    showPageViewer(
      context,
      title: book.title,
      pages: book.gallery,
      initialPage: page,
    );
  }

  /// Opens the book on the reader's own Amazon site (Amazon.in's edition
  /// in India, amazon.ca in Canada…), falling back to Amazon.com.
  Future<void> _buy() async {
    if (_opening) return;
    _opening = true;
    final opened = await AmazonLinkUtil.openBook(book);
    _opening = false;
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenLink)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final available = book.isAvailable;
    return GameScaffold(
      title: l10n.shop,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: GamePanel(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: kGameRadius,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Summary(book: book, onCover: () => _openViewer(0)),
                    const SizedBox(height: 18),
                    GameButton(
                      key: const ValueKey('buy-button'),
                      label: available
                          ? l10n.buyOnAmazon('Amazon')
                          : 'Coming soon',
                      icon: available
                          ? Icons.shopping_bag_rounded
                          : Icons.schedule_rounded,
                      onPressed: available ? _buy : null,
                      expand: true,
                    ),
                    if (book.previews.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const _Heading('Look inside'),
                      const SizedBox(height: 10),
                      _PreviewStrip(
                        book: book,
                        // The cover comes first in the viewer.
                        onTap: (i) =>
                            _openViewer(i + (book.cover == null ? 0 : 1)),
                      ),
                    ],
                    if (book.description.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const _Heading('About this book'),
                      const SizedBox(height: 8),
                      Text(
                        book.description,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15, height: 1.5),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cover on the left; title, author and details beside it.
class _Summary extends StatelessWidget {
  const _Summary({required this.book, required this.onCover});

  final BookItem book;
  final VoidCallback onCover;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    final muted = TextStyle(
      color: palette.cream.withValues(alpha: 0.85),
      fontSize: 13,
      height: 1.35,
    );
    final details = [
      if (book.ages.isNotEmpty) 'Ages ${book.ages}',
      if (book.pages > 0) '${book.pages} pages',
    ].join(' · ');
    return LayoutBuilder(builder: (context, constraints) {
      // The same size for every book.
      final coverWidth =
          (constraints.maxWidth * 0.36).clamp(96.0, 170.0).toDouble();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            key: const ValueKey('book-cover'),
            onTap: book.gallery.isEmpty ? null : onCover,
            child: Hero(
              tag: 'book-cover-${book.id}',
              child: SizedBox(
                width: coverWidth,
                child: BookCover(book: book),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (book.badge.isNotEmpty) ...[
                  Text(
                    book.badge.toUpperCase(),
                    style: TextStyle(
                      color: palette.lime,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (book.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(book.subtitle,
                      style: TextStyle(
                          color: palette.lime, fontSize: 13, height: 1.3)),
                ],
                const SizedBox(height: 10),
                if (book.byline.isNotEmpty) Text(book.byline, style: muted),
                if (details.isNotEmpty) Text(details, style: muted),
                if (book.format.isNotEmpty) Text(book.format, style: muted),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// A row of inside pages; tap one to see it full screen.
class _PreviewStrip extends StatelessWidget {
  const _PreviewStrip({required this.book, required this.onTap});

  final BookItem book;
  final ValueChanged<int> onTap;

  static const _height = 190.0;

  @override
  Widget build(BuildContext context) {
    // Inside pages share the cover's shape.
    final aspect = (book.cover == null ? null : AssetAspect.of(book.cover!)) ??
        BookCover.fallbackAspect;
    final cacheWidth =
        (_height * aspect * MediaQuery.devicePixelRatioOf(context)).round();
    return SizedBox(
      // Room for the page shadows.
      height: _height + 8,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: book.previews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => Semantics(
          button: true,
          hint: 'Open full screen',
          child: GestureDetector(
            key: ValueKey('preview-$i'),
            onTap: () => onTap(i),
            child: BookPageImage(
              path: book.previews[i],
              aspect: aspect,
              cacheWidth: cacheWidth,
              label: 'Page ${i + 1} of ${book.previews.length}',
            ),
          ),
        ),
      ),
    );
  }
}
