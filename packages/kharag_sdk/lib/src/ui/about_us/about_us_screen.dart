import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/sdk_config.dart';

/// About Us screen with configurable content
class KharagAboutUsScreen extends StatelessWidget {
  /// About Us configuration
  final AboutUsConfig config;

  const KharagAboutUsScreen({
    required this.config,
    super.key,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            if (config.logo != null) ...[
              Center(child: config.logo!),
              const SizedBox(height: 24),
            ],

            // App Name
            Center(
              child: Text(
                config.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Version
            Center(
              child: Text(
                'Version ${config.version}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Description
            Text(
              config.description,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Additional Content (Markdown)
            if (config.additionalContent != null) ...[
              MarkdownBody(
                data: config.additionalContent!,
                onTapLink: (text, href, title) {
                  if (href != null) {
                    _launchUrl(href);
                  }
                },
              ),
              const SizedBox(height: 32),
            ],

            // Contact Information
            if (config.supportEmail != null ||
                config.websiteUrl != null) ...[
              _SectionTitle(text: 'Contact'),
              const SizedBox(height: 16),

              if (config.supportEmail != null)
                _InfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: config.supportEmail!,
                  onTap: () => _launchUrl('mailto:${config.supportEmail}'),
                ),

              if (config.websiteUrl != null)
                _InfoTile(
                  icon: Icons.language,
                  title: 'Website',
                  subtitle: config.websiteUrl!,
                  onTap: () => _launchUrl(config.websiteUrl!),
                ),

              const SizedBox(height: 32),
            ],

            // Legal
            if (config.privacyPolicyUrl != null ||
                config.termsOfServiceUrl != null) ...[
              _SectionTitle(text: 'Legal'),
              const SizedBox(height: 16),

              if (config.privacyPolicyUrl != null)
                _InfoTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _launchUrl(config.privacyPolicyUrl!),
                ),

              if (config.termsOfServiceUrl != null)
                _InfoTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _launchUrl(config.termsOfServiceUrl!),
                ),

              const SizedBox(height: 32),
            ],

            // Social Links
            if (config.socialLinks != null &&
                config.socialLinks!.isNotEmpty) ...[
              _SectionTitle(text: 'Connect With Us'),
              const SizedBox(height: 16),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: config.socialLinks!.entries.map((entry) {
                  return _SocialButton(
                    label: entry.key,
                    url: entry.value,
                    onTap: () => _launchUrl(entry.value),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Information tile widget
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
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
    );
  }
}

/// Social button widget
class _SocialButton extends StatelessWidget {
  final String label;
  final String url;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}
