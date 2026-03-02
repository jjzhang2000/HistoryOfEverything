import 'package:flutter/material.dart';

import 'timeline_utils.dart';

/// Manages timeline colors including background gradients, tick colors, and header colors.
class TimelineColorManager {
  List<TimelineBackgroundColor> backgroundColors = [];
  List<TickColors> tickColors = [];
  List<HeaderColors> headerColors = [];
  
  /// Current header colors (interpolated)
  Color? headerTextColor;
  Color? headerBackgroundColor;
  HeaderColors? currentHeaderColors;
  
  /// Parse background color from JSON
  TimelineBackgroundColor? parseBackgroundColor(Map map, double start) {
    if (!map.containsKey("background")) return null;
    
    dynamic bg = map["background"];
    if (bg is! List || bg.length < 3) return null;
    
    return TimelineBackgroundColor()
      ..color = Color.fromARGB(255, bg[0] as int, bg[1] as int, bg[2] as int)
      ..start = start;
  }
  
  /// Parse tick colors from JSON
  TickColors? parseTickColors(Map map, double start) {
    if (!map.containsKey("ticks")) return null;
    
    dynamic ticks = map["ticks"];
    if (ticks is! Map) return null;
    
    Color bgColor = _parseColor(ticks["background"], Colors.black);
    Color longColor = _parseColor(ticks["long"], Colors.black);
    Color shortColor = _parseColor(ticks["short"], Colors.black);
    Color textColor = _parseColor(ticks["text"], Colors.black);
    
    return TickColors()
      ..background = bgColor
      ..long = longColor
      ..short = shortColor
      ..text = textColor
      ..start = start
      ..screenY = 0.0;
  }
  
  /// Parse header colors from JSON
  HeaderColors? parseHeaderColors(Map map, double start) {
    if (!map.containsKey("header")) return null;
    
    dynamic header = map["header"];
    if (header is! Map) return null;
    
    Color bgColor = _parseColor(header["background"], Colors.black);
    Color textColor = _parseColor(header["text"], Colors.black);
    
    return HeaderColors()
      ..background = bgColor
      ..text = textColor
      ..start = start
      ..screenY = 0.0;
  }
  
  /// Helper to parse color from JSON array
  Color _parseColor(dynamic value, Color defaultColor) {
    if (value is! List || value.length < 3) return defaultColor;
    
    return Color.fromARGB(
      value.length > 3 ? value[3] as int : 255,
      value[0] as int,
      value[1] as int,
      value[2] as int,
    );
  }
  
  /// Sort all color lists by start time
  void sortAll() {
    backgroundColors.sort((a, b) => a.start.compareTo(b.start));
    tickColors.sort((a, b) => a.start.compareTo(b.start));
    headerColors.sort((a, b) => a.start.compareTo(b.start));
  }
  
  /// Update screen Y positions for tick colors
  void updateTickColorPositions(double renderStart, double scale, double height) {
    if (tickColors.isEmpty) return;
    
    double lastStart = tickColors.first.start;
    for (TickColors color in tickColors) {
      color.screenY = (lastStart + (color.start - lastStart / 2.0) - renderStart) * scale;
      lastStart = color.start;
    }
  }
  
  /// Update screen Y positions for header colors
  void updateHeaderColorPositions(double renderStart, double scale, double height) {
    if (headerColors.isEmpty) return;
    
    double lastStart = headerColors.first.start;
    for (HeaderColors color in headerColors) {
      color.screenY = (lastStart + (color.start - lastStart / 2.0) - renderStart) * scale;
      lastStart = color.start;
    }
  }
  
  /// Find tick colors for a given screen position
  TickColors? findTickColors(double screen) {
    if (tickColors.isEmpty) return null;
    
    for (TickColors color in tickColors.reversed) {
      if (screen >= color.screenY) {
        return color;
      }
    }
    
    return screen < tickColors.first.screenY
        ? tickColors.first
        : tickColors.last;
  }
  
  /// Find header colors for a given screen position
  HeaderColors? findHeaderColors(double screen) {
    if (headerColors.isEmpty) return null;
    
    for (HeaderColors color in headerColors.reversed) {
      if (screen >= color.screenY) {
        return color;
      }
    }
    
    return screen < headerColors.first.screenY
        ? headerColors.first
        : headerColors.last;
  }
  
  /// Interpolate header colors over time
  /// Returns true if colors are still animating
  bool interpolateHeaderColors(double elapsed) {
    currentHeaderColors = findHeaderColors(0.0);
    
    if (currentHeaderColors == null) return false;
    
    if (headerTextColor == null) {
      headerTextColor = currentHeaderColors!.text;
      headerBackgroundColor = currentHeaderColors!.background;
      return false;
    }
    
    bool stillColoring = false;
    
    Color newTextColor = interpolateColor(
        headerTextColor!, currentHeaderColors!.text!, elapsed);
    
    if (newTextColor != headerTextColor) {
      headerTextColor = newTextColor;
      stillColoring = true;
    }
    
    Color newBgColor = interpolateColor(
        headerBackgroundColor!, currentHeaderColors!.background!, elapsed);
    
    if (newBgColor != headerBackgroundColor) {
      headerBackgroundColor = newBgColor;
      stillColoring = true;
    }
    
    return stillColoring;
  }
}