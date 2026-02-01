import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/search_manager.dart';
import 'package:timeline/timeline/timeline_entry.dart';

void main() {
  group('SearchManager', () {
    late SearchManager searchManager;

    setUp(() {
      // Get singleton instance and reset it for clean test state
      searchManager = SearchManager.init();
      searchManager.reset();
    });

    test('should be a singleton', () {
      final instance1 = SearchManager.init();
      final instance2 = SearchManager.init();

      expect(instance1, same(instance2));
    });

    test('should initialize with entries', () {
      final entries = [
        TimelineEntry()
          ..label = 'Test Event'
          ..start = 1000.0,
      ];

      final manager = SearchManager.init(entries);
      expect(manager, isNotNull);
    });

    group('performSearch', () {
      test('should return results for matching query', () {
        final entries = [
          TimelineEntry()
            ..label = 'Test Event'
            ..start = 1000.0,
        ];
        searchManager = SearchManager.init(entries);

        // Search for exact label
        final results = searchManager.performSearch('test event');
        expect(results.length, equals(1));
        expect(results.first.label, equals('Test Event'));
      });

      test('should be case insensitive', () {
        final entries = [
          TimelineEntry()
            ..label = 'Test Event'
            ..start = 1000.0,
        ];
        searchManager = SearchManager.init(entries);

        // All variations should find the same result
        final results1 = searchManager.performSearch('TEST EVENT');
        final results2 = searchManager.performSearch('test event');
        final results3 = searchManager.performSearch('Test Event');

        expect(results1.length, equals(1));
        expect(results2.length, equals(1));
        expect(results3.length, equals(1));
      });

      test('should return empty for non-matching query', () {
        final entries = [
          TimelineEntry()
            ..label = 'Test Event'
            ..start = 1000.0,
        ];
        searchManager = SearchManager.init(entries);

        final results = searchManager.performSearch('xyz123');
        expect(results, isEmpty);
      });

      test('should handle multiple entries', () {
        final entries = [
          TimelineEntry()
            ..label = 'Event One'
            ..start = 1000.0,
          TimelineEntry()
            ..label = 'Event Two'
            ..start = 2000.0,
        ];
        searchManager = SearchManager.init(entries);

        // Search for common word
        final results = searchManager.performSearch('event');
        expect(results.length, equals(2));
      });

      test('should handle empty entries list', () {
        searchManager = SearchManager.init([]);

        final results = searchManager.performSearch('test');
        expect(results, isEmpty);
      });
    });

    group('Reset Functionality', () {
      test('should clear previous data on reset', () {
        // First, initialize with some data
        final entries1 = [
          TimelineEntry()
            ..label = 'First Event'
            ..start = 1000.0,
        ];
        searchManager = SearchManager.init(entries1);
        expect(searchManager.performSearch('first').length, equals(1));

        // Reset and initialize with different data
        searchManager.reset();
        final entries2 = [
          TimelineEntry()
            ..label = 'Second Event'
            ..start = 2000.0,
        ];
        searchManager = SearchManager.init(entries2);

        // Old data should be gone
        expect(searchManager.performSearch('first'), isEmpty);
        // New data should be present
        expect(searchManager.performSearch('second').length, equals(1));
      });
    });
  });
}
