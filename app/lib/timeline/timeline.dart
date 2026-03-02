import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'resource_cache.dart';
import 'timeline_color_manager.dart';
import 'timeline_constants.dart';
import 'timeline_viewport.dart';
import 'timeline_utils.dart';

import 'timeline_entry.dart';

typedef PaintCallback = void Function();
typedef ChangeEraCallback = void Function(TimelineEntry? era);
typedef ChangeHeaderColorCallback = void Function(Color? background, Color? text);

/// Main Timeline class that coordinates viewport, colors, and animation.
/// 
/// This class has been refactored to separate concerns:
/// - [TimelineViewport] handles viewport state and scroll physics
/// - [TimelineColorManager] handles color configuration
/// - [TimelineConstants] provides layout constants
class Timeline {
  /// The current platform for scroll physics configuration.
  final TargetPlatform _platform;

  /// Viewport manager - handles position, scale, and scroll physics
  late final TimelineViewport viewport;
  
  /// Color manager - handles background, tick, and header colors
  late final TimelineColorManager colorManager;

  // Rendering state
  double _lastFrameTime = 0.0;
  double _height = 0.0;
  double _firstOnScreenEntryY = 0.0;
  double _lastEntryY = 0.0;
  double _lastOnScreenEntryY = 0.0;
  double _offsetDepth = 0.0;
  double _renderOffsetDepth = 0.0;
  double _labelX = 0.0;
  double _renderLabelX = 0.0;
  double _lastAssetY = 0.0;
  double _prevEntryOpacity = 0.0;
  double _distanceToPrevEntry = 0.0;
  double _nextEntryOpacity = 0.0;
  double _distanceToNextEntry = 0.0;
  double _gutterWidth = TimelineConstants.gutterLeft;
  
  bool _showFavorites = false;
  bool _isFrameScheduled = false;
  bool _isInteracting = false;
  bool _isScaling = false;
  bool _isActive = false;
  bool _isSteady = false;

  Timer? _steadyTimer;
  
  // Era tracking
  TimelineEntry? _currentEra;
  TimelineEntry? _lastEra;
  TimelineEntry? _nextEntry;
  TimelineEntry? _renderNextEntry;
  TimelineEntry? _prevEntry;
  TimelineEntry? _renderPrevEntry;

  // Entry data
  late List<TimelineEntry> _entries;
  late List<TimelineAsset> _renderAssets;
  final Map<String, TimelineEntry> _entriesById = <String, TimelineEntry>{};

  // Callbacks
  PaintCallback? onNeedPaint;
  ChangeEraCallback? onEraChanged;
  ChangeHeaderColorCallback? onHeaderColorsChanged;

  Timeline(this._platform) {
    _entries = <TimelineEntry>[];
    _renderAssets = <TimelineAsset>[];
    
    viewport = TimelineViewport(
      platform: _platform,
      viewportPaddingTop: TimelineConstants.viewportPaddingTop,
      viewportPaddingBottom: TimelineConstants.viewportPaddingBottom,
    );
    
    colorManager = TimelineColorManager();
    
    setViewport(start: 1536.0, end: 3072.0);
  }

  // Getters for viewport properties
  double get renderOffsetDepth => _renderOffsetDepth;
  double get renderLabelX => _renderLabelX;
  double get start => viewport.start;
  double get end => viewport.end;
  double get renderStart => viewport.renderStart;
  double get renderEnd => viewport.renderEnd;
  double get gutterWidth => _gutterWidth;
  double get nextEntryOpacity => _nextEntryOpacity;
  double get prevEntryOpacity => _prevEntryOpacity;
  bool get isInteracting => _isInteracting;
  bool get showFavorites => _showFavorites;
  bool get isActive => _isActive;
  
