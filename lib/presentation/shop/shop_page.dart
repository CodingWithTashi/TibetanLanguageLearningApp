import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/model/book_item.dart';
import 'package:tibetan_language_learning_app/service/book_catalog_repository.dart';
import 'package:tibetan_language_learning_app/util/amazon_link_util.dart';

import '../game/widget/game_ui.dart';
import 'book_detail_page.dart';
import 'widgets/book_cover.dart';

/// The book catalog. Books come from Firestore (see
/// [BookCatalogRepository]), with assets/books/books.json as the fallback.
class ShopPage extends StatefulWidget {
  static const routeName = "/shop";

  const ShopPage({Key? key, this.books}) : super(key: key);

  /// Defaults to [BookCatalogRepository.watch]; tests pass their own.
  final Stream<List<BookItem>> Function()? books;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late Stream<List<BookItem>> _books;

  @override
  void initState() {
    super.initState();
    // Ready by the time someone taps Buy.
    AmazonLinkUtil.detectCountry();
    _books = _load();
  }

  Stream<List<BookItem>> _load() {
    final books = widget.books?.call() ?? BookCatalogRepository().watch();
    // Learn each cover's shape first, so nothing jumps as they appear.
    return books.asyncMap((list) async {
      if (mounted) {
        await AssetAspect.preload(context, [
          for (final b in list)
            if (b.cover != null) b.cover!
        ]);
      }
      return list;
    });
  }

  void _open(BookItem book) =>
      Navigator.pushNamed(context, BookDetailPage.routeName, arguments: book);

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: AppLocalizations.of(context)!.shop,
      body: StreamBuilder<List<BookItem>>(
        stream: _books,
        builder: (context, snapshot) {
          final Widget child;
          if (snapshot.hasError) {
            child = _Message(
              icon: Icons.cloud_off_rounded,
              text: "The books couldn't be loaded.",
              action: GameButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                onPressed: () => setState(() {
                  _books = _load();
                }),
              ),
            );
          } else if (!snapshot.hasData) {
            child = Center(
              child: CircularProgressIndicator(
                  color: GamePalette.of(context).lime),
            );
          } else if (snapshot.data!.isEmpty) {
            child = const _Message(
              icon: Icons.menu_book_rounded,
              text: 'New books are on the way.',
            );
          } else {
            child = _catalog(snapshot.data!);
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: child,
          );
        },
      ),
    );
  }

  Widget _catalog(List<BookItem> books) {
    return LayoutBuilder(builder: (context, constraints) {
      const padding = 12.0;
      const gap = 8.0;
      final width = constraints.maxWidth - padding * 2;
      final columns = math.max(2, ((width + gap) / (170 + gap)).floor());
      final tile = (width - gap * (columns - 1)) / columns;
      // Every cover is this size.
      final coverHeight = _BookTile.coverHeightFor(tile);
      // The panel fits the books, and scrolls once they need more room.
      return Align(
        alignment: Alignment.topCenter,
        child: GamePanel(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: kGameRadius,
            child: GridView.builder(
              key: const ValueKey('book-grid'),
              shrinkWrap: true,
              padding: const EdgeInsets.all(padding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                mainAxisExtent: _BookTile.heightFor(context, coverHeight),
              ),
              itemCount: books.length,
              itemBuilder: (context, i) => _BookTile(
                key: ValueKey('book-${books[i].id}'),
                book: books[i],
                coverHeight: coverHeight,
                onTap: () => _open(books[i]),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// A cover with the title and one line of detail under it.
class _BookTile extends StatelessWidget {
  const _BookTile({
    Key? key,
    required this.book,
    required this.coverHeight,
    required this.onTap,
  }) : super(key: key);

  final BookItem book;
  final double coverHeight;
  final VoidCallback onTap;

  static const _padding = 8.0;
  static const _titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const _detailStyle = TextStyle(fontSize: 12, height: 1.3);

  /// Every cover fills the tile's width, in the same frame.
  static double coverHeightFor(double tile) =>
      (tile - _padding * 2) / BookCover.frameAspect;

  static double heightFor(BuildContext context, double coverHeight) {
    final scale = MediaQuery.textScalerOf(context);
    return _padding * 2 +
        coverHeight +
        10 +
        scale.scale(_titleStyle.fontSize!) * _titleStyle.height! * 2 +
        4 +
        scale.scale(_detailStyle.fontSize!) * _detailStyle.height! +
        2;
  }

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    final available = book.isAvailable;
    final details = [
      if (book.ages.isNotEmpty) 'Ages ${book.ages}',
      if (book.pages > 0) '${book.pages} pages',
    ];
    final detail = !available
        ? 'Coming soon'
        : details.isNotEmpty
            ? details.join(' · ')
            : book.byline;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: coverHeight,
                width: double.infinity,
                child: Hero(
                  tag: 'book-cover-${book.id}',
                  child: BookCover(book: book),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _titleStyle,
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _detailStyle.copyWith(
                  color: available
                      ? palette.cream.withValues(alpha: 0.85)
                      : palette.lime,
                  fontWeight: available ? null : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GamePanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: palette.lime, size: 40),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.cream, fontSize: 16)),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
