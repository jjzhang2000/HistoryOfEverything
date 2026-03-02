import 'dart:async';

import 'package:timeline/timeline/timeline_entry.dart';

/// This object handles the search operation in the app.
/// 
/// The search index uses a word-based approach with prefix matching:
/// - Labels are split into words (by spaces and common delimiters)
/// - Each word is indexed by all its prefixes for fast prefix matching
/// - This approach is O(n*m) where n is the number of words and m is average word length
/// - Much more efficient than the previous O(n²) substring approach
class SearchManager {
  static final SearchManager _searchManager = SearchManager._internal();
  
  /// Main index: maps normalized word prefixes to entries
  final Map<String, Set<TimelineEntry>> _prefixIndex = {};
  
  /// Word list for autocomplete suggestions
  final Set<String> _allWords = {};
  
  /// Initialization state
  bool _isInitialized = false;
  List<TimelineEntry>? _pendingEntries;
  Completer<void>? _initCompleter;

  /// Private constructor for singleton pattern
  SearchManager._internal();

  /// Factory constructor for lazy initialization
  factory SearchManager.init([List<TimelineEntry>? entries]) {
    if (entries != null) {
      _searchManager._pendingEntries = entries;
    }
    return _searchManager;
  }

  /// Ensures the index is initialized before performing search operations.
  void _ensureInitialized() {
    if (!_isInitialized && _pendingEntries != null) {
      _buildIndex(_pendingEntries!);
      _isInitialized = true;
      _pendingEntries = null;
    }
  }

  /// Initialize asynchronously to avoid blocking the UI
  Future<void> initAsync(List<TimelineEntry> entries) async {
    if (_isInitialized) return;
    
    _initCompleter ??= Completer<void>();
    if (_initCompleter!.isCompleted) return;
    
    _pendingEntries = entries;
    
    // Build index in a microtask to allow UI to render first
    await Future.microtask(() {
      _buildIndex(entries);
      _isInitialized = true;
      _pendingEntries = null;
    });
    
    _initCompleter!.complete();
  }

  /// Synchronous initialization (for backward compatibility)
  void init(List<TimelineEntry> entries) {
    if (_isInitialized) return;
    _buildIndex(entries);
    _isInitialized = true;
    _pendingEntries = null;
  }

  /// Resets the search manager state. Used primarily for testing.
  void reset() {
    _prefixIndex.clear();
    _allWords.clear();
    _isInitialized = false;
    _pendingEntries = null;
    _initCompleter = null;
  }

  /// Build the search index from entries.
  /// 
  /// This method uses a word-based indexing strategy:
  /// - Split each label into words
  /// - Index each word by all its prefixes (for prefix matching)
  /// - This is O(n*w*p) where n=entries, w=words per entry, p=prefixes per word
  /// - Much more efficient than O(n*l²) substring approach
  void _buildIndex(List<TimelineEntry> entries) {
    _prefixIndex.clear();
    _allWords.clear();

    for (final entry in entries) {
      _indexEntry(entry);
    }
  }

  /// Index a single entry
  void _indexEntry(TimelineEntry entry) {
    final words = _tokenize(entry.label);
    
    for (final word in words) {
      if (word.isEmpty) continue;
      
      _allWords.add(word);
      
      // Index all prefixes of this word for prefix matching
      // e.g., "dinosaur" -> "d", "di", "din", "dino", ...
      for (int i = 1; i <= word.length; i++) {
        final prefix = word.substring(0, i);
        _prefixIndex.putIfAbsent(prefix, () => <TimelineEntry>{}).add(entry);
      }
    }
  }

