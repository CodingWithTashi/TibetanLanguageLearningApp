import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bo.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bo'),
    Locale('en')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @learnLangauge.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnLangauge;

  /// No description provided for @practiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceLanguage;

  /// No description provided for @useCases.
  ///
  /// In en, this message translates to:
  /// **'Use Cases'**
  String get useCases;

  /// No description provided for @playGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get playGame;

  /// No description provided for @thirtyConsonant.
  ///
  /// In en, this message translates to:
  /// **'Tibetan 30 consonants'**
  String get thirtyConsonant;

  /// No description provided for @fourVowels.
  ///
  /// In en, this message translates to:
  /// **'Four Vowels'**
  String get fourVowels;

  /// No description provided for @fivePrefixes.
  ///
  /// In en, this message translates to:
  /// **'five Prefixes'**
  String get fivePrefixes;

  /// No description provided for @tenSuffixes.
  ///
  /// In en, this message translates to:
  /// **'Ten Suffixes'**
  String get tenSuffixes;

  /// No description provided for @twoPostFixes.
  ///
  /// In en, this message translates to:
  /// **'Two Postfixes'**
  String get twoPostFixes;

  /// No description provided for @ragoSurmounted.
  ///
  /// In en, this message translates to:
  /// **'12 Rango Surmounted'**
  String get ragoSurmounted;

  /// No description provided for @lagoSurmounted.
  ///
  /// In en, this message translates to:
  /// **'10 Lango Surmounted'**
  String get lagoSurmounted;

  /// No description provided for @sagoSarmounted.
  ///
  /// In en, this message translates to:
  /// **'11 Sago Surmounted'**
  String get sagoSarmounted;

  /// No description provided for @yatakSubJoin.
  ///
  /// In en, this message translates to:
  /// **'7 Yatak Subjoined'**
  String get yatakSubJoin;

  /// No description provided for @ratakSubJoined.
  ///
  /// In en, this message translates to:
  /// **'12 Ratak Subjoined'**
  String get ratakSubJoined;

  /// No description provided for @latakSubJoined.
  ///
  /// In en, this message translates to:
  /// **'6 Latak Subjoined'**
  String get latakSubJoined;

  /// No description provided for @verb.
  ///
  /// In en, this message translates to:
  /// **'Verbs'**
  String get verb;

  /// No description provided for @pronoun.
  ///
  /// In en, this message translates to:
  /// **'Pronoun'**
  String get pronoun;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Greetings'**
  String get greeting;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get color;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get number;

  /// No description provided for @spellingBeeContest.
  ///
  /// In en, this message translates to:
  /// **'Spelling Contest'**
  String get spellingBeeContest;

  /// No description provided for @spellingBee.
  ///
  /// In en, this message translates to:
  /// **'Spelling Bee'**
  String get spellingBee;

  /// No description provided for @snakeGame.
  ///
  /// In en, this message translates to:
  /// **'Snake Game'**
  String get snakeGame;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bo', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bo':
      return AppLocalizationsBo();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
