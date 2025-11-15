import 'package:flutter/widgets.dart';

/// Represents a single onboarding page
class OnboardingPage {
  /// Title of the onboarding page
  final String title;

  /// Description text
  final String description;

  /// Image widget (can be asset, network, or any widget)
  final Widget image;

  /// Optional background color
  final Color? backgroundColor;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    this.backgroundColor,
  });
}

/// Configuration for the onboarding flow
class OnboardingConfig {
  /// List of onboarding pages
  final List<OnboardingPage> pages;

  /// Whether to show skip button
  final bool showSkipButton;

  /// Skip button text
  final String skipButtonText;

  /// Next button text
  final String nextButtonText;

  /// Done/Get Started button text
  final String doneButtonText;

  /// Custom indicator builder (optional)
  final Widget Function(BuildContext context, int currentIndex, int totalPages)?
      indicatorBuilder;

  const OnboardingConfig({
    required this.pages,
    this.showSkipButton = true,
    this.skipButtonText = 'Skip',
    this.nextButtonText = 'Next',
    this.doneButtonText = 'Get Started',
    this.indicatorBuilder,
  });
}
