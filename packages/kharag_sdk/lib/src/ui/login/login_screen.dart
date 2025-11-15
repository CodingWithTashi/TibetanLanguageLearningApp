import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/models/result.dart';
import '../../core/models/user.dart';
import '../../core/providers/kharag_providers.dart';

/// Login screen configuration
class LoginConfig {
  /// App logo
  final Widget? logo;

  /// Title text
  final String title;

  /// Subtitle text
  final String subtitle;

  /// Google Sign-In button text
  final String googleButtonText;

  /// Custom background color
  final Color? backgroundColor;

  /// Show loading indicator
  final bool showLoading;

  const LoginConfig({
    this.logo,
    this.title = 'Welcome Back',
    this.subtitle = 'Sign in to continue',
    this.googleButtonText = 'Sign in with Google',
    this.backgroundColor,
    this.showLoading = true,
  });
}

/// Login screen with Google Sign-In
class KharagLoginScreen extends ConsumerStatefulWidget {
  /// Login configuration
  final LoginConfig config;

  /// Callback when login is successful
  final void Function(KharagUser user)? onLoginSuccess;

  /// Callback when login fails
  final void Function(String error)? onLoginError;

  const KharagLoginScreen({
    required this.config,
    this.onLoginSuccess,
    this.onLoginError,
    super.key,
  });

  @override
  ConsumerState<KharagLoginScreen> createState() => _KharagLoginScreenState();
}

class _KharagLoginScreenState extends ConsumerState<KharagLoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final authService = ref.read(authServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);

    // Log analytics
    await analyticsService.logEvent(
      name: AnalyticsEvents.loginStarted,
      parameters: {'method': 'google'},
    );

    final result = await authService.signIn(AuthProviderType.google);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    result.when(
      success: (user) async {
        // Log success
        await analyticsService.logLogin('google');
        await analyticsService.logEvent(
          name: AnalyticsEvents.loginSuccess,
          parameters: {'method': 'google'},
        );

        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!(user);
        }
      },
      failure: (failure) async {
        // Log failure
        await analyticsService.logEvent(
          name: AnalyticsEvents.loginFailed,
          parameters: {
            'method': 'google',
            'error': failure.message,
          },
        );

        // Don't show error for cancelled sign-in
        if (failure is! CancelledFailure) {
          if (widget.onLoginError != null) {
            widget.onLoginError!(failure.message);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor =
        widget.config.backgroundColor ?? theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              if (widget.config.logo != null) ...[
                widget.config.logo!,
                const SizedBox(height: 32),
              ],

              // Title
              Text(
                widget.config.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                widget.config.subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Google Sign-In Button
              _GoogleSignInButton(
                text: widget.config.googleButtonText,
                isLoading: _isLoading && widget.config.showLoading,
                onPressed: _isLoading ? null : _handleGoogleSignIn,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google Sign-In Button Widget
class _GoogleSignInButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GoogleSignInButton({
    required this.text,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Icon (using Container as placeholder - you can use an SVG)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.g_mobiledata,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
