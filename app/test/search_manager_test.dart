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

    test('should track initialization state', () {
      expect(searchManager.isInitialized, isFalse);
      
      final entries = [
        TimelineEntry()
          ..label = 'Test Event'
          ..start = 1000.0,
      ];
      searchManager.init(entries);
      
      expect(searchManager.isInitialized, isTrue);
    });

    group('performSearch - Prefix Matching', () {
      test('should return results for prefix matches', () {
        final entries = [
          TimelineEntry()
            ..label = 'Dinosaur'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        // All these prefixes should match "Dinosaur"
        expect(searchManager.performSearch('d').length, equals(1));
        expect(searchManager.performSearch('di').length, equals(1));
        expect(searchManager.performSearch('dino').length, equals(1));
        expect(searchManager.performSearch('dinosaur').length, equals(1));
      });

      test('should be case insensitive', () {
        final entries = [
          TimelineEntry()
            ..label = 'Test Event'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        // All variations should find the same result
        expect(searchManager.performSearch('TEST').length, equals(1));
        expect(searchManager.performSearch('test').length, equals(1));
        expect(searchManager.performSearch('TeSt').length, equals(1));
      });

      test('should not match non-prefix queries', () {
        final entries = [
          TimelineEntry()
            ..label = 'Dinosaur'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        // "saur" is not a prefix of "dinosaur", so it should NOT match
        // (unlike the old substring-based search)
        final results = searchManager.performSearch('saur');
        expect(results, isEmpty);
      });

      test('should return empty for non-matching query', () {
        final entries = [
          TimelineEntry()
            ..label = 'Test Event'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        final results = searchManager.performSearch('xyz123');
        expect(results, isEmpty);
      });

      test('should handle multiple entries with common prefix', () {
        final entries = [
          TimelineEntry()
            ..label = 'Dinosaur Demise'
            ..start = 1000.0,
          TimelineEntry()
            ..label = 'Dinosaurs'
            ..start = 2000.0,
          TimelineEntry()
            ..label = 'Mammals'
            ..start = 3000.0,
        ];
        searchManager.init(entries);

        // "dino" should match both dinosaur entries
        final dinoResults = searchManager.performSearch('dino');
        expect(dinoResults.length, equals(2));

        // "mammals" should match only mammals
        final mammalResults = searchManager.performSearch('mam');
        expect(mammalResults.length, equals(1));
      });

      test('should handle empty entries list', () {
        searchManager.init([]);

        final results = searchManager.performSearch('test');
        expect(results, isEmpty);
      });

      test('should return all entries for empty query', () {
        final entries = [
          TimelineEntry()
            ..label = 'Event One'
            ..start = 1000.0,
          TimelineEntry()
            ..label = 'Event Two'
            ..start = 2000.0,
        ];
        searchManager.init(entries);

        final results = searchManager.performSearch('');
        expect(results.length, equals(2));
      });
    });

    group('performMultiWordSearch', () {
      test('should match entries containing all words', () {
        final entries = [
          TimelineEntry()
            ..label = 'World War I'
            ..start = 1000.0,
          TimelineEntry()
            ..label = 'World War II'
            ..start = 2000.0,
          TimelineEntry()
            ..label = 'First World'
            ..start = 3000.0,
        ];
        searchManager.init(entries);

        // "world war" should match both World War entries
        final results = searchManager.performMultiWordSearch('world war');
        expect(results.length, equals(2));
      });

      test('should return empty if any word does not match', () {
        final entries = [
          TimelineEntry()
            ..label = 'World War I'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        // "world xyz" should not match anything
        final results = searchManager.performMultiWordSearch('world xyz');
        expect(results, isEmpty);
      });
    });

    group('getSuggestions', () {
      test('should return matching word suggestions', () {
        final entries = [
          TimelineEntry()
            ..label = 'Dinosaur Demise'
            ..start = 1000.0,
          TimelineEntry()
            ..label = 'Dinosaurs'
            ..start = 2000.0,
        ];
        searchManager.init(entries);

        final suggestions = searchManager.getSuggestions('dino');
        expect(suggestions, isNotEmpty);
        expect(suggestions.every((s) => s.startsWith('dino')), isTrue);
      });

      test('should limit suggestions to maxSuggestions', () {
        final entries = List.generate(20, (i) => TimelineEntry()
          ..label = 'Event $i'
          ..start = i.toDouble());
        searchManager.init(entries);

        final suggestions = searchManager.getSuggestions('e', maxSuggestions: 5);
        expect(suggestions.length, lessThanOrEqualTo(5));
      });
    });

    group('Tokenization', () {
      test('should split labels by spaces', () {
        final entries = [
          TimelineEntry()
            ..label = 'Hello World'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        // Should match by either word's prefix
        expect(searchManager.performSearch('hel').length, equals(1));
        expect(searchManager.performSearch('wor').length, equals(1));
      });

      test('should split labels by hyphens', () {
        final entries = [
          TimelineEntry()
            ..label = 'Pre-Cambrian Era'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        expect(searchManager.performSearch('pre').length, equals(1));
        expect(searchManager.performSearch('cam').length, equals(1));
        expect(searchManager.performSearch('era').length, equals(1));
      });

      test('should split labels by underscores', () {
        final entries = [
          TimelineEntry()
            ..label = 'test_event_name'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        expect(searchManager.performSearch('test').length, equals(1));
        expect(searchManager.performSearch('event').length, equals(1));
        expect(searchManager.performSearch('name').length, equals(1));
      });
    });

    group('Index Statistics', () {
      test('should track indexed word count', () {
        final entries = [
          TimelineEntry()
            ..label = 'Hello World'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        // Should have 2 unique words: "hello" and "world"
        expect(searchManager.indexedWordCount, equals(2));
      });

      test('should track indexed prefix count', () {
        final entries = [
          TimelineEntry()
            ..label = 'Hi'
            ..start = 1000.0,
        ];
        searchManager.init(entries);

        // "hi" has 2 prefixes: "h" and "hi"
        expect(searchManager.indexedPrefixCount, equals(2));
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
        searchManager.init(entries1);
        expect(searchManager.performSearch('fir').length, equals(1));

        // Reset and initialize with different data
        searchManager.reset();
        expect(searchManager.isInitialized, isFalse);
        
        final entries2 = [
          TimelineEntry()
            ..label = 'Second Event'
            ..start = 2000.0,
        ];
        searchManager.init(entries2);

        // Old data should be gone
        expect(searchManager.performSearch('fir'), isEmpty);
        // New data should be present
        expect(searchManager.performSearch('sec').length, equals(1));
      });
    });

    group('Async Initialization', () {
      test('should support async initialization', () async {
        final entries = [
          TimelineEntry()
            ..label = 'Test Event'
            ..start = 1000.0,
        ];
        
        await searchManager.initAsync(entries);
        
        expect(searchManager.isInitialized, isTrue);
        expect(searchManager.performSearch('test').length, equals(1));
      });

      test('should not reinitialize if already initialized', () async {
        final entries1 = [
          TimelineEntry()
            ..label = 'First Event'
            ..start = 1000.0,
        ];
        
        await searchManager.initAsync(entries1);
        
        // Try to initialize again with different data
        final entries2 = [
          TimelineEntry()
            ..label = 'Second Event'
            ..start = 2000.0,
        ];
        await searchManager.initAsync(entries2);
        
        // Should still have first event
        expect(searchManager.performSearch('first').length, equals(1));
      });
    });
  });
}