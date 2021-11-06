import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';
import 'package:tibetan_language_learning_app/servie_locater.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  late Locale locale;
  late String familyName;
  LanguageCubit(this.locale, this.familyName) : super(LanguageInitial()) {
    updateLocale(locale, familyName);
  }

  Future<void> updateLocale(Locale local, String family) async {
    emit(LanguageLoading());
    locale = local;
    familyName = family;
    getIt<SharedPreferences>().setString('familyName', familyName);
    emit(LanguageLoaded(locale: locale, familyName: familyName));
  }
}
