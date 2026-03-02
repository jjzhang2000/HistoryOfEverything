# Changelog

All notable changes to the History of Everything project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Riverpod state management integration (`flutter_riverpod: ^2.4.9`)
- `CONTRIBUTING.md` - Contributing guidelines for the project
- `app/lib/providers/app_providers.dart` - Riverpod providers for state management
- `app/lib/timeline/timeline_constants.dart` - Layout constants extracted from Timeline class
- `app/lib/timeline/timeline_viewport.dart` - Viewport state management class
- `app/lib/timeline/timeline_color_manager.dart` - Color management class
- `app/lib/timeline/resource_cache.dart` - LRU cache for resource management
- Localization support with `app/lib/l10n/` directory
- Unit tests for timeline components

### Changed
- Refactored `Timeline` class into smaller, single-responsibility classes
- Migrated from Flare/Nima animation libraries to Rive
- Improved search performance with prefix-based indexing
- Enhanced error handling in `BlocProvider` and `ArticleWidget`
- Fixed null safety issues across multiple files
- Standardized code comments to English
- Removed unused code and variables
- Fixed platform compatibility for Web platform

### Fixed
- Platform compatibility issue in `main_menu.dart` for Web platform
- Null pointer exceptions from force unwrapping (`!`)
- Search index performance issues
- Error handling for async operations
- Code style issues reported by `flutter analyze`

## [1.0.0] - Original Release

### Added
- Vertical timeline navigation from Big Bang to Internet
- Event animations using Flare/Nima
- Bubble-style labels for event names and times
- Markdown-formatted article content
- Search functionality with SplayTreeMap
- Favorites with SharedPreferences persistence
- Share functionality
- Support for Android, iOS, Web, and Windows platforms

---

## Version History Summary

| Version | Date | Description |
|---------|------|-------------|
| Unreleased | 2026-03 | Major refactoring, Riverpod integration, Rive migration |
| 1.0.0 | 2019 | Original release by 2D Inc |

---

## Migration Guide

### From Flare/Nima to Rive

The project has migrated from deprecated Flare/Nima animation libraries to Rive. Key changes:

1. **Asset Loading**: `.flr` and `.nma` files are now replaced with PNG fallback images
2. **Rive Support**: `.riv` files are fully supported for new animations
3. **Resource Cache**: LRU cache implementation for efficient memory management

### To Riverpod State Management

New Riverpod providers are available alongside the existing `BlocProvider`:

```dart
// Old way (still supported)
BlocProvider.getTimeline(context)

// New way (recommended)
ref.watch(timelineProvider)
```

### Timeline Class Refactoring

The `Timeline` class has been split into:
- `TimelineConstants` - Layout constants
- `TimelineViewport` - Viewport management
- `TimelineColorManager` - Color handling

Access constants via static getters (backward compatible):
```dart
Timeline.lineWidth  // Still works
```

---

[Unreleased]: https://github.com/jjzhang2000/HistoryOfEverything/compare/v1.0.0...Upgrade
[1.0.0]: https://github.com/2d-inc/HistoryOfEverything/releases/tag/v1.0.0