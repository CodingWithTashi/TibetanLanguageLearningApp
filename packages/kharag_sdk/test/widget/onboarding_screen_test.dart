import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

void main() {
  late OnboardingConfig testConfig;

  setUp(() {
    testConfig = OnboardingConfig(
      pages: [
        OnboardingPage(
          title: 'Page 1',
          description: 'Description 1',
          image: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        ),
        OnboardingPage(
          title: 'Page 2',
          description: 'Description 2',
          image: Container(
            width: 100,
            height: 100,
            color: Colors.red,
          ),
        ),
        OnboardingPage(
          title: 'Page 3',
          description: 'Description 3',
          image: Container(
            width: 100,
            height: 100,
            color: Colors.green,
          ),
        ),
      ],
      showSkipButton: true,
      skipButtonText: 'Skip',
      nextButtonText: 'Next',
      doneButtonText: 'Done',
    );
  });

  Widget buildTestWidget({
    required OnboardingConfig config,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) {
    return MaterialApp(
      home: KharagOnboardingScreen(
        config: config,
        onComplete: onComplete ?? () {},
        onSkip: onSkip,
      ),
    );
  }

  group('KharagOnboardingScreen - UI Elements', () {
    testWidgets('should display first page content', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(config: testConfig));

      // Assert
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('should show skip button when enabled', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(config: testConfig));

      // Assert
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('should hide skip button when disabled', (tester) async {
      // Arrange
      final config = OnboardingConfig(
        pages: testConfig.pages,
        showSkipButton: false,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(config: config));

      // Assert
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('should display page indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(config: testConfig));

      // Assert
      // SmoothPageIndicator should be present
      expect(
        find.byWidgetPredicate(
          (widget) => widget.toString().contains('SmoothPageIndicator'),
        ),
        findsOneWidget,
      );
    });
  });

  group('KharagOnboardingScreen - Navigation', () {
    testWidgets('should navigate to next page on Next button tap',
        (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget(config: testConfig));

      // Verify initial state
      expect(find.text('Page 1'), findsOneWidget);

      // Act
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
    });

    testWidgets('should show Done button on last page', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget(config: testConfig));

      // Act - Navigate to last page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 3'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('should call onComplete when Done is tapped',
        (tester) async {
      // Arrange
      var completeCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          config: testConfig,
          onComplete: () => completeCalled = true,
        ),
      );

      // Navigate to last page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Assert
      expect(completeCalled, isTrue);
    });

    testWidgets('should call onSkip when Skip is tapped', (tester) async {
      // Arrange
      var skipCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          config: testConfig,
          onSkip: () => skipCalled = true,
        ),
      );

      // Act
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Assert
      expect(skipCalled, isTrue);
    });

    testWidgets('should hide skip button on last page', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget(config: testConfig));

      // Navigate to last page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Skip'), findsNothing);
    });
  });

  group('KharagOnboardingScreen - Page Swiping', () {
    testWidgets('should navigate by swiping pages', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget(config: testConfig));

      // Verify initial state
      expect(find.text('Page 1'), findsOneWidget);

      // Act - Swipe left to next page
      await tester.drag(
        find.byType(PageView),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 2'), findsOneWidget);
    });
  });

  group('KharagOnboardingScreen - Custom Button Text', () {
    testWidgets('should use custom button text', (tester) async {
      // Arrange
      final config = OnboardingConfig(
        pages: testConfig.pages,
        skipButtonText: 'Custom Skip',
        nextButtonText: 'Custom Next',
        doneButtonText: 'Custom Done',
      );

      // Act
      await tester.pumpWidget(buildTestWidget(config: config));

      // Assert
      expect(find.text('Custom Skip'), findsOneWidget);
      expect(find.text('Custom Next'), findsOneWidget);

      // Navigate to last page
      await tester.tap(find.text('Custom Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom Next'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Done'), findsOneWidget);
    });
  });

  group('KharagOnboardingScreen - Theme Integration', () {
    testWidgets('should use theme colors', (tester) async {
      // Arrange
      const primaryColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          ),
          home: KharagOnboardingScreen(
            config: testConfig,
            onComplete: () {},
          ),
        ),
      );

      // Act & Assert
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );

      expect(
        nextButton.style?.backgroundColor?.resolve({}),
        isNotNull,
      );
    });
  });
}
