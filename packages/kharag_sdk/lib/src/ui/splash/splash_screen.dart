import 'package:flutter/material.dart';

import '../../core/models/sdk_config.dart';

/// Splash screen with configurable logo and animation
class KharagSplashScreen extends StatefulWidget {
  /// Splash configuration
  final SplashConfig config;

  /// Callback when splash is complete
  final VoidCallback onComplete;

  const KharagSplashScreen({
    required this.config,
    required this.onComplete,
    super.key,
  });

  @override
  State<KharagSplashScreen> createState() => _KharagSplashScreenState();
}

class _KharagSplashScreenState extends State<KharagSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.config.animationDuration),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Complete splash after minimum duration
    Future.delayed(
      Duration(milliseconds: widget.config.minDisplayDuration),
      widget.onComplete,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor =
        widget.config.backgroundColor ?? theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: widget.config.logo,
              ),
            ),

            // Loading indicator (if provided)
            if (widget.config.loadingIndicator != null) ...[
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: widget.config.loadingIndicator!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
