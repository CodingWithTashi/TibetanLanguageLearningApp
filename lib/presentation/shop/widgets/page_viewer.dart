import 'package:material_ui/material_ui.dart';

import '../../game/widget/game_ui.dart';
import 'book_cover.dart';

/// Full-screen pages to swipe through and zoom (pinch or double-tap).
/// Completes with the page that was showing when the viewer was closed.
Future<int?> showPageViewer(
  BuildContext context, {
  required String title,
  required List<String> pages,
  int initialPage = 0,
}) {
  return showGeneralDialog<int>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.96),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => PageViewer(
      title: title,
      pages: pages,
      initialPage: initialPage,
    ),
    transitionBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class PageViewer extends StatefulWidget {
  const PageViewer({
    Key? key,
    required this.title,
    required this.pages,
    this.initialPage = 0,
  }) : super(key: key);

  final String title;
  final List<String> pages;
  final int initialPage;

  @override
  State<PageViewer> createState() => _PageViewerState();
}

class _PageViewerState extends State<PageViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialPage);
  late int _page = widget.initialPage;
  bool _zoomed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) => _controller.animateToPage(page,
      duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final palette = GamePalette.of(context);
    final count = widget.pages.length;
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_page + 1} / $count',
                    key: const ValueKey('viewer-counter'),
                    style: TextStyle(
                      color: palette.cream,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GameRoundButton(
                    icon: Icons.close_rounded,
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(_page),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    // While zoomed in, a drag moves around the page instead.
                    physics: _zoomed
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    itemCount: count,
                    onPageChanged: (i) => setState(() {
                      _page = i;
                      _zoomed = false;
                    }),
                    itemBuilder: (context, i) => _ZoomablePage(
                      path: widget.pages[i],
                      label: 'Page ${i + 1} of $count',
                      onZoomChanged: (zoomed) {
                        if (i == _page && zoomed != _zoomed) {
                          setState(() => _zoomed = zoomed);
                        }
                      },
                    ),
                  ),
                  if (wide && _page > 0)
                    _Arrow(
                      alignment: Alignment.centerLeft,
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Previous page',
                      onPressed: () => _go(_page - 1),
                    ),
                  if (wide && _page < count - 1)
                    _Arrow(
                      alignment: Alignment.centerRight,
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'Next page',
                      onPressed: () => _go(_page + 1),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                _zoomed
                    ? 'Double-tap to zoom out'
                    : 'Pinch or double-tap to zoom',
                style: TextStyle(
                    color: palette.cream.withValues(alpha: 0.8), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.alignment,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Alignment alignment;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GameRoundButton(
          icon: icon,
          tooltip: tooltip,
          size: 48,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _ZoomablePage extends StatefulWidget {
  const _ZoomablePage({
    required this.path,
    required this.label,
    required this.onZoomChanged,
  });

  final String path;
  final String label;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage>
    with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  Animation<Matrix4>? _zoomAnimation;
  Offset _tapPosition = Offset.zero;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_reportZoom);
    _zoom.addListener(() {
      final animation = _zoomAnimation;
      if (animation != null) _transform.value = animation.value;
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _reportZoom() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) {
      _zoomed = zoomed;
      widget.onZoomChanged(zoomed);
    }
  }

  void _toggleZoom() {
    final Matrix4 end;
    if (_zoomed) {
      end = Matrix4.identity();
    } else {
      const scale = 2.5;
      final p = _tapPosition;
      end = Matrix4.identity()
        ..translateByDouble(-p.dx * (scale - 1), -p.dy * (scale - 1), 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
    }
    _zoomAnimation = Matrix4Tween(begin: _transform.value, end: end)
        .animate(CurvedAnimation(parent: _zoom, curve: Curves.easeOutCubic));
    _zoom.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _tapPosition = details.localPosition,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Semantics(
            image: true,
            label: widget.label,
            child: Image(
              image: bookImage(widget.path),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined,
                    color: Colors.white70, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
