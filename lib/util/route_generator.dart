import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_language_learning_app/bloc/snake_game/snake_game_bloc.dart';
import 'package:tibetan_language_learning_app/cubit/audio_cubit.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/model/book_item.dart';
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
import 'package:tibetan_language_learning_app/presentation/shop/book_detail_page.dart';
import 'package:tibetan_language_learning_app/presentation/shop/shop_page.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_case_item_list.dart';
import 'package:tibetan_language_learning_app/presentation/use_cases/use_cases_menu.dart';
import 'package:tibetan_language_learning_app/presentation/widget/parallax_background.dart';
import 'package:tibetan_language_learning_app/service/audio_service.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return ParallaxPageRoute(
          builder: (_) => LanguageTypePage(),
        );
      case HomePage.routeName:
        return ParallaxPageRoute(
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
        return ParallaxPageRoute(
          builder: (_) => LearnMenuPage(),
        );
      case AlphabetListPage.routeName:
        return ParallaxPageRoute(
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
        return ParallaxPageRoute(
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
        return ParallaxPageRoute(
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
        return ParallaxPageRoute(
          builder: (_) => UseCaseMenuPage(),
        );
      case UseCaseItemList.routeName:
        {
          if (settings.arguments != null && settings.arguments is UseCaseType) {
            return ParallaxPageRoute(
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
        return ParallaxPageRoute(
          builder: (_) => const GameHomePage(),
        );
      case SpellingBeePage.routeName:
        return ParallaxPageRoute(
          builder: (_) => ChangeNotifierProvider<SpellingBeeProvider>(
            create: (BuildContext context) => SpellingBeeProvider(),
            child: SpellingBeePage(),
          ),
        );
      case SnakeGamePage.routeName:
        return ParallaxPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => SnakeGameBloc(),
            child: SnakeGamePage(),
          ),
        );
      case MemoryMatchGameScreen.routeName:
        return ParallaxPageRoute(
          builder: (_) => const MemoryMatchGameScreen(),
        );
      case ShopPage.routeName:
        return ParallaxPageRoute(
          builder: (_) => const ShopPage(),
        );
      case BookDetailPage.routeName:
        if (args is BookItem) {
          return ParallaxPageRoute(
            builder: (_) => BookDetailPage(book: args),
          );
        }
        return _errorRoute();

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
