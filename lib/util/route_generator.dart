import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/bloc/snake_game/snake_game_bloc.dart';
import 'package:tibetan_language_learning_app/cubit/audio_cubit.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/presentation/game/game_home_page.dart';
import 'package:tibetan_language_learning_app/presentation/game/memory_match/memory_match_screen.dart';
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
import 'package:tibetan_language_learning_app/util/page_transitions.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return PageTransitions.fadeTransition(
          const LanguageTypePage(),
          settings: settings,
        );
      case HomePage.routeName:
        return PageTransitions.fadeScaleTransition(
          const HomePage(),
          settings: settings,
        );
      case LearnMenuPage.routeName:
        return PageTransitions.slideTransition(
          const LearnMenuPage(),
          settings: settings,
        );
      case AlphabetListPage.routeName:
        return PageTransitions.slideTransition(
          const AlphabetListPage(),
          settings: settings,
        );
      case AlphabetDetailPage.routeName:
        {
          if (settings.arguments != null && settings.arguments is Alphabet) {
            return PageTransitions.fadeScaleTransition(
              BlocProvider<AudioCubit>(
                create: (context) =>
                    AudioCubit(AudioService(), audioPlayer: AudioPlayer()),
                child: AlphabetDetailPage(
                  alphabet: settings.arguments as Alphabet,
                ),
              ),
              settings: settings,
            );
          }
          return _errorRoute();
        }
      case PracticeMenuPage.routeName:
        return PageTransitions.slideTransition(
          const PracticeMenuPage(),
          settings: settings,
        );
      case PracticeDetailPage.routeName:
        {
          if (settings.arguments != null && settings.arguments is Alphabet) {
            return PageTransitions.fadeScaleTransition(
              PracticeDetailPage(
                alphabet: settings.arguments as Alphabet,
              ),
              settings: settings,
            );
          }
          return _errorRoute();
        }

      case VerbListPage.routeName:
        return PageTransitions.slideTransition(
          const VerbListPage(),
          settings: settings,
        );
      case VerbDetailPage.routeName:
        {
          if (settings.arguments != null && settings.arguments is Verb) {
            return PageTransitions.fadeScaleTransition(
              BlocProvider<AudioCubit>(
                create: (context) =>
                    AudioCubit(AudioService(), audioPlayer: AudioPlayer()),
                child: VerbDetailPage(
                  verb: settings.arguments as Verb,
                ),
              ),
              settings: settings,
            );
          }
          return _errorRoute();
        }
      case UseCaseMenuPage.routeName:
        return PageTransitions.slideTransition(
          const UseCaseMenuPage(),
          settings: settings,
        );
      case UseCaseItemList.routeName:
        {
          if (settings.arguments != null && settings.arguments is UseCaseType) {
            return PageTransitions.fadeScaleTransition(
              BlocProvider<AudioCubit>(
                create: (context) =>
                    AudioCubit(AudioService(), audioPlayer: AudioPlayer()),
                child: UseCaseItemList(
                  type: settings.arguments as UseCaseType,
                ),
              ),
              settings: settings,
            );
          }
          return _errorRoute();
        }
      case GameHomePage.routeName:
        return PageTransitions.heroTransition(
          GameHomePage(),
          settings: settings,
        );
      case SpellingBeePage.routeName:
        return PageTransitions.fadeScaleTransition(
          ChangeNotifierProvider<SpellingBeeProvider>(
            create: (BuildContext context) => SpellingBeeProvider(),
            child: const SpellingBeePage(),
          ),
          settings: settings,
        );
      case SnakeGamePage.routeName:
        return PageTransitions.fadeScaleTransition(
          BlocProvider(
            create: (context) => SnakeGameBloc(),
            child: const SnakeGamePage(),
          ),
          settings: settings,
        );
      case MemoryMatchGameScreen.routeName:
        return PageTransitions.fadeScaleTransition(
          const MemoryMatchGameScreen(),
          settings: settings,
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
