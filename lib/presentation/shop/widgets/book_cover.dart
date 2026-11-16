import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../model/book_item.dart';
import '../../game/widget/game_ui.dart';

/// How a picture link is fetched: downloaded once, then kept on the phone.
/// Tests swap in their own.
@visibleForTesting
ImageProvider Function(String url) networkBookImage =
    (url) => CachedNetworkImageProvider(url);

/// A book picture: an https link (Firebase Storage, see
/// tool/upload_shop_books.py), or an asset in the app.
ImageProvider bookImage(String path, {int? cacheWidth}) {
  final ImageProvider image;
  if (path.startsWith('https://')) {
    image = networkBookImage(path);
  } else {
    image = AssetImage(path);
  }
  return ResizeImage.resizeIfNeeded(cacheWidth, null, image);
}

/// Width / height of each picture once known, shared by every screen so a
/// cover keeps its shape between pages (and while it flies between them).
final _knownAspects = <String, double>{};

/// A book's front cover with a soft shadow, always in the same frame
/// ([frameAspect]) so every book is the same size. A cover of another shape
/// (a square picture book) is shown whole, on a soft blur of itself. Books
/// without a cover picture get a plain title card instead.
class BookCover extends StatelessWidget {
  const BookCover({Key? key, required this.book}) : super(key: key);

  final BookItem book;

  /// Width / height of every cover's frame: an 8.5 × 11 in book.
  static const frameAspect = 0.77;

  /// Shape assumed until a picture's real size is known.
  static const fallbackAspect = frameAspect;

  @override
  Widget build(BuildContext context) {
    final path = book.cover;
    return _frame(path == null
        ? _TitleCard(book: book)
        : AssetAspect(
            path: path,
            builder: (aspect) => _face(path, aspect),
          ));
  }

  Widget _face(String path, double aspect) {
    Widget picture(BoxFit fit) => Image(
          image: bookImage(path),
          fit: fit,
          gaplessPlayback: true,
          frameBuilder: _fadeIn,
          errorBuilder: (_, __, ___) => _TitleCard(book: book),
        );
    // Close enough to the frame's shape: fill it.
    if ((aspect - frameAspect).abs() / frameAspect < 0.04) {
      return picture(BoxFit.cover);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Image(
            image: bookImage(path),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        const ColoredBox(color: Color(0x26000000)),
        picture(BoxFit.contain),
      ],
    );
  }

  Widget _frame(Widget face) {
    const radius = BorderRadius.all(Radius.circular(4));
    return Semantics(
      image: true,
      label: '${book.title} cover',
      child: AspectRatio(
        aspectRatio: frameAspect,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: ClipRRect(borderRadius: radius, child: face),
        ),
      ),
    );
  }
}

/// Fades a picture in once it has loaded instead of popping in.
Widget _fadeIn(BuildContext context, Widget child, int? frame, bool sync) {
  if (sync) return child;
  return AnimatedOpacity(
    opacity: frame == null ? 0 : 1,
    duration: const Duration(milliseconds: 200),
    child: child,
  );
}

/// An inside page, shown at [aspect] (the pages of a book share one shape).
class BookPageImage extends StatelessWidget {
  const BookPageImage({
    Key? key,
    required this.path,
    required this.aspect,
    this.cacheWidth,
    this.label,
  }) : super(key: key);

  final String path;
  final double aspect;

  /// Decode at this many pixels wide; small thumbnails need far fewer.
  final int? cacheWidth;
  final String? label;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(4));
    return AspectRatio(
      aspectRatio: aspect,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white10,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Image(
            image: bookImage(path, cacheWidth: cacheWidth),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            semanticLabel: label,
            frameBuilder: _fadeIn,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}

/// Builds with the picture's width / height once it is known, so a book
/// keeps its real shape (square picture books, tall workbooks).
class AssetAspect extends StatefulWidget {
  const AssetAspect({
    Key? key,
    required this.path,
    required this.builder,
    this.fallback = BookCover.fallbackAspect,
  }) : super(key: key);

  final String path;
  final Widget Function(double aspect) builder;

  /// Used until the picture has loaded.
  final double fallback;

  /// The shape of [path], if it has been seen.
  static double? of(String path) => _knownAspects[path];

  /// Tests can't decode pictures, so they say what shape one has.
  @visibleForTesting
  static void debugRemember(String path, double aspect) =>
      _knownAspects[path] = aspect;

  /// Learns the shape of [paths] up front, so nothing changes size when the
  /// pictures appear. Gives up after [timeout]; shapes then follow later.
  static Future<void> preload(
    BuildContext context,
    Iterable<String> paths, {
    Duration timeout = const Duration(milliseconds: 800),
  }) {
    final config = createLocalImageConfiguration(context);
    final pending = <Future<void>>[];
    for (final path in paths) {
      if (_knownAspects.containsKey(path)) continue;
      final done = Completer<void>();
      final stream = bookImage(path).resolve(config);
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          final aspect = info.image.width / info.image.height;
          info.dispose();
          if (aspect.isFinite && aspect > 0) _knownAspects[path] = aspect;
          stream.removeListener(listener);
          if (!done.isCompleted) done.complete();
        },
        onError: (_, __) {
          stream.removeListener(listener);
          if (!done.isCompleted) done.complete();
        },
      );
      stream.addListener(listener);
      pending.add(done.future);
    }
    if (pending.isEmpty) return Future.value();
    return Future.wait(pending).timeout(timeout, onTimeout: () => const []);
  }

  @override
  State<AssetAspect> createState() => _AssetAspectState();
}

class _AssetAspectState extends State<AssetAspect> {
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(AssetAspect old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path) _resolve();
  }

  void _resolve() {
    _stop();
    if (_knownAspects.containsKey(widget.path)) return;
    final path = widget.path;
    final stream =
        bookImage(path).resolve(createLocalImageConfiguration(context));
    // A cached picture answers straight away, while this widget is being
    // built; build() reads the result then, so no rebuild is needed.
    var answeredNow = true;
    final listener = ImageStreamListener(
      (info, _) {
        final aspect = info.image.width / info.image.height;
        info.dispose();
        _stop();
        if (!aspect.isFinite || aspect <= 0) return;
        _knownAspects[path] = aspect;
        if (!answeredNow && mounted) setState(() {});
      },
      onError: (_, __) => _stop(),
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
    answeredNow = false;
  }

  void _stop() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(_knownAspects[widget.path] ?? widget.fallback);
}

/// Stand-in cover: plain dark olive with the title and publisher.
class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.book});

  final BookItem book;

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final pad = w * 0.11;
      final titleSize = w * 0.105;
      final authorSize = w * 0.07;
      const lineHeight = 1.2;
      final authorBlock =
          book.byline.isEmpty ? 0.0 : w * 0.05 + authorSize * lineHeight;
      // As many title lines as fit (at most six).
      final room = h - pad * 2 - authorBlock;
      final lines = (room / (titleSize * lineHeight)).floor().clamp(1, 6);
      return ColoredBox(
        color: palette.deep,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: lines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.cream,
                    fontSize: titleSize,
                    height: lineHeight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (book.byline.isNotEmpty) ...[
                  SizedBox(height: w * 0.05),
                  Text(
                    book.byline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.lime,
                      fontSize: authorSize,
                      height: lineHeight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
