import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/model/book_item.dart';
import 'package:tibetan_language_learning_app/util/amazon_link_util.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

/// Titles and author were taken from the Amazon.ca URLs, so check the spelling.
const List<BookItem> shopBooks = [
  BookItem(
    title: 'Tibetan Language Learning: Fruits & Vegetables',
    author: 'Kunchok Tashi',
    asin: 'B0C2MWLY61',
  ),
  BookItem(
    title: 'First Tibetan Alphabet',
    author: 'Kunchok Tashi',
    asin: 'B0HR4LJ42T',
  ),
  BookItem(
    title: 'Tibetan Alphabet Coloring Book for Kids',
    author: 'Kunchok Tashi',
    asin: 'B0C1J7N94C',
  ),
];

class ShopPage extends StatelessWidget {
  static const routeName = "/shop";

  const ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketplace = AmazonLinkUtil.currentMarketplace();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Hero(
            tag: 'image',
            child: Container(
              child: Image.asset(
                'assets/images/tree.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(
                        milliseconds: ApplicationUtil.ANIMATION_DURATION),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: -50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: _getWidgetList(context, marketplace),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  List<Widget> _getWidgetList(
      BuildContext context, AmazonMarketplace marketplace) {
    final List<Widget> widgetList = [
      SizedBox(
        height: MediaQuery.of(context).padding.top + 20,
      ),
    ];
    for (final book in shopBooks) {
      widgetList.add(_getBookCard(context, book, marketplace));
      widgetList.add(SizedBox(height: 20));
    }
    return widgetList;
  }

  Widget _getBookCard(
      BuildContext context,
      BookItem book,
      AmazonMarketplace marketplace,
      ) {
    return InkWell(
      onTap: () => _openBook(context, book, marketplace),
      child: Container(
        width: 300,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: ApplicationUtil.getBoxDecorationOne(context),
        child: Column(
          children: [
            _getCover(book),
            SizedBox(height: 12),
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            if (book.author.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                book.author,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
            SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 20, color: Colors.white),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!
                        .buyOnAmazon(marketplace.domain),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCover(BookItem book) {
    final asset = book.coverAsset;
    if (asset == null) {
      return Icon(Icons.menu_book_outlined, size: 80, color: Colors.white);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        asset,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.menu_book_outlined, size: 80, color: Colors.white),
      ),
    );
  }

  Future<void> _openBook(
      BuildContext context,
      BookItem book,
      AmazonMarketplace marketplace,
      ) async {
    final uri = AmazonLinkUtil.productUri(
      book.asinFor(marketplace.domain),
      marketplace,
    );
    final opened = await AmazonLinkUtil.open(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenLink)),
      );
    }
  }
}