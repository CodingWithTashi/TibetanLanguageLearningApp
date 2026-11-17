import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibetan_language_learning_app/cubit/language_cubit.dart';
import 'package:tibetan_language_learning_app/game_bloc/game_bloc.dart';
import 'package:tibetan_language_learning_app/l10n/app_localizations.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';
import 'package:tibetan_language_learning_app/l10n/localization_delegate.dart';
import 'package:tibetan_language_learning_app/presentation/widget/parallax_background.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';
import 'package:tibetan_language_learning_app/util/route_generator.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
    // MobileAds.instance.initialize();
  }
  setupLocator();
  GetIt.I.isReady<SharedPreferences>().then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameBloc>(
          create: (context) => GameBloc()..add(LoadGames()),
        ),
        BlocProvider<LanguageCubit>(
          create: (context) => LanguageCubit(
            Locale.fromSubtags(languageCode: "en"),
            AppConstant.ROBOTO_FAMILY,
          ),
        ),
      ],
      child: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // One instance for the app's lifetime: a new observer on every locale
  // change would lose track of the pages already on the stack.
  final ParallaxDepthObserver _parallaxObserver = ParallaxDepthObserver();

  @override
  void dispose() {
    _parallaxObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return MaterialApp(
          locale: BlocProvider.of<LanguageCubit>(context).locale,
          debugShowCheckedModeBanner: false,
          title: 'Tibetan Language Learning App',
          localizationsDelegates: [
            MaterialLocalizationTbDelegate(),
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
            GlobalCupertinoLocalizations.delegate,
            //GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: L10n.all,
          theme: ThemeData(
            fontFamily: BlocProvider.of<LanguageCubit>(context).familyName,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xff57612F),
            ),
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            }),
          ),
          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
          navigatorObservers: [_parallaxObserver],
          builder: (context, child) => ParallaxBackground(
            observer: _parallaxObserver,
            child: child!,
          ),
        );
      },
    );
  }
}
