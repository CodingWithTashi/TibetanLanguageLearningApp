import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  late Locale locale;
  LanguageCubit(this.locale) : super(LanguageInitial()) {
    updateLocale(locale);
  }

  Future<void> updateLocale(Locale local) async {
    emit(LanguageLoading());
    locale = local;
    emit(LanguageLoaded(locale: locale));
  }
}