  // Getters for color properties
  Color? get headerTextColor => colorManager.headerTextColor;
  Color? get headerBackgroundColor => colorManager.headerBackgroundColor;
  HeaderColors? get currentHeaderColors => colorManager.currentHeaderColors;
  TimelineEntry? get currentEra => _currentEra;
  TimelineEntry? get nextEntry => _renderNextEntry;
  TimelineEntry? get prevEntry => _renderPrevEntry;
  List<TimelineEntry> get entries => _entries;
  List<TimelineBackgroundColor> get backgroundColors => colorManager.backgroundColors;
  List<TickColors> get tickColors => colorManager.tickColors;
  List<TimelineAsset> get renderAssets => _renderAssets;
  
  // Expose constants for backward compatibility
  static double get lineWidth => TimelineConstants.lineWidth;
  static double get lineSpacing => TimelineConstants.lineSpacing;
  static double get depthOffset => TimelineConstants.depthOffset;
  static double get edgePadding => TimelineConstants.edgePadding;
  static double get moveSpeed => TimelineConstants.moveSpeed;
  static double get deceleration => TimelineConstants.deceleration;
  static double get gutterLeft => TimelineConstants.gutterLeft;
  static double get gutterLeftExpanded => TimelineConstants.gutterLeftExpanded;
  static double get edgeRadius => TimelineConstants.edgeRadius;
  static double get minChildLength => TimelineConstants.minChildLength;
  static double get defaultBubbleHeight => TimelineConstants.defaultBubbleHeight;
  static double get bubbleArrowSize => TimelineConstants.bubbleArrowSize;
  static double get bubblePadding => TimelineConstants.bubblePadding;
  static double get bubbleTextHeight => TimelineConstants.bubbleTextHeight;
  static double get assetPadding => TimelineConstants.assetPadding;
  static double get parallax => TimelineConstants.parallax;
  static double get assetScreenScale => TimelineConstants.assetScreenScale;

  set showFavorites(bool value) {
    if (_showFavorites != value) {
      _showFavorites = value;
      _startRendering();
    }
  }

  set isInteracting(bool value) {
    if (value != _isInteracting) {
      _isInteracting = value;
      _updateSteady();
    }
  }

  set isScaling(bool value) {
    if (value != _isScaling) {
      _isScaling = value;
      _updateSteady();
    }
  }

  set isActive(bool isIt) {
    if (isIt != _isActive) {
      _isActive = isIt;
      if (_isActive) {
        _startRendering();
      }
    }
  }

  /// Check that the viewport is steady - no active gestures.
  void _updateSteady() {
    bool isIt = !_isInteracting && !_isScaling;

    if (_steadyTimer != null) {
      _steadyTimer!.cancel();
      _steadyTimer = null;
    }

    if (isIt) {
      _steadyTimer = Timer(const Duration(milliseconds: TimelineConstants.steadyMilliseconds), () {
        _steadyTimer = null;
        _isSteady = true;
        _startRendering();
      });
    } else {
      _isSteady = false;
      _startRendering();
    }
  }

