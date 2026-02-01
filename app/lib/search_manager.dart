import 'dart:collection';

import 'package:timeline/timeline/timeline_entry.dart';

/// This object handles the search operation in the app. When it is initialized,
/// receiving the full list of entries as input, the object fills in a [SplayTreeMap],
/// i.e. a self-balancing binary tree. 
class SearchManager {
  static final SearchManager _searchManager = SearchManager._internal();
  /// This map creates a dictionary for every possible substring that each of the
  /// [TimelineEntry] labels have, and uses a [Set] as a value, allowing for multiple
  /// entires to be stored for a single key.
  final SplayTreeMap<String, Set<TimelineEntry>> _queryMap =
      SplayTreeMap<String, Set<TimelineEntry>>();

  /// Initialization state flags for lazy index building.
  bool _isInitialized = false;
  List<TimelineEntry>? _pendingEntries;

  /// Constructor definition.
  SearchManager._internal();

  /// Factory constructor that will store pending entries for lazy initialization,
  /// and return the reference to the _searchManager (constructing it if called a first time.).
  factory SearchManager.init([List<TimelineEntry>? entries]) {
    if (entries != null) {
      _searchManager._pendingEntries = entries;
    }
    return _searchManager;
  }

  /// Ensures the index is initialized before performing search operations.
  /// This method builds the index lazily when needed, avoiding blocking during app startup.
  void _ensureInitialized() {
    if (!_isInitialized && _pendingEntries != null) {
      _fill(_pendingEntries!);
      _isInitialized = true;
      _pendingEntries = null;
    }
  }

  /// Resets the search manager state. Used primarily for testing.
  void reset() {
    _queryMap.clear();
    _isInitialized = false;
    _pendingEntries = null;
  }

  void _fill(List<TimelineEntry> entries) {
    /// Sanity check.
    _queryMap.clear(); 

    /// Fill the map with all the possible searchable substrings. 
    /// This operation is O(n^2), thus very slow, and performed only once upon initialization.
    for (TimelineEntry e in entries) {
      String label = e.label;
      int len = label.length;
      for (int i = 0; i < len; i++) {
        for (int j = i + 1; j <= len; j++) {
          String substring = label.substring(i, j).toLowerCase();
          if (_queryMap.containsKey(substring)) {
            _queryMap[substring]!.add(e);
          } else {
            _queryMap.putIfAbsent(substring, () => {e});
          }
        }
      }
    }
  }

  /// Use the [SplayTreeMap] query function to return the full [Set] of results.
  /// This operation amortized logarithmic time.
  Set<TimelineEntry> performSearch(String query) {
    _ensureInitialized();
    // Normalize query to lowercase for case-insensitive search
    final normalizedQuery = query.toLowerCase();
    
    if (_queryMap.containsKey(normalizedQuery)) {
      return _queryMap[normalizedQuery]!;
    } else if (normalizedQuery.isNotEmpty) {
      return <TimelineEntry>{};
    }
    Iterable<String> keys = _queryMap.keys;
    Set<TimelineEntry> res = <TimelineEntry>{};
    for (String k in keys) {
      res.addAll(_queryMap[k]!);
    }
    return res;
  }
}