  /// Split text into searchable words
  List<String> _tokenize(String text) {
    // Split by spaces, hyphens, underscores, and other common delimiters
    // Also handle camelCase and PascalCase
    final buffer = StringBuffer();
    final words = <String>[];
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      
      // Check if this is a delimiter
      if (_isDelimiter(char)) {
        if (buffer.isNotEmpty) {
          words.add(buffer.toString().toLowerCase());
          buffer.clear();
        }
      } 
      // Check for camelCase transition (lowercase to uppercase)
      else if (i > 0 && _isUpperCase(char) && !_isUpperCase(text[i - 1])) {
        if (buffer.isNotEmpty) {
          words.add(buffer.toString().toLowerCase());
          buffer.clear();
        }
        buffer.write(char);
      }
      else {
        buffer.write(char);
      }
    }
    
    // Don't forget the last word
    if (buffer.isNotEmpty) {
      words.add(buffer.toString().toLowerCase());
    }
    
    return words;
  }

  bool _isDelimiter(String char) {
    return char == ' ' || char == '-' || char == '_' || char == '/' || char == '\\';
  }

  bool _isUpperCase(String char) {
    return char.toUpperCase() == char && char.toLowerCase() != char;
  }

  /// Perform a search query.
  /// 
  /// The search matches:
  /// - Exact prefix matches from any word in any entry's label
  /// - Returns entries containing words that start with the query
  /// 
  /// Example: "dino" matches "Dinosaur Demise", "Dinosaurs", etc.
  Set<TimelineEntry> performSearch(String query) {
    _ensureInitialized();
    
    final normalizedQuery = query.trim().toLowerCase();
    
    if (normalizedQuery.isEmpty) {
      // Return all entries for empty query
      return _prefixIndex.values.fold<Set<TimelineEntry>>(
        <TimelineEntry>{},
        (acc, entries) => acc..addAll(entries),
      );
    }
    
    // Direct prefix lookup - O(1)
    return _prefixIndex[normalizedQuery] ?? <TimelineEntry>{};
  }

  /// Perform a multi-word search (AND operation between words)
  /// 
  /// Example: "world war" matches entries containing both "world" and "war"
  Set<TimelineEntry> performMultiWordSearch(String query) {
    _ensureInitialized();
    
    final normalizedQuery = query.trim().toLowerCase();
    
    if (normalizedQuery.isEmpty) {
      return _prefixIndex.values.fold<Set<TimelineEntry>>(
        <TimelineEntry>{},
        (acc, entries) => acc..addAll(entries),
      );
    }
    
    final searchWords = normalizedQuery.split(RegExp(r'\s+'));
    
    if (searchWords.isEmpty) {
      return <TimelineEntry>{};
    }
    
    // Get results for each word
    final resultSets = <Set<TimelineEntry>>[];
    for (final word in searchWords) {
      if (word.isEmpty) continue;
      
      // Find all entries matching this word prefix
      final wordResults = <TimelineEntry>{};
      for (final key in _prefixIndex.keys) {
        if (key.startsWith(word)) {
          wordResults.addAll(_prefixIndex[key]!);
        }
      }
      
      if (wordResults.isEmpty) {
        // No matches for this word, AND will be empty
        return <TimelineEntry>{};
      }
      
      resultSets.add(wordResults);
    }
    
    if (resultSets.isEmpty) {
      return <TimelineEntry>{};
    }
    
    // Intersect all result sets (AND operation)
    Set<TimelineEntry> result = resultSets.first;
    for (int i = 1; i < resultSets.length; i++) {
      result = result.intersection(resultSets[i]);
    }
    
    return result;
  }

  /// Get autocomplete suggestions for a partial query
  List<String> getSuggestions(String query, {int maxSuggestions = 5}) {
    _ensureInitialized();
    
    final normalizedQuery = query.trim().toLowerCase();
    
    if (normalizedQuery.isEmpty) {
      return _allWords.take(maxSuggestions).toList();
    }
    
    final suggestions = _allWords
        .where((word) => word.startsWith(normalizedQuery))
        .take(maxSuggestions)
        .toList();
    
    return suggestions;
  }

  /// Get the total number of indexed words
  int get indexedWordCount => _allWords.length;

  /// Get the total number of indexed prefixes
  int get indexedPrefixCount => _prefixIndex.length;

  /// Check if the index is initialized
  bool get isInitialized => _isInitialized;
}