  /// Schedule a new frame.
  void _startRendering() {
    if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  double screenPaddingInTime(double padding, double start, double end) {
    return padding / viewport.computeScaleFor(start, end);
  }

  /// Compute the viewport scale from the start/end times.
  double computeScale(double start, double end) {
    return viewport.computeScaleFor(start, end);
  }

  /// Load all the resources from the local bundle.
  Future<List<TimelineEntry>> loadFromBundle(String filename) async {
    try {
      String data = await rootBundle.loadString(filename);
      List jsonEntries = json.decode(data) as List;

      List<TimelineEntry> allEntries = <TimelineEntry>[];
      colorManager.backgroundColors.clear();
      colorManager.tickColors.clear();
      colorManager.headerColors.clear();

      for (dynamic entry in jsonEntries) {
        Map map = entry as Map;

        TimelineEntry timelineEntry = TimelineEntry();
        if (map.containsKey("date")) {
          timelineEntry.type = TimelineEntryType.Incident;
          dynamic date = map["date"];
          timelineEntry.start = date is int ? date.toDouble() : date;
        } else if (map.containsKey("start")) {
          timelineEntry.type = TimelineEntryType.Era;
          dynamic start = map["start"];
          if (start == null) continue;
          timelineEntry.start = start is int ? start.toDouble() : start;
        } else {
          continue;
        }

        // Parse background color
        TimelineBackgroundColor? bgColor = colorManager.parseBackgroundColor(map, timelineEntry.start!);
        if (bgColor != null) {
          colorManager.backgroundColors.add(bgColor);
        }

        // Parse accent color
        dynamic accent = map["accent"];
        if (accent == null) continue;
        if (accent is List && accent.length >= 3) {
          timelineEntry.accent = Color.fromARGB(
              accent.length > 3 ? accent[3] as int : 255,
              accent[0] as int,
              accent[1] as int,
              accent[2] as int);
        }

        // Parse tick colors
        TickColors? tc = colorManager.parseTickColors(map, timelineEntry.start!);
        if (tc != null) {
          colorManager.tickColors.add(tc);
        }

        // Parse header colors
        HeaderColors? hc = colorManager.parseHeaderColors(map, timelineEntry.start!);
        if (hc != null) {
          colorManager.headerColors.add(hc);
        }

        if (map.containsKey("end")) {
          dynamic end = map["end"];
          timelineEntry.end = end is int ? end.toDouble() : end;
        } else if (timelineEntry.type == TimelineEntryType.Era) {
          timelineEntry.end = DateTime.now().year.toDouble() * 10.0;
        } else {
          timelineEntry.end = timelineEntry.start;
        }

        if (map.containsKey("label")) {
          timelineEntry.label = map["label"] as String;
        }

        if (map.containsKey("id")) {
          timelineEntry.id = map["id"] as String;
          if (timelineEntry.id != null) {
            _entriesById[timelineEntry.id!] = timelineEntry;
          }
        }
        if (map.containsKey("article")) {
          timelineEntry.articleFilename = map["article"] as String;
        }

        // Load asset with caching support
        if (map.containsKey("asset")) {
          Map assetMap = map["asset"] as Map;
          String source = assetMap["source"];
          String assetFilename = "assets/$source";
          String? extension = getExtension(source);
          
          // Schedule asset loading asynchronously (lazy loading)
          timelineEntry.assetFilename = assetFilename;
          timelineEntry.assetMap = assetMap;
          
          // Mark asset as needing loading
          _scheduleAssetLoad(timelineEntry, extension);
        }
        allEntries.add(timelineEntry);
      }

      // Sort entries
      allEntries.sort((TimelineEntry a, TimelineEntry b) {
        return (a.start ?? 0).compareTo(b.start ?? 0);
      });

      colorManager.sortAll();

      viewport.timeMin = double.infinity;
      viewport.timeMax = -double.infinity;
      _entries = <TimelineEntry>[];

      TimelineEntry? previous;
      for (TimelineEntry entry in allEntries) {
        if (entry.start != null && entry.start! < viewport.timeMin) {
          viewport.timeMin = entry.start!;
        }
        if (entry.end != null && entry.end! > viewport.timeMax) {
          viewport.timeMax = entry.end!;
        }
        if (previous != null) {
          previous.next = entry;
        }
        entry.previous = previous;
        previous = entry;

        TimelineEntry? parent;
        double minDistance = double.infinity;
        for (TimelineEntry checkEntry in allEntries) {
          if (checkEntry.type == TimelineEntryType.Era) {
            if (entry.start == null || checkEntry.start == null || checkEntry.end == null) continue;
            double distance = entry.start! - checkEntry.start!;
            double distanceEnd = entry.start! - checkEntry.end!;
            if (distance > 0 && distanceEnd < 0 && distance < minDistance) {
              minDistance = distance;
              parent = checkEntry;
            }
          }
        }
        if (parent != null) {
          entry.parent = parent;
          parent.children ??= <TimelineEntry>[];
          parent.children!.add(entry);
        } else {
          _entries.add(entry);
        }
      }
      return allEntries;
    } catch (e) {
      debugPrint('Error loading timeline from bundle: $e');
      return <TimelineEntry>[];
    }
  }

  /// Helper function for [MenuVignette].
  TimelineEntry? getById(String id) {
    return _entriesById[id];
  }

  /// Schedule asset loading for an entry (lazy loading with caching)
  void _scheduleAssetLoad(TimelineEntry entry, String? extension) {
    if (entry.isAssetLoadScheduled || entry.assetFilename == null) return;
    
    entry.isAssetLoadScheduled = true;
    
    // Load asset asynchronously using the resource cache
    _loadAssetAsync(entry, extension);
  }

  /// Load asset asynchronously with caching
  Future<void> _loadAssetAsync(TimelineEntry entry, String? extension) async {
    if (entry.assetFilename == null || entry.assetMap == null) return;
    
    try {
      TimelineAsset? asset;
      String filename = entry.assetFilename!;
      Map assetMap = entry.assetMap!;
      
      if (extension == "riv") {
        // Load Rive animation with caching
        final riveAsset = await ResourceLoader.loadRive(filename);
        if (riveAsset != null) {
          asset = riveAsset;
        }
      } else if (extension == "flr" || extension == "nma") {
        // Flare/Nima migration: try to load PNG fallback with caching
        String source = assetMap["source"];
        String baseName = source.substring(0, source.lastIndexOf('.'));
        String fileBaseName = baseName.contains('/') ? baseName.substring(baseName.lastIndexOf('/') + 1) : baseName;
        
        List<String> pngPaths = [
          "assets/$baseName.png",
          "assets/$fileBaseName.png",
        ];
        
        ui.Image? image;
        for (String pngPath in pngPaths) {
          image = await ResourceLoader.loadImage(pngPath);
          if (image != null) {
            debugPrint('Loaded PNG fallback for $source: $pngPath');
            break;
          }
        }
        
        if (image != null) {
          TimelineImage imageAsset = TimelineImage();
          imageAsset.image = image;
          asset = imageAsset;
        } else {
          // Create placeholder
          debugPrint('Warning: No PNG fallback found for $source, using placeholder');
          ui.PictureRecorder recorder = ui.PictureRecorder();
          ui.Canvas canvas = ui.Canvas(recorder);
          ui.Paint paint = ui.Paint()..color = const Color(0x00000000);
          canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), paint);
          ui.Picture picture = recorder.endRecording();
          final placeholderImage = await picture.toImage(1, 1);
          
          TimelineImage imageAsset = TimelineImage();
          imageAsset.image = placeholderImage;
          asset = imageAsset;
        }
      } else {
        // Load regular image with caching
        final image = await ResourceLoader.loadImage(filename);
        if (image != null) {
          TimelineImage imageAsset = TimelineImage();
          imageAsset.image = image;
          asset = imageAsset;
        }
      }
      
      if (asset != null) {
        // Apply scale and dimensions
        double scale = 1.0;
        if (assetMap.containsKey("scale")) {
          dynamic s = assetMap["scale"];
          scale = s is int ? s.toDouble() : s;
        }
        
        dynamic width = assetMap["width"];
        asset.width = (width is int ? width.toDouble() : width) * scale;
        
        dynamic height = assetMap["height"];
        asset.height = (height is int ? height.toDouble() : height) * scale;
        asset.entry = entry;
        asset.filename = filename;
        
        entry.asset = asset;
        
        // Trigger repaint
        onNeedPaint?.call();
      }
    } catch (e) {
      debugPrint('Error loading asset for ${entry.label}: $e');
    }
  }
  
  /// Preload assets for visible/nearby entries
  void preloadVisibleAssets() {
    for (final entry in _entries) {
      if (entry.asset == null && entry.assetFilename != null && !entry.isAssetLoadScheduled) {
        final extension = getExtension(entry.assetFilename!);
        _scheduleAssetLoad(entry, extension);
      }
      
      // Also check children
      if (entry.children != null) {
        for (final child in entry.children!) {
          if (child.asset == null && child.assetFilename != null && !child.isAssetLoadScheduled) {
            final extension = getExtension(child.assetFilename!);
            _scheduleAssetLoad(child, extension);
          }
        }
      }
    }
  }

  /// Make sure while scrolling we're within the correct timeline bounds.
  clampScroll() {
    viewport.clampScroll(() {
      if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        _lastFrameTime = 0.0;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }
    });
  }

  /// Set the viewport position and dimensions.
  void setViewport({
    double start = double.infinity,
    bool pad = false,
    double end = double.infinity,
    double height = double.infinity,
    double velocity = double.infinity,
    bool animate = false,
  }) {
    if (height != double.infinity) {
      if (_height == 0.0 && _entries.isNotEmpty) {
        double scale = height / (viewport.end - viewport.start);
        viewport.start = viewport.start - padding.top / scale;
        viewport.end = viewport.end + padding.bottom / scale;
      }
      _height = height;
      viewport.height = height;
    }

    viewport.setViewport(
      newStart: start,
      newEnd: end,
      newHeight: height,
      pad: pad,
      animate: animate,
      velocity: velocity,
    );

    if (!animate) {
      advance(0.0, false);
      onNeedPaint?.call();
    } else if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  /// Frame callback for animation.
  void beginFrame(Duration timeStamp) {
    _isFrameScheduled = false;
    final double t =
        timeStamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;
    if (_lastFrameTime == 0.0) {
      _lastFrameTime = t;
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      return;
    }

    double elapsed = t - _lastFrameTime;
    _lastFrameTime = t;

    if (!advance(elapsed, true) && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }

    onNeedPaint?.call();
  }

  TickColors? findTickColors(double screen) {
    return colorManager.findTickColors(screen);
  }

  bool advance(double elapsed, bool animate) {
    if (_height <= 0) {
      return true;
    }
    
    double scale = _height / (viewport.renderEnd - viewport.renderStart);

    bool doneRendering = true;
    bool stillScaling = true;

    // Advance scroll simulation
    if (viewport.hasScrollSimulation) {
      doneRendering = false;
      viewport.advanceScroll(elapsed);
    }

    // Check gutter width
    double targetGutterWidth = _showFavorites ? TimelineConstants.gutterLeftExpanded : TimelineConstants.gutterLeft;
    double dgw = targetGutterWidth - _gutterWidth;
    if (!animate || dgw.abs() < 1) {
      _gutterWidth = targetGutterWidth;
    } else {
      doneRendering = false;
      _gutterWidth += dgw * min(1.0, elapsed * 10.0);
    }

    // Animate viewport movement
    if (viewport.animateViewport(
      elapsed, 
      animate, 
      TimelineConstants.moveSpeed, 
      TimelineConstants.moveSpeedInteracting, 
      _isInteracting
    )) {
      doneRendering = false;
    } else {
      stillScaling = false;
    }
    isScaling = stillScaling;

    scale = _height / (viewport.renderEnd - viewport.renderStart);

    // Update color positions
    colorManager.updateTickColorPositions(viewport.renderStart, scale, _height);
    colorManager.updateHeaderColorPositions(viewport.renderStart, scale, _height);

    // Interpolate header colors
    if (colorManager.interpolateHeaderColors(elapsed)) {
      doneRendering = false;
      onHeaderColorsChanged?.call(colorManager.headerBackgroundColor, colorManager.headerTextColor);
    }

    // Reset state for item advancement
    _lastEntryY = -double.infinity;
    _lastOnScreenEntryY = 0.0;
    _firstOnScreenEntryY = double.infinity;
    _lastAssetY = -double.infinity;
    _labelX = 0.0;
    _offsetDepth = 0.0;
    _currentEra = null;
    _nextEntry = null;
    _prevEntry = null;

    // Advance items
    if (_advanceItems(
        _entries, _gutterWidth + TimelineConstants.lineSpacing, scale, elapsed, animate, 0)) {
      doneRendering = false;
    }

    // Advance assets
    _renderAssets = <TimelineAsset>[];
    if (_advanceAssets(_entries, elapsed, animate, _renderAssets)) {
      doneRendering = false;
    }

    if (_nextEntryOpacity == 0.0) {
      _renderNextEntry = _nextEntry;
    }

    double targetNextEntryOpacity = _lastOnScreenEntryY > _height / 1.7 ||
            !_isSteady ||
            _distanceToNextEntry < 0.01 ||
            _nextEntry != _renderNextEntry
        ? 0.0
        : 1.0;
    double dt = targetNextEntryOpacity - _nextEntryOpacity;

    if (!animate || dt.abs() < 0.01) {
      _nextEntryOpacity = targetNextEntryOpacity;
    } else {
      doneRendering = false;
      _nextEntryOpacity += dt * min(1.0, elapsed * 10.0);
    }

    if (_prevEntryOpacity == 0.0) {
      _renderPrevEntry = _prevEntry;
    }

    double targetPrevEntryOpacity = _firstOnScreenEntryY < _height / 2.0 ||
            !_isSteady ||
            _distanceToPrevEntry < 0.01 ||
            _prevEntry != _renderPrevEntry
        ? 0.0
        : 1.0;
    dt = targetPrevEntryOpacity - _prevEntryOpacity;

    if (!animate || dt.abs() < 0.01) {
      _prevEntryOpacity = targetPrevEntryOpacity;
    } else {
      doneRendering = false;
      _prevEntryOpacity += dt * min(1.0, elapsed * 10.0);
    }

    double dl = _labelX - _renderLabelX;
    if (!animate || dl.abs() < 1.0) {
      _renderLabelX = _labelX;
    } else {
      doneRendering = false;
      _renderLabelX += dl * min(1.0, elapsed * 6.0);
    }

    if (_currentEra != _lastEra) {
      _lastEra = _currentEra;
      onEraChanged?.call(_currentEra);
    }

    if (_isSteady) {
      double dd = _offsetDepth - renderOffsetDepth;
      if (!animate || dd.abs() * TimelineConstants.depthOffset < 1.0) {
        _renderOffsetDepth = _offsetDepth;
      } else {
        doneRendering = false;
        _renderOffsetDepth += dd * min(1.0, elapsed * 12.0);
      }
    }

    return doneRendering;
  }

  double bubbleHeight(TimelineEntry entry) {
    return TimelineConstants.bubblePadding * 2.0 + entry.lineCount * TimelineConstants.bubbleTextHeight;
  }

  bool _advanceItems(List<TimelineEntry> items, double x, double scale,
      double elapsed, bool animate, int depth) {
    bool stillAnimating = false;
    double lastEnd = -double.infinity;
    
    for (int i = 0; i < items.length; i++) {
      TimelineEntry item = items[i];

      if (item.start == null) continue;
      double start = item.start! - viewport.renderStart;
      double end =
          item.type == TimelineEntryType.Era && item.end != null ? item.end! - viewport.renderStart : start;

      double y = start * scale;
      if (i > 0 && y - lastEnd < TimelineConstants.edgePadding) {
        y = lastEnd + TimelineConstants.edgePadding;
      }
      double endY = end * scale;
      lastEnd = endY;

      item.length = endY - y;

      double targetLabelY = y;
      double itemBubbleHeight = bubbleHeight(item);
      double fadeAnimationStart = itemBubbleHeight + TimelineConstants.bubblePadding / 2.0;
      if (targetLabelY - _lastEntryY < fadeAnimationStart &&
          item.type == TimelineEntryType.Era &&
          _lastEntryY + fadeAnimationStart < endY) {
        targetLabelY = _lastEntryY + fadeAnimationStart + 0.5;
      }

      double targetLabelOpacity =
          targetLabelY - _lastEntryY < fadeAnimationStart ? 0.0 : 1.0;

      if (targetLabelOpacity > 0.0 && item.targetLabelOpacity != 1.0) {
        item.delayLabel = 0.5;
      }
      item.targetLabelOpacity = targetLabelOpacity;
      if (item.delayLabel > 0.0) {
        targetLabelOpacity = 0.0;
        item.delayLabel -= elapsed;
        stillAnimating = true;
      }

      double dt = targetLabelOpacity - item.labelOpacity;
      if (!animate || dt.abs() < 0.01) {
        item.labelOpacity = targetLabelOpacity;
      } else {
        stillAnimating = true;
        item.labelOpacity += dt * min(1.0, elapsed * 25.0);
      }

      item.y = y;
      item.endY = endY;

      double targetLegOpacity = item.length > TimelineConstants.edgeRadius ? 1.0 : 0.0;
      double dtl = targetLegOpacity - item.legOpacity;
      if (!animate || dtl.abs() < 0.01) {
        item.legOpacity = targetLegOpacity;
      } else {
        stillAnimating = true;
        item.legOpacity += dtl * min(1.0, elapsed * 20.0);
      }

      double targetItemOpacity;
      if (item.parent != null) {
        targetItemOpacity = item.parent!.length < TimelineConstants.minChildLength ||
                item.parent!.endY < y
            ? 0.0
            : y > item.parent!.y ? 1.0 : 0.0;
      } else {
        targetItemOpacity = 1.0;
      }
      dtl = targetItemOpacity - item.opacity;
      if (!animate || dtl.abs() < 0.01) {
        item.opacity = targetItemOpacity;
      } else {
        stillAnimating = true;
        item.opacity += dtl * min(1.0, elapsed * 20.0);
      }

      double targetLabelVelocity = targetLabelY - item.labelY;
      double dvy = targetLabelVelocity - item.labelVelocity;
      if (dvy.abs() > _height) {
        item.labelY = targetLabelY;
        item.labelVelocity = 0.0;
      } else {
        item.labelVelocity += dvy * elapsed * 18.0;
        item.labelY += item.labelVelocity * elapsed * 20.0;
      }
      if (animate &&
          (item.labelVelocity.abs() > 0.01 ||
              targetLabelVelocity.abs() > 0.01)) {
        stillAnimating = true;
      }

      if (item.targetLabelOpacity > 0.0) {
        _lastEntryY = targetLabelY;
        if (_lastEntryY < _height && _lastEntryY > viewport.devicePadding.top) {
          _lastOnScreenEntryY = _lastEntryY;
          if (_firstOnScreenEntryY == double.infinity) {
            _firstOnScreenEntryY = _lastEntryY;
          }
        }
      }

      if (item.type == TimelineEntryType.Era &&
          y < 0 &&
          endY > _height &&
          depth > _offsetDepth) {
        _offsetDepth = depth.toDouble();
      }
      if (item.type == TimelineEntryType.Era && y < 0 && endY > _height / 2.0) {
        _currentEra = item;
      }

      if (y > _height + itemBubbleHeight) {
        item.labelY = y;
        if (_nextEntry == null) {
          _nextEntry = item;
          _distanceToNextEntry = (y - _height) / _height;
        }
      } else if (endY < viewport.devicePadding.top) {
        _prevEntry = item;
        _distanceToPrevEntry = ((y - _height) / _height).abs();
      } else if (endY < -itemBubbleHeight) {
        item.labelY = y;
      }

      double lx = x + TimelineConstants.lineSpacing + TimelineConstants.lineSpacing;
      if (lx > _labelX) {
        _labelX = lx;
      }

      if (item.children != null && item.isVisible) {
        if (_advanceItems(item.children!, x + TimelineConstants.lineSpacing + TimelineConstants.lineWidth, scale,
            elapsed, animate, depth + 1)) {
          stillAnimating = true;
        }
      }
    }
    return stillAnimating;
  }

  bool _advanceAssets(List<TimelineEntry> items, double elapsed, bool animate,
      List<TimelineAsset> renderAssets) {
    bool stillAnimating = false;
    for (TimelineEntry item in items) {
      if (item.asset != null) {
        double y = item.labelY;
        double halfHeight = _height / 2.0;
        double thresholdAssetY = y +
            ((y - halfHeight) / halfHeight) *
                TimelineConstants.parallax;
        double targetAssetY =
            thresholdAssetY - item.asset!.height * TimelineConstants.assetScreenScale / 2.0;
        double targetAssetOpacity =
            (thresholdAssetY - _lastAssetY < 0 ? 0.0 : 1.0) *
                item.opacity *
                item.labelOpacity;

        if (targetAssetOpacity > 0.0 && item.targetAssetOpacity != 1.0) {
          item.delayAsset = 0.25;
        }
        item.targetAssetOpacity = targetAssetOpacity;
        if (item.delayAsset > 0.0) {
          targetAssetOpacity = 0.0;
          item.delayAsset -= elapsed;
          stillAnimating = true;
        }

        TimelineAsset? asset = item.asset;
        if (asset == null) continue;

        double targetScale = targetAssetOpacity;
        double targetScaleVelocity = targetScale - asset.scale;
        if (!animate || targetScale == 0) {
          asset.scaleVelocity = targetScaleVelocity;
        } else {
          double dvy = targetScaleVelocity - asset.scaleVelocity;
          asset.scaleVelocity += dvy * elapsed * 18.0;
        }

        asset.scale += asset.scaleVelocity * elapsed * 20.0;
        if (animate &&
            (asset.scaleVelocity.abs() > 0.01 ||
                targetScaleVelocity.abs() > 0.01)) {
          stillAnimating = true;
        }
        if (asset.opacity == 0.0) {
          asset.y = targetAssetY;
          asset.velocity = 0.0;
        }

        double da = targetAssetOpacity - asset.opacity;
        if (!animate || da.abs() < 0.01) {
          asset.opacity = targetAssetOpacity;
        } else {
          stillAnimating = true;
          asset.opacity += da * min(1.0, elapsed * 15.0);
        }

        if (asset.opacity > 0.0) {
          double targetAssetVelocity = max(_lastAssetY, targetAssetY) - asset.y;
          double dvay = targetAssetVelocity - asset.velocity;
          if (dvay.abs() > _height) {
            asset.y = targetAssetY;
            asset.velocity = 0.0;
          } else {
            asset.velocity += dvay * elapsed * 15.0;
            asset.y += asset.velocity * elapsed * 17.0;
          }
          if (asset.velocity.abs() > 0.01 || targetAssetVelocity.abs() > 0.01) {
            stillAnimating = true;
          }

          _lastAssetY = targetAssetY +
              asset.height * TimelineConstants.assetScreenScale + TimelineConstants.assetPadding;
          if (asset.y > _height ||
              asset.y + asset.height * TimelineConstants.assetScreenScale < 0.0) {
            // Cull
          } else {
            if (asset is TimelineRive && asset.artboard != null) {
              asset.artboard!.advance(elapsed);
            }
            renderAssets.add(item.asset!);
          }
        } else {
          item.asset?.y = max(_lastAssetY, targetAssetY);
        }
      }

      if (item.children != null && item.isVisible) {
        if (_advanceAssets(item.children!, elapsed, animate, renderAssets)) {
          stillAnimating = true;
        }
      }
    }
    return stillAnimating;
  }

  // Padding accessors
  EdgeInsets padding = EdgeInsets.zero;
  EdgeInsets get devicePadding => viewport.devicePadding;
  set devicePadding(EdgeInsets value) {
    viewport.devicePadding = value;
  }
}