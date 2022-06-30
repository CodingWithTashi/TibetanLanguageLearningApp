import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/cubit/audio_cubit.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/game/game_home_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/snake_game/snake_game.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/provider/spelling_bee_provider.dart';
import 'package:tibetan_language_learning_app/presentation/game/spelling_bee/spelling_bee_page.dart';
import 'package:tibetan_language_learning_app/presentation/home.dart';
import 'package:tibetan_language_learning_app/presentation/language_type_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet/alphabet_detail_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/alphabet/alphabet_list_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/learn_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs/verb_detail_page.dart';
import 'package:tibetan_language_learning_app/presentation/learn/verbs/verbs_list_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_detail_page.dart';
import 'package:tibetan_language_learning_app/presentation/practice/practice_menu_page.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_case_item_list.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_cases_menu.dart';
import 'package:tibetan_language_learning_app/service/audio_service.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => LanguageTypePage(),
        );
      case HomePage.routeName:
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
          if (settings.arguments != null && settings.arguments is Alphabet) {
            return MaterialPageRoute(
              builder: (_) => BlocProvider<AudioCubit>(
                create: (context) =>
                    AudioCubit(AudioService(), audioPlayer: AudioPlayer()),
                child: AlphabetDetailPage(
                  alphabet: settings.arguments as Alphabet,
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
          if (settings.arguments != null && settings.arguments is Alphabet) {
            return MaterialPageRoute(
              builder: (_) => PracticeDetailPage(
                alphabet: settings.arguments as Alphabet,
              ),
            );
          }
          return _errorRoute();
        }

      case VerbListPage.routeName:
        return MaterialPageRoute(
          builder: (_) => VerbListPage(),
        );
      case VerbDetailPage.routeName:
        {
          if (settings.arguments != null && settings.arguments is Verb) {
            return MaterialPageRoute(
              builder: (_) => BlocProvider<AudioCubit>(
                create: (context) =>
                    AudioCubit(AudioService(), audioPlayer: AudioPlayer()),
                child: VerbDetailPage(
                  verb: settings.arguments as Verb,
                ),
              ),
            );
          }
          return _errorRoute();
        }
      case UseCaseMenuPage.routeName:
        return MaterialPageRoute(
          builder: (_) => UseCaseMenuPage(),
        );
      case UseCaseItemList.routeName:
        {
          if (settings.arguments != null && settings.arguments is UseCaseType) {
            return MaterialPageRoute(
              builder: (_) => BlocProvider<AudioCubit>(
                create: (context) =>
                    AudioCubit(AudioService(), audioPlayer: AudioPlayer()),
                child: UseCaseItemList(
                  type: settings.arguments as UseCaseType,
                ),
              ),
            );
          }
          return _errorRoute();
        }
      case GameHomePage.routeName:
        return MaterialPageRoute(
          builder: (_) => GameHomePage(),
        );
      case SpellingBeePage.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<SpellingBeeProvider>(
            create: (BuildContext context) => SpellingBeeProvider(),
            child: SpellingBeePage(),
          ),
        );
      case SnakeGamePage.routeName:
        return MaterialPageRoute(
          builder: (_) => SnakeGamePage(),
        );

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
