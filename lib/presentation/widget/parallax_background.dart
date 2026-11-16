import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Tracks how deep the user is in the page stack, as a fractional value that
/// follows each page's transition animation (including the iOS back swipe).
///
/// Only [PageRoute]s count, so dialogs and bottom sheets don't move the
/// background.
class ParallaxDepthObserver extends NavigatorObserver with ChangeNotifier {
  final List<PageRoute<dynamic>> _routes = <PageRoute<dynamic>>[];

  // Pages that took another page's place (pushReplacement). They sit on the
  // level of the page they replaced, so their push must not move anything.
  final Set<Route<dynamic>> _replacements = <Route<dynamic>>{};

  /// 0 on the first page, 1 on a page pushed on top of it, and so on;
  /// fractional while a transition is running.
  double get depth {
    double sum = 0;
    for (final route in _routes) {
      sum += _presence(route);
    }
    return math.max(0, sum - 1);
  }

  // How much of [route] is on screen: 0 while it is still off to the side,
  // 1 once its push transition has finished. Uses the same curve as the
  // Cupertino page slide so the background keeps pace with the pages.
  double _presence(PageRoute<dynamic> route) {
    final animation = route.animation;
    if (animation == null) return 1;
    if (navigator?.userGestureInProgress ?? false) return animation.value;
    if (animation.status == AnimationStatus.reverse) {
      return Curves.fastEaseInToSlowEaseOut.flipped.transform(animation.value);
    }
    if (_replacements.contains(route)) return 1;
    return Curves.fastEaseInToSlowEaseOut.transform(animation.value);
  }

  void _add(Route<dynamic> route) {
    if (route is! PageRoute || _routes.contains(route)) return;
    _routes.add(route);
    route.animation?.addListener(notifyListeners);
    notifyListeners();
  }

  void _remove(Route<dynamic> route) {
    _replacements.remove(route);
    if (route is! PageRoute || !_routes.remove(route)) return;
    route.animation?.removeListener(notifyListeners);
    notifyListeners();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Keep counting the page until it has finished sliding away.
    final animation = route is TransitionRoute ? route.animation : null;
    if (animation == null || animation.isDismissed) {
      _remove(route);
      return;
    }
    late final AnimationStatusListener listener;
    listener = (status) {
      if (status == AnimationStatus.dismissed) {
        animation.removeStatusListener(listener);
        _remove(route);
      }
    };
    animation.addStatusListener(listener);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _remove(oldRoute);
    if (newRoute is PageRoute && oldRoute is PageRoute) {
      _replacements.add(newRoute);
    }
    if (newRoute != null) _add(newRoute);
  }

  @override
  void didStartUserGesture(
          Route<dynamic> route, Route<dynamic>? previousRoute) =>
      notifyListeners();

  @override
  void didStopUserGesture() => notifyListeners();

  @override
  void dispose() {
    for (final route in _routes) {
      route.animation?.removeListener(notifyListeners);
    }
    _routes.clear();
    _replacements.clear();
    super.dispose();
  }
}

/// One background image shared by every page, drawn behind the [Navigator].
///
/// Pages with a transparent [Scaffold] show it through. As pages are pushed
/// the image pans sideways at about half the speed of the page slide, which
/// gives the parallax effect. At rest the first page sees the left side of
/// the picture, the next level the middle and deeper levels the right side.
class ParallaxBackground extends StatelessWidget {
  const ParallaxBackground({
    Key? key,
    required this.observer,
    required this.child,
  }) : super(key: key);

  final ParallaxDepthObserver observer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Shown for the first frames, until the image has been decoded.
        ColoredBox(color: Theme.of(context).primaryColor),
        Flow(
          delegate: _PanDelegate(observer),
          children: [
            RepaintBoundary(
              child: Image.asset(
                'assets/images/tree.jpg',
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

class _PanDelegate extends FlowDelegate {
  _PanDelegate(this.observer) : super(repaint: observer);

  final ParallaxDepthObserver observer;

  /// Depth at which the image reaches its right edge.
  static const double _maxDepth = 2;

  /// The image is always at least this much wider than the screen, so there
  /// is room to pan on tablets and in landscape too.
  static const double _minWidthFactor = 1.2;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    final side =
        math.max(constraints.maxHeight, constraints.maxWidth * _minWidthFactor);
    return BoxConstraints.tight(Size.square(side));
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final screen = context.size;
    final image = context.getChildSize(0)!;
    final t = (observer.depth / _maxDepth).clamp(0.0, 1.0);
    final dx = -(image.width - screen.width) * t;
    final dy = -(image.height - screen.height) / 2;
    context.paintChild(0, transform: Matrix4.translationValues(dx, dy, 0));
  }

  @override
  bool shouldRepaint(_PanDelegate oldDelegate) =>
      oldDelegate.observer != observer;

  @override
  bool shouldRelayout(_PanDelegate oldDelegate) => false;
}

/// A [MaterialPageRoute] for pages that sit on the shared
/// [ParallaxBackground].
///
/// These pages are see-through, so the page underneath must not stay
/// partly on screen. The normal iOS-style transition only moves it a third
/// of the way out, and then it would vanish in one frame when the
/// transition ends. Instead, the page underneath is pushed all the way off
/// screen, on the same curve as the arriving page. The two pages stay edge
/// to edge, like a carousel, while the background pans more slowly behind
/// them.
class ParallaxPageRoute<T> extends MaterialPageRoute<T> {
  ParallaxPageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return _SlideOut(
      animation: secondaryAnimation,
      // Follow the finger exactly during an iOS back swipe, as the
      // arriving page does.
      linear: navigator?.userGestureInProgress ?? false,
      // The theme's transition still slides this page in and handles the
      // back swipe; only its own one-third slide-out is switched off.
      child: super.buildTransitions(
          context, animation, kAlwaysDismissedAnimation, child),
    );
  }
}

/// Slides [child] fully off to the left as [animation] runs from 0 to 1.
/// Uses the curve of the Cupertino page slide, so it moves in step with the
/// page coming in on top.
class _SlideOut extends StatefulWidget {
  const _SlideOut({
    required this.animation,
    required this.linear,
    required this.child,
  });

  final Animation<double> animation;
  final bool linear;
  final Widget child;

  @override
  State<_SlideOut> createState() => _SlideOutState();
}

class _SlideOutState extends State<_SlideOut> {
  static final Animatable<Offset> _offLeft =
      Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0));

  CurvedAnimation? _curve;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  @override
  void didUpdateWidget(_SlideOut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.linear != widget.linear) {
      _curve?.dispose();
      _setUp();
    }
  }

  @override
  void dispose() {
    _curve?.dispose();
    super.dispose();
  }

  void _setUp() {
    _curve = widget.linear
        ? null
        : CurvedAnimation(
            parent: widget.animation,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          );
    _position = (_curve ?? widget.animation).drive(_offLeft);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _position,
      textDirection: Directionality.of(context),
      transformHitTests: false,
      child: widget.child,
    );
  }
}
