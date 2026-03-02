import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline/blocs/favorites_bloc.dart';
import 'package:timeline/search_manager.dart';
import 'package:timeline/timeline/timeline.dart';
import 'package:timeline/timeline/timeline_entry.dart';

/// Application initialization state
enum AppInitState {
  loading,
  success,
  error,
}

/// State class for app initialization
class AppInitData {
  final AppInitState state;
  final String? errorMessage;
  final List<TimelineEntry> entries;

  const AppInitData({
    this.state = AppInitState.loading,
    this.errorMessage,
    this.entries = const [],
  });

  AppInitData copyWith({
    AppInitState? state,
    String? errorMessage,
    List<TimelineEntry>? entries,
  }) {
    return AppInitData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      entries: entries ?? this.entries,
    );
  }
}

/// State notifier for app initialization
class AppInitNotifier extends StateNotifier<AppInitData> {
  final Ref ref;

  AppInitNotifier(this.ref) : super(const AppInitData()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final timeline = ref.read(timelineProvider);
      final entries = await timeline.loadFromBundle('assets/timeline.json');

      if (entries.isEmpty) {
        state = AppInitData(
          state: AppInitState.error,
          errorMessage: 'No timeline data found',
        );
        return;
      }

      // Initialize timeline viewport
      final firstEntry = entries.first;
      final firstStart = firstEntry.start ?? 0.0;
      timeline.setViewport(
        start: firstStart * 2.0,
        end: firstStart,
        animate: true,
      );
      timeline.advance(0.0, false);

      // Initialize favorites
      final favoritesBloc = ref.read(favoritesBlocProvider);
      await favoritesBloc.init(entries);

      // Initialize search manager
      final searchManager = ref.read(searchManagerProvider);
      searchManager.init(entries);

      state = AppInitData(
        state: AppInitState.success,
        entries: entries,
      );
    } catch (error) {
      state = AppInitData(
        state: AppInitState.error,
        errorMessage: 'Failed to load timeline: $error',
      );
      debugPrint('Error loading timeline: $error');
    }
  }

  void retry() {
    state = const AppInitData(state: AppInitState.loading);
    _initialize();
  }
}

/// Provider for platform target
final platformProvider = Provider<TargetPlatform>((ref) {
  return TargetPlatform.iOS;
});

/// Provider for Timeline instance
final timelineProvider = Provider<Timeline>((ref) {
  final platform = ref.watch(platformProvider);
  return Timeline(platform);
});

/// Provider for FavoritesBloc instance
final favoritesBlocProvider = Provider<FavoritesBloc>((ref) {
  return FavoritesBloc();
});

/// Provider for SearchManager instance
final searchManagerProvider = Provider<SearchManager>((ref) {
  return SearchManager.init();
});

/// Provider for app initialization state
final appInitProvider = StateNotifierProvider<AppInitNotifier, AppInitData>((ref) {
  return AppInitNotifier(ref);
});

/// Convenience providers for specific state aspects
final appInitStateProvider = Provider<AppInitState>((ref) {
  return ref.watch(appInitProvider).state;
});

final appErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(appInitProvider).errorMessage;
});

final timelineEntriesProvider = Provider<List<TimelineEntry>>((ref) {
  return ref.watch(appInitProvider).entries;
});

/// Provider for checking if app is initialized
final isInitializedProvider = Provider<bool>((ref) {
  return ref.watch(appInitStateProvider) == AppInitState.success;
});

/// Notifier provider for favorites list
final favoritesListProvider = StateNotifierProvider<FavoritesListNotifier, List<TimelineEntry>>((ref) {
  return FavoritesListNotifier(ref);
});

class FavoritesListNotifier extends StateNotifier<List<TimelineEntry>> {
  final Ref ref;

  FavoritesListNotifier(this.ref) : super([]);

  void setFavorites(List<TimelineEntry> favorites) {
    state = favorites;
  }

  void addFavorite(TimelineEntry entry) {
    if (!state.any((e) => e.label == entry.label)) {
      final newFavorites = [...state, entry];
      newFavorites.sort((a, b) => (a.start ?? 0).compareTo(b.start ?? 0));
      state = newFavorites;
    }
  }

  void removeFavorite(TimelineEntry entry) {
    state = state.where((e) => e.label != entry.label).toList();
  }

  bool isFavorite(TimelineEntry entry) {
    return state.any((e) => e.label == entry.label);
  }
}