import 'package:get_it/get_it.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<AlphabetType>(AlphabetType());
}
