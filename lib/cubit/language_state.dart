part of 'language_cubit.dart';

@immutable
abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {
  LanguageLoading();
}

class LanguageLoaded extends LanguageState {
  final Locale locale;
  final String familyName;
  LanguageLoaded({required this.locale, required this.familyName});
}
