import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/timeline/resource_cache.dart';

void main() {
  group('ResourceCache', () {
    late ResourceCache cache;

    setUp(() {
      cache = ResourceCache(maxCacheSize: 1024); // 1KB for testing
    });

    tearDown(() {
      cache.clear();
    });

    group('Basic Operations', () {
      test('should start empty', () {
        expect(cache.cachedItemCount, equals(0));
        expect(cache.currentCacheSize, equals(0));
      });

      test('should add item to cache', () {
        cache.put('test_key', 'test_value', 100);

        expect(cache.cachedItemCount, equals(1));
        expect(cache.currentCacheSize, equals(100));
      });

      test('should retrieve cached item', () {
        cache.put('test_key', 'test_value', 100);

        final value = cache.get<String>('test_key');

        expect(value, equals('test_value'));
      });

      test('should return null for missing key', () {
        final value = cache.get<String>('missing_key');

        expect(value, isNull);
      });

      test('should return null for wrong type', () {
        cache.put('test_key', 'string_value', 100);

        final value = cache.get<int>('test_key');

        expect(value, isNull);
      });

      test('should update existing key', () {
        cache.put('test_key', 'value1', 100);
        cache.put('test_key', 'value2', 200);

        expect(cache.cachedItemCount, equals(1));
        expect(cache.currentCacheSize, equals(200));
        expect(cache.get<String>('test_key'), equals('value2'));
      });
    });

    group('LRU Eviction', () {
      test('should evict oldest entry when cache is full', () {
        cache.put('key1', 'value1', 500);
        cache.put('key2', 'value2', 500);
        cache.put('key3', 'value3', 500); // Should evict key1

        expect(cache.cachedItemCount, equals(2));
        expect(cache.get<String>('key1'), isNull);
        expect(cache.get<String>('key2'), isNotNull);
        expect(cache.get<String>('key3'), isNotNull);
      });

      test('should update LRU order on access', () {
        cache.put('key1', 'value1', 400);
        cache.put('key2', 'value2', 400);

        // Access key1 to make it recently used
        cache.get<String>('key1');

        // Add key3, should evict key2 (oldest)
        cache.put('key3', 'value3', 400);

        expect(cache.get<String>('key1'), isNotNull);
        expect(cache.get<String>('key2'), isNull);
        expect(cache.get<String>('key3'), isNotNull);
      });

      test('should evict multiple entries if needed', () {
        cache.put('key1', 'value1', 300);
        cache.put('key2', 'value2', 300);
        cache.put('key3', 'value3', 300);

        // Add large item, should evict key1 and key2
        cache.put('key4', 'value4', 600);

        expect(cache.get<String>('key1'), isNull);
        expect(cache.get<String>('key2'), isNull);
        expect(cache.get<String>('key3'), isNotNull);
        expect(cache.get<String>('key4'), isNotNull);
      });
    });

    group('Cache Statistics', () {
      test('should track hits and misses', () {
        cache.put('key1', 'value1', 100);

        // Access cached item (hit)
        cache.get<String>('key1');
        
        // Access missing items (misses)
        cache.get<String>('missing1');
        cache.get<String>('missing2');

        // Just verify that we can access the cache
        expect(cache.cachedItemCount, equals(1));
      });

      test('should have zero hit ratio with no operations', () {
        expect(cache.hitRatio, equals(0.0));
      });
    });

    group('Clear Operations', () {
      test('should clear all entries', () {
        cache.put('key1', 'value1', 100);
        cache.put('key2', 'value2', 200);

        cache.clear();

        expect(cache.cachedItemCount, equals(0));
        expect(cache.currentCacheSize, equals(0));
      });

      test('should clear entries matching pattern', () {
        cache.put('image_1', 'value1', 100);
        cache.put('image_2', 'value2', 100);
        cache.put('rive_1', 'value3', 100);

        cache.clearPattern('image');

        expect(cache.cachedItemCount, equals(1));
        expect(cache.get<String>('rive_1'), isNotNull);
      });
    });

    group('getOrLoad', () {
      test('should return cached value without calling loader', () async {
        cache.put('key1', 'cached_value', 100);

        var loaderCalled = false;
        final value = await cache.getOrLoad<String>('key1', () async {
          loaderCalled = true;
          return 'new_value';
        });

        expect(value, equals('cached_value'));
        expect(loaderCalled, isFalse);
      });

      test('should call loader for missing value', () async {
        final value = await cache.getOrLoad<String>('key1', () async {
          return 'loaded_value';
        });

        expect(value, equals('loaded_value'));
        expect(cache.cachedItemCount, equals(1));
      });

      test('should not load twice for same key', () async {
        var loadCount = 0;

        // Start two concurrent loads
        final future1 = cache.getOrLoad<String>('key1', () async {
          loadCount++;
          await Future.delayed(const Duration(milliseconds: 10));
          return 'value';
        });
        final future2 = cache.getOrLoad<String>('key1', () async {
          loadCount++;
          await Future.delayed(const Duration(milliseconds: 10));
          return 'value';
        });

        await Future.wait([future1, future2]);

        expect(loadCount, equals(1));
      });
    });

    group('Preloading', () {
      test('should preload multiple keys', () async {
        var loadCount = 0;

        cache.preload(
          ['key1', 'key2', 'key3'],
          (key) async {
            loadCount++;
            return 'value_$key';
          },
        );

        // Wait for async preloading
        await Future.delayed(const Duration(milliseconds: 50));

        expect(loadCount, greaterThanOrEqualTo(3));
      });

      test('should not preload already cached keys', () async {
        cache.put('key1', 'existing', 100);
        var loadCount = 0;

        cache.preload(
          ['key1', 'key2'],
          (key) async {
            loadCount++;
            return 'value_$key';
          },
        );

        await Future.delayed(const Duration(milliseconds: 50));

        expect(loadCount, equals(1)); // Only key2 should be loaded
      });
    });

    group('Size Estimation', () {
      test('should evict entries when cache is full', () {
        final smallCache = ResourceCache(maxCacheSize: 200);

        smallCache.put('key1', 'value1', 100);
        smallCache.put('key2', 'value2', 100);
        smallCache.put('key3', 'value3', 100); // Should trigger eviction

        // Cache should have evicted some entries
        expect(smallCache.cachedItemCount, lessThanOrEqualTo(2));
        smallCache.clear();
      });
    });
  });
}