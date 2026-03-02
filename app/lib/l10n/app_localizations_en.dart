// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'History & Future of Everything';

  @override
  String get historyOfEverything => 'The History of Everything';

  @override
  String get yourFavorites => 'Your Favorites';

  @override
  String get noFavoritesYet => 'You haven\'t favorited anything yet.';

  @override
  String get about => 'About';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get search => 'Search';

  @override
  String get share => 'Share';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String yearsAgo(String years) {
    return '$years Ago';
  }

  @override
  String billionYears(String value) {
    return '$value Billion Years';
  }

  @override
  String millionYears(String value) {
    return '$value Million Years';
  }

  @override
  String thousandYears(String value) {
    return '$value Thousand Years';
  }

  @override
  String get years => 'Years';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownAgo => 'Unknown Ago';
}
