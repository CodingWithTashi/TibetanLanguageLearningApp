import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/presentation/home.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/route_generator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //if (kIsWeb) MobileAds.instance.initialize();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tibetan Language Learning App',
      theme: ThemeData(
        fontFamily: 'jomolhari',
        primarySwatch: ApplicationUtil.createMaterialColor(Color(0xff57612F)),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
