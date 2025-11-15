import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

import 'config/app_config.dart';
import 'config/firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/app_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  final crashlytics = FirebaseCrashlyticsService();
  await crashlytics.initialize();

  runApp(
    const ProviderScope(
      child: KharagSdkExampleApp(),
    ),
  );
}

class KharagSdkExampleApp extends ConsumerStatefulWidget {
  const KharagSdkExampleApp({super.key});

  @override
  ConsumerState<KharagSdkExampleApp> createState() =>
      _KharagSdkExampleAppState();
}

class _KharagSdkExampleAppState extends ConsumerState<KharagSdkExampleApp> {
  bool _isInitialized = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    // Initialize RevenueCat
    final subscriptionService = ref.read(subscriptionServiceProvider);
    await subscriptionService.initialize(
      apiKey: AppConfig.revenueCatApiKey,
      enableDebugLogs: true,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kharag SDK Example',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: !_isInitialized
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _showSplash
              ? KharagSplashScreen(
                  config: AppConfig.splashConfig,
                  onComplete: _onSplashComplete,
                )
              : const AppNavigation(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
