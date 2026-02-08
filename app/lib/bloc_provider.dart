import 'package:flutter/widgets.dart';
import "package:timeline/blocs/favorites_bloc.dart";
import 'package:timeline/search_manager.dart';
import 'package:timeline/timeline/timeline.dart';
import 'package:timeline/timeline/timeline_entry.dart';

/// This [InheritedWidget] wraps the whole app, and provides access
/// to the user's favorites through the [FavoritesBloc] 
/// and the [Timeline] object.
class BlocProvider extends InheritedWidget {
  final FavoritesBloc favoritesBloc;
  final Timeline timeline;
  final SearchManager searchManager;

  /// This widget is initialized when the app boots up, and thus loads the resources.
  /// The timeline.json file contains all the entries' data.
  /// Once those entries have been loaded, load also all the favorites.
  /// Lastly use the entries' references to load a local dictionary for the [SearchManager].
  BlocProvider(
      {super.key,
      FavoritesBloc? fb,
      Timeline? t,
      SearchManager? sm,
      required super.child,
      TargetPlatform platform = TargetPlatform.iOS})
      : timeline = t ?? Timeline(platform),
        favoritesBloc = fb ?? FavoritesBloc(),
        searchManager = sm ?? SearchManager.init() {
    _initializeData();
  }

  /// Initialize data by loading timeline entries, favorites, and search index
  void _initializeData() {
    timeline
        .loadFromBundle("assets/timeline.json")
        .then((List<TimelineEntry> entries) {
      if (entries.isEmpty) return;
      
      // Initialize timeline viewport
      timeline.setViewport(
          start: entries.first.start! * 2.0,
          end: entries.first.start!,
          animate: true);
      timeline.advance(0.0, false);

      // Initialize favorites
      favoritesBloc.init(entries);
      
      // Initialize search manager
      searchManager.init(entries);
    })
    .catchError((error) {
      print('Error loading timeline: $error');
      // Handle error gracefully - can show a user-friendly error message
    });
  }

  @override
  updateShouldNotify(InheritedWidget oldWidget) => true;

  /// static accessor for the [FavoritesBloc]. 
  /// e.g. [ArticleWidget] retrieves the favorites information using this static getter.
  static FavoritesBloc? favorites(BuildContext context) {
    BlocProvider? bp =
        context.dependOnInheritedWidgetOfExactType<BlocProvider>();
    return bp?.favoritesBloc;
  }

  /// static accessor for the [Timeline]. 
  /// e.g. [_MainMenuWidgetState.navigateToTimeline] uses this static getter to access build the [TimelineWidget].
  static Timeline? getTimeline(BuildContext context) {
    BlocProvider? bp =
        context.dependOnInheritedWidgetOfExactType<BlocProvider>();
    return bp?.timeline;
  }

  /// static accessor for the [SearchManager]. 
  /// e.g. [SearchWidget] uses this static getter to perform search operations.
  static SearchManager? getSearchManager(BuildContext context) {
    BlocProvider? bp =
        context.dependOnInheritedWidgetOfExactType<BlocProvider>();
    return bp?.searchManager;
  }
}
