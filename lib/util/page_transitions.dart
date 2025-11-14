import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/util/app_theme.dart';

/// Custom page transitions for smooth, professional navigation
/// Provides various transition effects for different contexts

class PageTransitions {
  /// Smooth slide transition from right to left
  static Route<T> slideTransition<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppTheme.animationNormal,
      reverseTransitionDuration: AppTheme.animationNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: AppTheme.defaultCurve));
        final offsetAnimation = animation.drive(tween);

        // Add fade for smoothness
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
          ),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Fade transition with scale effect
  static Route<T> fadeScaleTransition<T>(Widget page,
      {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppTheme.animationNormal,
      reverseTransitionDuration: AppTheme.animationNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: AppTheme.smoothCurve,
        );

        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppTheme.smoothCurve,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Slide up transition (for bottom sheets or dialogs)
  static Route<T> slideUpTransition<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppTheme.animationNormal,
      reverseTransitionDuration: AppTheme.animationNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: AppTheme.defaultCurve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Shared axis transition (material design 3 style)
  static Route<T> sharedAxisTransition<T>(Widget page,
      {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppTheme.animationNormal,
      reverseTransitionDuration: AppTheme.animationNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Outgoing page
        final outgoingAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: AppTheme.defaultCurve,
          ),
        );

        final outgoingFade = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
          ),
        );

        // Incoming page
        final incomingAnimation = Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppTheme.defaultCurve,
          ),
        );

        final incomingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: incomingAnimation,
          child: FadeTransition(
            opacity: incomingFade,
            child: child,
          ),
        );
      },
    );
  }

  /// Smooth fade transition (simple and elegant)
  static Route<T> fadeTransition<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppTheme.animationNormal,
      reverseTransitionDuration: AppTheme.animationNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AppTheme.smoothCurve,
          ),
          child: child,
        );
      },
    );
  }

  /// Custom hero-like transition with scale and fade
  static Route<T> heroTransition<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
          ),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Default transition based on context
  static Route<T> defaultTransition<T>(Widget page, {RouteSettings? settings}) {
    return fadeScaleTransition<T>(page, settings: settings);
  }
}

/// Extension to easily navigate with custom transitions
extension NavigationExtension on BuildContext {
  Future<T?> pushWithTransition<T>(
    Widget page, {
    TransitionType type = TransitionType.fadeScale,
  }) {
    Route<T> route;
    switch (type) {
      case TransitionType.slide:
        route = PageTransitions.slideTransition<T>(page);
        break;
      case TransitionType.fadeScale:
        route = PageTransitions.fadeScaleTransition<T>(page);
        break;
      case TransitionType.slideUp:
        route = PageTransitions.slideUpTransition<T>(page);
        break;
      case TransitionType.sharedAxis:
        route = PageTransitions.sharedAxisTransition<T>(page);
        break;
      case TransitionType.fade:
        route = PageTransitions.fadeTransition<T>(page);
        break;
      case TransitionType.hero:
        route = PageTransitions.heroTransition<T>(page);
        break;
    }
    return Navigator.of(this).push(route);
  }
}

enum TransitionType {
  slide,
  fadeScale,
  slideUp,
  sharedAxis,
  fade,
  hero,
}
