
import 'dart:math';
import 'dart:ui';

import 'package:timeline/timeline/timeline_entry.dart';

Color interpolateColor(Color from, Color to, double elapsed) {
  double r, g, b, a;
  double speed = min(1.0, elapsed * 5.0);
  double c = (to.a * 255.0) - (from.a * 255.0);
  if (c.abs() < 1.0) {
    a = to.a * 255.0;
  } else {
    a = from.a * 255.0 + c * speed;
  }

  c = (to.r * 255.0) - (from.r * 255.0);
  if (c.abs() < 1.0) {
    r = to.r * 255.0;
  } else {
    r = from.r * 255.0 + c * speed;
  }

  c = (to.g * 255.0) - (from.g * 255.0);
  if (c.abs() < 1.0) {
    g = to.g * 255.0;
  } else {
    g = from.g * 255.0 + c * speed;
  }

  c = (to.b * 255.0) - (from.b * 255.0);
  if (c.abs() < 1.0) {
    b = to.b * 255.0;
  } else {
    b = from.b * 255.0 + c * speed;
  }

  return Color.fromARGB(a.round(), r.round(), g.round(), b.round());
}

String? getExtension(String? filename) {
  if (filename == null) return null;
  int dot = filename.lastIndexOf(".");
  if (dot == -1) {
    return null;
  }
  return filename.substring(dot + 1);
}

String? removeExtension(String? filename) {
  if (filename == null) return null;
  int dot = filename.lastIndexOf(".");
  if (dot == -1) {
    return null;
  }
  return filename.substring(0, dot);
}

class TimelineBackgroundColor {
  Color? color;
  double start = 0.0;
}

class TickColors {
  Color? background;
  Color? long;
  Color? short;
  Color? text;
  double start = 0.0;
  double screenY = 0.0;
}

class HeaderColors {
  Color? background;
  Color? text;
  double start = 0.0;
  double screenY = 0.0;
}

class TapTarget {
  TimelineEntry? entry;
  Rect? rect;
  bool zoom = false;
}