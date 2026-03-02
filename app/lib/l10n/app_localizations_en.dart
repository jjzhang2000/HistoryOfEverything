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

  @override
  String get aboutPageTitle => 'The History of\nEverything';

  @override
  String get version => 'v1.0';

  @override
  String get aboutDescription1 => 'The History of Everything is built with ';

  @override
  String get aboutDescription2 => ' by ';

  @override
  String get aboutDescription3 => '. The graphics and animations were created using tools by ';

  @override
  String get aboutDescription4 => '.\n\nInspired by the Kurzgesagt video ';

  @override
  String get aboutDescription5 => '.';

  @override
  String get flutter => 'Flutter';

  @override
  String get twoDimensions => '2Dimensions';

  @override
  String get historyAndFutureVideo => 'The History & Future of Everything';

  @override
  String get designedBy => 'Designed by';

  @override
  String get builtWith => 'Built with';

  @override
  String get universe => 'Universe';

  @override
  String get earth => 'Earth';

  @override
  String get life => 'Life';

  @override
  String get humanity => 'Humanity';

  @override
  String get showAll => 'Show All';

  @override
  String get collapse => 'Collapse';

  @override
  String get expand => 'Expand';

  @override
  String get noResults => 'No results found';

  @override
  String get searchHint => 'Search for events...';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get readMore => 'Read More';

  @override
  String get articleError => 'Failed to load article';
}