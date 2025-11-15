import 'package:flutter/material.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

import '../config/app_config.dart';

/// Wrapper for the about us screen
class AboutUsWrapper extends StatelessWidget {
  const AboutUsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const KharagAboutUsScreen(
      config: AppConfig.aboutUsConfig,
    );
  }
}
