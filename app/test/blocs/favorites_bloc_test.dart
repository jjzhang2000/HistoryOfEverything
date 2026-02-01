import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline/blocs/favorites_bloc.dart';
import 'package:timeline/timeline/timeline_entry.dart';

void main() {
  group('FavoritesBloc', () {
    late FavoritesBloc favoritesBloc;
    late List<TimelineEntry> testEntries;

    setUp(() {
      favoritesBloc = FavoritesBloc();
      
      // Setup mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Create test entries
      testEntries = [
        TimelineEntry()
          ..label = 'Big Bang'
          ..start = -13800000000.0
          ..end = -13800000000.0,
        TimelineEntry()
          ..label = 'Dinosaurs'
          ..start = -245000000.0
          ..end = -66000000.0,
        TimelineEntry()
          ..label = 'Humans'
          ..start = -300000.0
          ..end = 2024.0,
      ];
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should initialize correctly', () {
      expect(favoritesBloc, isNotNull);
      expect(favoritesBloc.favorites, isEmpty);
    });

    test('init should load favorites from SharedPreferences', () async {
      // Pre-populate SharedPreferences with favorites
      SharedPreferences.setMockInitialValues({
        FavoritesBloc.FAVORITES_KEY: ['Big Bang', 'Humans'],
      });

      await favoritesBloc.init(testEntries);

      expect(favoritesBloc.favorites.length, equals(2));
      expect(favoritesBloc.favorites[0].label, equals('Big Bang'));
      expect(favoritesBloc.favorites[1].label, equals('Humans'));
    });

    test('init should sort favorites by start time', () async {
      // Pre-populate with favorites in reverse order
      SharedPreferences.setMockInitialValues({
        FavoritesBloc.FAVORITES_KEY: ['Humans', 'Dinosaurs', 'Big Bang'],
      });

      await favoritesBloc.init(testEntries);

      // Should be sorted: Big Bang (-13.8B), Dinosaurs (-245M), Humans (-300K)
      expect(favoritesBloc.favorites[0].label, equals('Big Bang'));
      expect(favoritesBloc.favorites[1].label, equals('Dinosaurs'));
      expect(favoritesBloc.favorites[2].label, equals('Humans'));
    });

    test('init should handle empty favorites list', () async {
      await favoritesBloc.init(testEntries);

      expect(favoritesBloc.favorites, isEmpty);
    });

    test('init should ignore non-existent favorites', () async {
      SharedPreferences.setMockInitialValues({
        FavoritesBloc.FAVORITES_KEY: ['Big Bang', 'NonExistent'],
      });

      await favoritesBloc.init(testEntries);

      expect(favoritesBloc.favorites.length, equals(1));
      expect(favoritesBloc.favorites[0].label, equals('Big Bang'));
    });

    test('addFavorite should add entry to favorites', () async {
      await favoritesBloc.init(testEntries);
      
      final newEntry = TimelineEntry()
        ..label = 'Big Bang'
        ..start = -13800000000.0;

      favoritesBloc.addFavorite(newEntry);

      expect(favoritesBloc.favorites.length, equals(1));
      expect(favoritesBloc.favorites[0].label, equals('Big Bang'));
    });

    test('addFavorite should not add duplicate entries', () async {
      await favoritesBloc.init(testEntries);
      
      final entry = TimelineEntry()
        ..label = 'Big Bang'
        ..start = -13800000000.0;

      favoritesBloc.addFavorite(entry);
      favoritesBloc.addFavorite(entry);

      expect(favoritesBloc.favorites.length, equals(1));
    });

    test('addFavorite should maintain sorted order', () async {
      await favoritesBloc.init(testEntries);
      
      final bigBang = testEntries[0]; // -13.8B
      final humans = testEntries[2];  // -300K
      final dinosaurs = testEntries[1]; // -245M

      favoritesBloc.addFavorite(humans);
      favoritesBloc.addFavorite(bigBang);
      favoritesBloc.addFavorite(dinosaurs);

      expect(favoritesBloc.favorites[0].label, equals('Big Bang'));
      expect(favoritesBloc.favorites[1].label, equals('Dinosaurs'));
      expect(favoritesBloc.favorites[2].label, equals('Humans'));
    });

    test('removeFavorite should remove entry from favorites', () async {
      await favoritesBloc.init(testEntries);
      
      final entry = testEntries[0];
      favoritesBloc.addFavorite(entry);
      expect(favoritesBloc.favorites.length, equals(1));

      favoritesBloc.removeFavorite(entry);

      expect(favoritesBloc.favorites, isEmpty);
    });

    test('removeFavorite should not fail for non-favorite entry', () async {
      await favoritesBloc.init(testEntries);
      
      final entry = testEntries[0];
      
      // Should not throw
      expect(() => favoritesBloc.removeFavorite(entry), returnsNormally);
      expect(favoritesBloc.favorites, isEmpty);
    });

    test('favorites should persist to SharedPreferences', () async {
      await favoritesBloc.init(testEntries);
      
      final entry = testEntries[0];
      favoritesBloc.addFavorite(entry);

      // Verify saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedFavs = prefs.getStringList(FavoritesBloc.FAVORITES_KEY);
      
      expect(savedFavs, isNotNull);
      expect(savedFavs, contains('Big Bang'));
    });

    test('removeFavorite should update SharedPreferences', () async {
      await favoritesBloc.init(testEntries);
      
      final entry1 = testEntries[0];
      final entry2 = testEntries[1];
      
      favoritesBloc.addFavorite(entry1);
      favoritesBloc.addFavorite(entry2);
      
      favoritesBloc.removeFavorite(entry1);

      final prefs = await SharedPreferences.getInstance();
      final savedFavs = prefs.getStringList(FavoritesBloc.FAVORITES_KEY);
      
      expect(savedFavs, isNotNull);
      expect(savedFavs, isNot(contains('Big Bang')));
      expect(savedFavs, contains('Dinosaurs'));
    });

    test('favorites list should be immutable from outside', () async {
      await favoritesBloc.init(testEntries);
      
      final entry = testEntries[0];
      favoritesBloc.addFavorite(entry);

      final favorites = favoritesBloc.favorites;
      
      // Modifying the returned list should not affect internal state
      favorites.clear();
      
      expect(favoritesBloc.favorites.length, equals(1));
    });
  });
}
