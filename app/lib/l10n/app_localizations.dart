import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list.
///
/// ## Overview
///
/// ### Localized Messages
///
/// Use the `AppLocalizations` class to access localized strings:
///
/// ```dart
/// AppLocalizations.of(context).yourFavorites
/// ```
///
/// The `[LocalizationsDelegate]` returned by `AppLocalizations.delegate`
/// loads the strings lazily.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.shortLocale(locale);

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of supported locales for this app's localizations.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en')
  ];

  /// The title of the application
  String get appTitle;

  /// Main title displayed in the menu
  String get historyOfEverything;

  /// Title for the favorites page
  String get yourFavorites;

  /// Message shown when user has no favorites
  String get noFavoritesYet;

  /// Title for the about page
  String get about;

  /// Button text for retrying an action
  String get retry;

  /// Loading indicator text
  String get loading;

  /// Error message when data fails to load
  String get errorLoadingData;

  /// Search label
  String get search;

  /// Share button text
  String get share;

  /// Add to favorites button tooltip
  String get addToFavorites;

  /// Remove from favorites button tooltip
  String get removeFromFavorites;

  /// Time format showing years ago
  String yearsAgo(String years);

  /// Format for billion years
  String billionYears(String value);

  /// Format for million years
  String millionYears(String value);

  /// Format for thousand years
  String thousandYears(String value);

  /// The word 'Years'
  String get years;

  /// Unknown value placeholder
  String get unknown;

  /// Unknown time ago
  String get unknownAgo;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'used.');
}