import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/providers/app_providers.dart';
import 'package:timeline/timeline/timeline_entry.dart';

void main() {
  group('AppInitData', () {
    test('should initialize with default values', () {
      const data = AppInitData();

      expect(data.state, equals(AppInitState.loading));
      expect(data.errorMessage, isNull);
      expect(data.entries, isEmpty);
    });

    test('should copy with new values', () {
      const data = AppInitData();
      final entries = [
        TimelineEntry()
          ..label = 'Test'
          ..start = 1000.0,
      ];

      final newData = data.copyWith(
        state: AppInitState.success,
        entries: entries,
      );

      expect(newData.state, equals(AppInitState.success));
      expect(newData.entries.length, equals(1));
      expect(data.state, equals(AppInitState.loading)); // Original unchanged
    });

    test('should copy with error state', () {
      const data = AppInitData();

      final newData = data.copyWith(
        state: AppInitState.error,
        errorMessage: 'Test error',
      );

      expect(newData.state, equals(AppInitState.error));
      expect(newData.errorMessage, equals('Test error'));
    });
  });

  group('FavoritesListNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with empty list', () {
      final notifier = container.read(favoritesListProvider.notifier);
      expect(notifier.state, isEmpty);
    });

    test('should set favorites', () {
      final notifier = container.read(favoritesListProvider.notifier);
      final entries = [
        TimelineEntry()
          ..label = 'Event 1'
          ..start = 1000.0,
        TimelineEntry()
          ..label = 'Event 2'
          ..start = 2000.0,
      ];

      notifier.setFavorites(entries);

      expect(notifier.state.length, equals(2));
    });

    test('should add favorite', () {
      final notifier = container.read(favoritesListProvider.notifier);
      final entry = TimelineEntry()
        ..label = 'Test Event'
        ..start = 1000.0;

      notifier.addFavorite(entry);

      expect(notifier.state.length, equals(1));
      expect(notifier.state[0].label, equals('Test Event'));
    });

    test('should not add duplicate favorites', () {
      final notifier = container.read(favoritesListProvider.notifier);
      final entry = TimelineEntry()
        ..label = 'Test Event'
        ..start = 1000.0;

      notifier.addFavorite(entry);
      notifier.addFavorite(entry);

      expect(notifier.state.length, equals(1));
    });

    test('should sort favorites by start time', () {
      final notifier = container.read(favoritesListProvider.notifier);
      final entry1 = TimelineEntry()
        ..label = 'Later Event'
        ..start = 2000.0;
      final entry2 = TimelineEntry()
        ..label = 'Earlier Event'
        ..start = 1000.0;

      notifier.addFavorite(entry1);
      notifier.addFavorite(entry2);

      expect(notifier.state[0].label, equals('Earlier Event'));
      expect(notifier.state[1].label, equals('Later Event'));
    });

    test('should remove favorite', () {
      final notifier = container.read(favoritesListProvider.notifier);
      final entry = TimelineEntry()
        ..label = 'Test Event'
        ..start = 1000.0;

      notifier.addFavorite(entry);
      expect(notifier.state.length, equals(1));

      notifier.removeFavorite(entry);
      expect(notifier.state, isEmpty);
    });

    test('should check if entry is favorite', () {
      final notifier = container.read(favoritesListProvider.notifier);
      final entry = TimelineEntry()
        ..label = 'Test Event'
        ..start = 1000.0;

      expect(notifier.isFavorite(entry), isFalse);

      notifier.addFavorite(entry);
      expect(notifier.isFavorite(entry), isTrue);
    });
  });

  group('Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('platformProvider should return iOS by default', () {
      final platform = container.read(platformProvider);
      expect(platform, equals(TargetPlatform.iOS));
    });

    test('timelineProvider should create Timeline instance', () {
      final timeline = container.read(timelineProvider);
      expect(timeline, isNotNull);
    });

    test('favoritesBlocProvider should create FavoritesBloc instance', () {
      final bloc = container.read(favoritesBlocProvider);
      expect(bloc, isNotNull);
    });

    test('searchManagerProvider should create SearchManager instance', () {
      final manager = container.read(searchManagerProvider);
      expect(manager, isNotNull);
    });

    test('appInitProvider should start in loading state', () {
      final data = container.read(appInitProvider);
      expect(data.state, equals(AppInitState.loading));
    });

    test('appInitStateProvider should return current state', () {
      final state = container.read(appInitStateProvider);
      expect(state, equals(AppInitState.loading));
    });

    test('isInitializedProvider should return false initially', () {
      final isInit = container.read(isInitializedProvider);
      expect(isInit, isFalse);
    });
  });
}