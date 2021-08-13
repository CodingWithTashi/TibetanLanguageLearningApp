import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tibetan_language_learning_app/cubit/audio_cubit.dart';
import 'package:tibetan_language_learning_app/presentation/home.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet_detail_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet_list_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_detail_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
      case LearnMenuPage.routeName:
        /*return PageRouteBuilder(
            opaque: true,
            transitionDuration: const Duration(seconds: 4),
            pageBuilder: (BuildContext context, _, __) {
              return new LearnMenuPage();
            },
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return new SlideTransition(
                child: child,
                position: new Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
              );
            });*/
        return MaterialPageRoute(
          builder: (_) => LearnMenuPage(),
        );
      case AlphabetListPage.routeName:
        return MaterialPageRoute(
          builder: (_) => AlphabetListPage(),
        );
      case AlphabetDetailPage.routeName:
        {
          if (settings.arguments != null && settings.arguments is String) {
            return MaterialPageRoute(
              builder: (_) => BlocProvider<AudioCubit>(
                create: (context) => AudioCubit(),
                child: AlphabetDetailPage(
                  alphabet: settings.arguments as String,
                ),
              ),
            );
          }
          return _errorRoute();
        }
      case PracticeMenuPage.routeName:
        return MaterialPageRoute(
          builder: (_) => PracticeMenuPage(),
        );
      case PracticeDetailPage.routeName:
        {
          if (settings.arguments != null && settings.arguments is String) {
            return MaterialPageRoute(
              builder: (_) => PracticeDetailPage(
                alphabet: settings.arguments as String,
              ),
            );
          }
          return _errorRoute();
        }
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Error occur'),
        ),
      );
    });
  }
}
