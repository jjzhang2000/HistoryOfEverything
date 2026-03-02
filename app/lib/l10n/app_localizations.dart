import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('zh')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'History & Future of Everything'**
  String get appTitle;

  /// Main title displayed in the menu
  ///
  /// In en, this message translates to:
  /// **'The History of Everything'**
  String get historyOfEverything;

  /// Title for the favorites page
  ///
  /// In en, this message translates to:
  /// **'Your Favorites'**
  String get yourFavorites;

  /// Message shown when user has no favorites
  ///
  /// In en, this message translates to:
  /// **'You haven\'t favorited anything yet.'**
  String get noFavoritesYet;

  /// Title for the about page
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Button text for retrying an action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Add to favorites button tooltip
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// Remove from favorites button tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// Time format showing years ago
  ///
  /// In en, this message translates to:
  /// **'{years} Ago'**
  String yearsAgo(String years);

  /// Format for billion years
  ///
  /// In en, this message translates to:
  /// **'{value} Billion Years'**
  String billionYears(String value);

  /// Format for million years
  ///
  /// In en, this message translates to:
  /// **'{value} Million Years'**
  String millionYears(String value);

  /// Format for thousand years
  ///
  /// In en, this message translates to:
  /// **'{value} Thousand Years'**
  String thousandYears(String value);

  /// The word 'Years'
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// Unknown value placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Unknown time ago
  ///
  /// In en, this message translates to:
  /// **'Unknown Ago'**
  String get unknownAgo;

  /// Title on the about page
  ///
  /// In en, this message translates to:
  /// **'The History of\nEverything'**
  String get aboutPageTitle;

  /// Version number
  ///
  /// In en, this message translates to:
  /// **'v1.0'**
  String get version;

  /// First part of about description
  ///
  /// In en, this message translates to:
  /// **'The History of Everything is built with '**
  String get aboutDescription1;

  /// Second part of about description
  ///
  /// In en, this message translates to:
  /// **' by '**
  String get aboutDescription2;

  /// Third part of about description
  ///
  /// In en, this message translates to:
  /// **'. The graphics and animations were created using tools by '**
  String get aboutDescription3;

  /// Fourth part of about description
  ///
  /// In en, this message translates to:
  /// **'.\n\nInspired by the Kurzgesagt video '**
  String get aboutDescription4;

  /// Last part of about description
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get aboutDescription5;

  /// Flutter framework name
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get flutter;

  /// Company name
  ///
  /// In en, this message translates to:
  /// **'2Dimensions'**
  String get twoDimensions;

  /// Video title that inspired the app
  ///
  /// In en, this message translates to:
  /// **'The History & Future of Everything'**
  String get historyAndFutureVideo;

  /// Label for designer credit
  ///
  /// In en, this message translates to:
  /// **'Designed by'**
  String get designedBy;

  /// Label for technology credit
  ///
  /// In en, this message translates to:
  /// **'Built with'**
  String get builtWith;

  /// Section title for universe events
  ///
  /// In en, this message translates to:
  /// **'Universe'**
  String get universe;

  /// Section title for earth events
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get earth;

  /// Section title for life events
  ///
  /// In en, this message translates to:
  /// **'Life'**
  String get life;

  /// Section title for humanity events
  ///
  /// In en, this message translates to:
  /// **'Humanity'**
  String get humanity;

  /// Button text to show all items
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// Button text to collapse section
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// Button text to expand section
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Placeholder text in search field
  ///
  /// In en, this message translates to:
  /// **'Search for events...'**
  String get searchHint;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Read more button text
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// Error message when article fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load article'**
  String get articleError;
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
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
