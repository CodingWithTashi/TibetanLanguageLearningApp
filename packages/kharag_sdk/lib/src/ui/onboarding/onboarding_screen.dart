import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/models/onboarding.dart';

/// Onboarding screen with configurable pages
class KharagOnboardingScreen extends StatefulWidget {
  /// Onboarding configuration
  final OnboardingConfig config;

  /// Callback when onboarding is complete
  final VoidCallback onComplete;

  /// Callback when skip is pressed
  final VoidCallback? onSkip;

  const KharagOnboardingScreen({
    required this.config,
    required this.onComplete,
    this.onSkip,
    super.key,
  });

  @override
  State<KharagOnboardingScreen> createState() =>
      _KharagOnboardingScreenState();
}

class _KharagOnboardingScreenState extends State<KharagOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < widget.config.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == widget.config.pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (widget.config.showSkipButton && !isLastPage)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      widget.config.skipButtonText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 56),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.config.pages.length,
                itemBuilder: (context, index) {
                  final page = widget.config.pages[index];
                  return _OnboardingPageWidget(page: page);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: widget.config.indicatorBuilder != null
                  ? widget.config.indicatorBuilder!(
                      context,
                      _currentPage,
                      widget.config.pages.length,
                    )
                  : SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.config.pages.length,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: theme.colorScheme.primary,
                        dotColor: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
            ),

            // Next/Done button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLastPage
                        ? widget.config.doneButtonText
                        : widget.config.nextButtonText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual onboarding page widget
class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageWidget({
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: page.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Flexible(
            flex: 3,
            child: Center(child: page.image),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Flexible(
            flex: 2,
            child: SingleChildScrollView(
              child: Text(
                page.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
