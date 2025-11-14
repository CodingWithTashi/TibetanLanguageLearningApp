import 'package:flutter/material.dart';

/// Enhanced theme system with modern design tokens
/// Professional color palette, spacing, and design patterns
class AppTheme {
  // Design Tokens - Colors
  static const Color primaryColor = Color(0xFF57612F);
  static const Color primaryLight = Color(0xFF7A8448);
  static const Color primaryDark = Color(0xFF3E4621);

  static const Color accentColor = Color(0xFFD4AF37);
  static const Color accentLight = Color(0xFFE5C563);
  static const Color accentDark = Color(0xFFB8961F);

  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFADB5BD);

  // Spacing System
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // Elevation/Shadows
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      offset: const Offset(0, 10),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Enhanced card decorations with modern shadow
  static BoxDecoration getCardDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = radiusM,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1)
          : null,
      boxShadow: withShadow ? shadowMedium : null,
    );
  }

  // Primary button decoration with gradient
  static BoxDecoration getPrimaryButtonDecoration({
    double borderRadius = radiusM,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          primaryDark,
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isPressed ? shadowSmall : shadowMedium,
    );
  }

  // Neumorphic-inspired decoration (subtle, modern)
  static BoxDecoration getNeumorphicDecoration(
    BuildContext context, {
    bool isPressed = false,
    Color? color,
  }) {
    final baseColor = color ?? primaryColor;
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(radiusM),
      boxShadow: isPressed
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: baseColor.withOpacity(0.5),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
    );
  }

  // Glass morphism effect
  static BoxDecoration getGlassDecoration({
    Color? color,
    double borderRadius = radiusM,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: shadowMedium,
    );
  }

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

  // Text Styles
  static TextStyle heading1 = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle heading3 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle buttonText = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textLight,
    letterSpacing: 0.5,
  );

  static TextStyle caption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textHint,
  );
}
