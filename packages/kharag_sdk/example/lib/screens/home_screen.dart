import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

import '../config/app_config.dart';
import 'paywall_wrapper.dart';
import 'about_us_wrapper.dart';

/// Home screen - Main authenticated screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = ref.read(authServiceProvider);
      final analytics = ref.read(analyticsServiceProvider);

      final result = await authService.signOut();

      result.when(
        success: (_) async {
          await analytics.logEvent(name: AnalyticsEvents.logoutSuccess);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed out successfully'),
              ),
            );
          }
        },
        failure: (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    }
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaywallWrapper(),
      ),
    );
  }

  void _showAboutUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutUsWrapper(),
      ),
    );
  }

  Future<void> _testCrashlytics(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Crashlytics'),
        content: const Text(
          'This will log a test error to Firebase Crashlytics. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final crashlytics = ref.read(crashlyticsServiceProvider);
      await crashlytics.recordError(
        Exception('Test error from Kharag SDK Example'),
        StackTrace.current,
        reason: 'Testing Crashlytics integration',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test error logged to Crashlytics'),
          ),
        );
      }
    }
  }

  Future<void> _testAnalyticsEvent(BuildContext context, WidgetRef ref) async {
    final analytics = ref.read(analyticsServiceProvider);

    await analytics.logEvent(
      name: 'test_event',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'home_screen',
      },
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test event logged to Analytics'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kharag SDK Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleSignOut(context, ref),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not authenticated'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.colorScheme.primary,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  user.displayName?.substring(0, 1).toUpperCase() ??
                                      user.email.substring(0, 1).toUpperCase(),
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'User',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // SDK Features Section
                Text(
                  'SDK Features',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Feature Cards
                _FeatureCard(
                  icon: Icons.shopping_cart,
                  title: 'Subscription Paywall',
                  description: 'View subscription packages and make purchases',
                  onTap: () => _showPaywall(context),
                ),

                const SizedBox(height: 12),

                _FeatureCard(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  description: 'View app information and legal documents',
                  onTap: () => _showAboutUs(context),
                ),

                const SizedBox(height: 32),

                // Testing Section
                Text(
                  'Testing Tools',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                _FeatureCard(
                  icon: Icons.bug_report,
                  title: 'Test Crashlytics',
                  description: 'Log a test error to Firebase Crashlytics',
                  onTap: () => _testCrashlytics(context, ref),
                ),

                const SizedBox(height: 12),

                _FeatureCard(
                  icon: Icons.analytics,
                  title: 'Test Analytics Event',
                  description: 'Log a test event to Firebase Analytics',
                  onTap: () => _testAnalyticsEvent(context, ref),
                ),

                const SizedBox(height: 32),

                // Subscription Status
                _SubscriptionStatusCard(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature card widget
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subscription status card
class _SubscriptionStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionService = ref.watch(subscriptionServiceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Subscription Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: subscriptionService.getSubscriptionStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error loading subscription status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  );
                }

                final result = snapshot.data;
                if (result is Success<SubscriptionStatus>) {
                  final status = result.data;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusRow(
                        label: 'Status',
                        value: status.isActive ? 'Active' : 'Inactive',
                        isActive: status.isActive,
                      ),
                      if (status.isInTrialPeriod)
                        _StatusRow(
                          label: 'Trial',
                          value: 'Active',
                          isActive: true,
                        ),
                      if (status.activeProductId != null)
                        _StatusRow(
                          label: 'Product',
                          value: status.activeProductId!,
                        ),
                    ],
                  );
                }

                return Text(
                  'No active subscription',
                  style: theme.textTheme.bodyMedium,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Status row widget
class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? isActive;

  const _StatusRow({
    required this.label,
    required this.value,
    this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          Row(
            children: [
              if (isActive != null)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isActive! ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
