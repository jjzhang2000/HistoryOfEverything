import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart';
import 'timeline_entry.dart';

/// Cache entry for storing loaded resources with metadata
class CacheEntry {
  final dynamic resource;
  final DateTime lastAccessed;
  final int sizeBytes;

  CacheEntry({
    required this.resource,
    required this.sizeBytes,
  }) : lastAccessed = DateTime.now();

  void updateAccessTime() {
    // lastAccessed is final, so we recreate entries when needed
  }
}

/// LRU Cache for timeline resources (images, Rive animations)
/// 
/// Features:
/// - Maximum memory limit with LRU eviction
/// - Lazy loading support
/// - Async loading with futures
/// - Preloading for critical resources
class ResourceCache {
  /// Maximum cache size in bytes (50MB default)
  final int maxCacheSize;
  
  /// Current cache size in bytes
  int _currentCacheSize = 0;
  
  /// Cache storage using LinkedHashMap for LRU ordering
  final LinkedHashMap<String, CacheEntry> _cache = LinkedHashMap();
  
  /// Pending load operations to prevent duplicate loads
  final Map<String, Future<dynamic>> _pendingLoads = {};
  
  /// Statistics
  int _hits = 0;
  int _misses = 0;

  ResourceCache({
    this.maxCacheSize = 50 * 1024 * 1024, // 50MB
  });

  /// Get cache hit ratio
  double get hitRatio => _hits + _misses > 0 ? _hits / (_hits + _misses) : 0.0;
  
  /// Get current cache size
  int get currentCacheSize => _currentCacheSize;
  
  /// Get number of cached items
  int get cachedItemCount => _cache.length;

  /// Get a resource from cache or load it
  Future<T?> getOrLoad<T>(String key, Future<T?> Function() loader) async {
    // Check cache first
    final cached = get<T>(key);
    if (cached != null) {
      _hits++;
      return cached;
    }
    
    _misses++;
    
    // Check if load is already in progress
    if (_pendingLoads.containsKey(key)) {
      final result = await _pendingLoads[key];
      return result as T?;
    }
    
    // Start new load
    final loadFuture = loader();
    _pendingLoads[key] = loadFuture;
    
    try {
      final result = await loadFuture;
      if (result != null) {
        put(key, result, _estimateSize(result));
      }
      return result;
    } finally {
      _pendingLoads.remove(key);
    }
  }

  /// Get a cached resource
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && entry.resource is T) {
      // Move to end for LRU (remove and re-add)
      _cache.remove(key);
      _cache[key] = CacheEntry(
        resource: entry.resource,
        sizeBytes: entry.sizeBytes,
      );
      return entry.resource as T;
    }
    return null;
  }

  /// Put a resource in cache
  void put(String key, dynamic resource, int sizeBytes) {
    // Remove existing entry if present
    if (_cache.containsKey(key)) {
      final existing = _cache[key]!;
      _currentCacheSize -= existing.sizeBytes;
      _cache.remove(key);
    }
    
    // Evict entries if needed
    while (_currentCacheSize + sizeBytes > maxCacheSize && _cache.isNotEmpty) {
      _evictOldest();
    }
    
    // Add new entry
    _cache[key] = CacheEntry(
      resource: resource,
      sizeBytes: sizeBytes,
    );
    _currentCacheSize += sizeBytes;
    
    debugPrint('ResourceCache: Added $key (${_formatBytes(sizeBytes)}), total: ${_formatBytes(_currentCacheSize)}');
  }

  /// Preload resources (fire and forget)
  void preload(List<String> keys, Future<dynamic> Function(String) loader) {
    for (final key in keys) {
      if (!_cache.containsKey(key) && !_pendingLoads.containsKey(key)) {
        getOrLoad(key, () => loader(key));
      }
    }
  }

  /// Clear cache entries matching pattern
  void clearPattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();
    
    for (final key in keysToRemove) {
      final entry = _cache[key]!;
      _currentCacheSize -= entry.sizeBytes;
      _cache.remove(key);
    }
    
    if (keysToRemove.isNotEmpty) {
      debugPrint('ResourceCache: Cleared ${keysToRemove.length} entries matching "$pattern"');
    }
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _currentCacheSize = 0;
    debugPrint('ResourceCache: Cleared all entries');
  }

  /// Evict oldest entry (LRU)
  void _evictOldest() {
    if (_cache.isEmpty) return;
    
    final oldestKey = _cache.keys.first;
    final oldestEntry = _cache[oldestKey]!;
    _currentCacheSize -= oldestEntry.sizeBytes;
    _cache.remove(oldestKey);
    
    debugPrint('ResourceCache: Evicted $oldestKey (${_formatBytes(oldestEntry.sizeBytes)})');
  }

  /// Estimate size of a resource
  int _estimateSize(dynamic resource) {
    if (resource is ui.Image) {
      // Image size: width * height * 4 bytes (RGBA)
      return resource.width * resource.height * 4;
    } else if (resource is TimelineRive) {
      // Rive files are typically small, estimate based on artboard
      return 100 * 1024; // 100KB estimate
    } else if (resource is ByteData) {
      return resource.lengthInBytes;
    }
    return 10 * 1024; // Default 10KB estimate
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Global resource cache instance
final ResourceCache resourceCache = ResourceCache(
  maxCacheSize: 50 * 1024 * 1024, // 50MB
);

/// Resource loader with lazy loading support
class ResourceLoader {
  /// Load an image asset with caching
  static Future<ui.Image?> loadImage(String filename) async {
    return resourceCache.getOrLoad<ui.Image>(filename, () async {
      try {
        final ByteData data = await rootBundle.load(filename);
        final Uint8List list = Uint8List.view(data.buffer);
        final ui.Codec codec = await ui.instantiateImageCodec(list);
        final ui.FrameInfo frame = await codec.getNextFrame();
        return frame.image;
      } catch (e) {
        debugPrint('Error loading image $filename: $e');
        return null;
      }
    });
  }

  /// Load a Rive animation with caching
  static Future<TimelineRive?> loadRive(String filename) async {
    return resourceCache.getOrLoad<TimelineRive>(filename, () async {
      try {
        final ByteData data = await rootBundle.load(filename);
        final riveFile = RiveFile.import(data);
        final artboard = riveFile.mainArtboard;
        
        final riveAsset = TimelineRive();
        riveAsset.artboard = artboard;
        riveAsset.filename = filename;
        
        if (artboard.animations.isNotEmpty) {
          riveAsset.controller = SimpleAnimation(artboard.animations.first.name);
          artboard.addController(riveAsset.controller!);
        }
        
        return riveAsset;
      } catch (e) {
        debugPrint('Error loading Rive $filename: $e');
        return null;
      }
    });
  }

  /// Preload critical assets for smooth navigation
  static Future<void> preloadCriticalAssets(List<String> filenames) async {
    final futures = <Future>[];
    
    for (final filename in filenames) {
      if (filename.endsWith('.riv')) {
        futures.add(loadRive(filename));
      } else if (filename.endsWith('.png') || filename.endsWith('.jpg')) {
        futures.add(loadImage(filename));
      }
    }
    
    await Future.wait(futures);
  }
}