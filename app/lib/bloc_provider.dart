import 'package:flutter/widgets.dart';
import "package:timeline/blocs/favorites_bloc.dart";
import 'package:timeline/search_manager.dart';
import 'package:timeline/timeline/timeline.dart';

/// Error state for the application initialization
enum AppInitState {
  loading,
  success,
  error,
}

/// This [InheritedWidget] wraps the whole app, and provides access
/// to the user's favorites through the [FavoritesBloc] 
/// and the [Timeline] object.
class BlocProvider extends InheritedWidget {
  final FavoritesBloc favoritesBloc;
  final Timeline timeline;
  final SearchManager searchManager;

  /// Error state notifier
  final ValueNotifier<AppInitState> initState = ValueNotifier(AppInitState.loading);
  
  /// Error message if initialization failed
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

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
  Future<void> _initializeData() async {
    try {
      final entries = await timeline.loadFromBundle("assets/timeline.json");
      
      if (entries.isEmpty) {
        initState.value = AppInitState.error;
        errorMessage.value = 'No timeline data found';
        return;
      }

      // Initialize timeline viewport
      final firstEntry = entries.first;
      final firstStart = firstEntry.start ?? 0.0;
      timeline.setViewport(
          start: firstStart * 2.0,
          end: firstStart,
          animate: true);
      timeline.advance(0.0, false);

      // Initialize favorites
      await favoritesBloc.init(entries);
      
      // Initialize search manager
      searchManager.init(entries);
      
      initState.value = AppInitState.success;
    } catch (error) {
      initState.value = AppInitState.error;
      errorMessage.value = 'Failed to load timeline: $error';
      debugPrint('Error loading timeline: $error');
    }
  }

  /// Retry initialization after an error
  void retryInitialization() {
    initState.value = AppInitState.loading;
    errorMessage.value = null;
    _initializeData();
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
  
  /// static accessor for the initialization state
  static ValueNotifier<AppInitState>? getInitState(BuildContext context) {
    BlocProvider? bp =
        context.dependOnInheritedWidgetOfExactType<BlocProvider>();
    return bp?.initState;
  }
  
  /// static accessor for the error message
  static ValueNotifier<String?>? getErrorMessage(BuildContext context) {
    BlocProvider? bp =
        context.dependOnInheritedWidgetOfExactType<BlocProvider>();
    return bp?.errorMessage;
  }
  
  /// static method to retry initialization
  static void retry(BuildContext context) {
    BlocProvider? bp =
        context.dependOnInheritedWidgetOfExactType<BlocProvider>();
    bp?.retryInitialization();
  }
}