import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/timeline/timeline_color_manager.dart';
import 'package:timeline/timeline/timeline_utils.dart';

void main() {
  group('TimelineColorManager', () {
    late TimelineColorManager colorManager;

    setUp(() {
      colorManager = TimelineColorManager();
    });

    test('should initialize with empty color lists', () {
      expect(colorManager.backgroundColors, isEmpty);
      expect(colorManager.tickColors, isEmpty);
      expect(colorManager.headerColors, isEmpty);
    });

    group('parseBackgroundColor', () {
      test('should parse valid background color from map', () {
        final map = <String, dynamic>{
          'background': [255, 0, 0], // Red
        };

        final result = colorManager.parseBackgroundColor(map, 0.0);

        expect(result, isNotNull);
        expect(result!.color, equals(const Color.fromARGB(255, 255, 0, 0)));
        expect(result.start, equals(0.0));
      });

      test('should return null when background is missing', () {
        final map = <String, dynamic>{};

        final result = colorManager.parseBackgroundColor(map, 0.0);

        expect(result, isNull);
      });

      test('should handle background with 3 values (RGB)', () {
        final map = <String, dynamic>{
          'background': [255, 128, 0], // Orange without alpha
        };

        final result = colorManager.parseBackgroundColor(map, 100.0);

        expect(result, isNotNull);
        expect(result!.color, equals(const Color.fromARGB(255, 255, 128, 0)));
      });
    });

    group('parseTickColors', () {
      test('should parse valid tick colors from map', () {
        final map = <String, dynamic>{
          'ticks': {
            'background': [0, 0, 0],
            'long': [255, 255, 255],
            'short': [128, 128, 128],
            'text': [255, 255, 255],
          },
        };

        final result = colorManager.parseTickColors(map, 0.0);

        expect(result, isNotNull);
        expect(result!.start, equals(0.0));
        expect(result.background, isNotNull);
        expect(result.long, isNotNull);
      });

      test('should return null when ticks is missing', () {
        final map = <String, dynamic>{};

        final result = colorManager.parseTickColors(map, 0.0);

        expect(result, isNull);
      });
    });

    group('parseHeaderColors', () {
      test('should parse valid header colors from map', () {
        final map = <String, dynamic>{
          'header': {
            'background': [0, 0, 0], // Black
            'text': [255, 255, 255], // White
          },
        };

        final result = colorManager.parseHeaderColors(map, 0.0);

        expect(result, isNotNull);
        expect(result!.start, equals(0.0));
        expect(result.background, isNotNull);
        expect(result.text, isNotNull);
      });

      test('should return null when header is missing', () {
        final map = <String, dynamic>{};

        final result = colorManager.parseHeaderColors(map, 0.0);

        expect(result, isNull);
      });
    });

    group('sortAll', () {
      test('should sort background colors by start', () {
        // Add colors in reverse order
        final bg1 = TimelineBackgroundColor()
          ..color = const Color(0xFF000001)
          ..start = 300.0;
        final bg2 = TimelineBackgroundColor()
          ..color = const Color(0xFF000002)
          ..start = 100.0;
        final bg3 = TimelineBackgroundColor()
          ..color = const Color(0xFF000003)
          ..start = 200.0;
        
        colorManager.backgroundColors.addAll([bg1, bg2, bg3]);

        colorManager.sortAll();

        expect(colorManager.backgroundColors[0].start, equals(100.0));
        expect(colorManager.backgroundColors[1].start, equals(200.0));
        expect(colorManager.backgroundColors[2].start, equals(300.0));
      });

      test('should sort tick colors by start', () {
        final tc1 = TickColors()..start = 300.0;
        final tc2 = TickColors()..start = 100.0;
        final tc3 = TickColors()..start = 200.0;
        
        colorManager.tickColors.addAll([tc1, tc2, tc3]);

        colorManager.sortAll();

        expect(colorManager.tickColors[0].start, equals(100.0));
        expect(colorManager.tickColors[1].start, equals(200.0));
        expect(colorManager.tickColors[2].start, equals(300.0));
      });

      test('should sort header colors by start', () {
        final hc1 = HeaderColors()..start = 300.0;
        final hc2 = HeaderColors()..start = 100.0;
        final hc3 = HeaderColors()..start = 200.0;
        
        colorManager.headerColors.addAll([hc1, hc2, hc3]);

        colorManager.sortAll();

        expect(colorManager.headerColors[0].start, equals(100.0));
        expect(colorManager.headerColors[1].start, equals(200.0));
        expect(colorManager.headerColors[2].start, equals(300.0));
      });
    });

    group('findTickColors', () {
      test('should return null when no tick colors', () {
        final result = colorManager.findTickColors(0.0);
        expect(result, isNull);
      });

      test('should find tick colors based on screenY', () {
        final tc1 = TickColors()
          ..start = 0.0
          ..screenY = 0.0;
        final tc2 = TickColors()
          ..start = 1000.0
          ..screenY = 500.0;
        
        colorManager.tickColors.addAll([tc1, tc2]);

        // At screenY 0, should find first color
        var result = colorManager.findTickColors(0.0);
        expect(result, isNotNull);
        expect(result!.start, equals(0.0));

        // At screenY 500, should find second color
        result = colorManager.findTickColors(500.0);
        expect(result, isNotNull);
        expect(result!.start, equals(1000.0));
      });
    });

    group('interpolateHeaderColors', () {
      test('should return false when no header colors', () {
        final result = colorManager.interpolateHeaderColors(0.016);
        expect(result, isFalse);
      });

      test('should set header colors when available', () {
        final hc = HeaderColors()
          ..start = 0.0
          ..background = Colors.black
          ..text = Colors.white
          ..screenY = 0.0;
        
        colorManager.headerColors.add(hc);

        final result = colorManager.interpolateHeaderColors(0.016);

        expect(colorManager.headerTextColor, equals(Colors.white));
        expect(colorManager.headerBackgroundColor, equals(Colors.black));
      });
    });

    group('Header color properties', () {
      test('should have null header colors initially', () {
        expect(colorManager.headerTextColor, isNull);
        expect(colorManager.headerBackgroundColor, isNull);
        expect(colorManager.currentHeaderColors, isNull);
      });
    });

    group('updateTickColorPositions', () {
      test('should update tick color positions based on scale', () {
        final tc1 = TickColors()..start = 0.0;
        final tc2 = TickColors()..start = 1000.0;
        
        colorManager.tickColors.addAll([tc1, tc2]);

        colorManager.updateTickColorPositions(0.0, 1.0, 1000.0);

        // Should not throw
        expect(colorManager.tickColors, hasLength(2));
      });
    });

    group('updateHeaderColorPositions', () {
      test('should update header color positions based on scale', () {
        final hc1 = HeaderColors()..start = 0.0;
        final hc2 = HeaderColors()..start = 1000.0;
        
        colorManager.headerColors.addAll([hc1, hc2]);

        colorManager.updateHeaderColorPositions(0.0, 1.0, 1000.0);

        // Should not throw
        expect(colorManager.headerColors, hasLength(2));
      });
    });
  });

  group('TimelineBackgroundColor', () {
    test('should store color and start', () {
      final bgColor = TimelineBackgroundColor()
        ..color = const Color(0xFFFF0000)
        ..start = 100.0;

      expect(bgColor.color, equals(const Color(0xFFFF0000)));
      expect(bgColor.start, equals(100.0));
    });
  });

  group('TickColors', () {
    test('should store colors and position', () {
      final tickColors = TickColors()
        ..background = Colors.black
        ..long = Colors.white
        ..short = Colors.grey
        ..text = Colors.white
        ..start = 100.0
        ..screenY = 50.0;

      expect(tickColors.background, equals(Colors.black));
      expect(tickColors.long, equals(Colors.white));
      expect(tickColors.short, equals(Colors.grey));
      expect(tickColors.text, equals(Colors.white));
      expect(tickColors.start, equals(100.0));
      expect(tickColors.screenY, equals(50.0));
    });
  });

  group('HeaderColors', () {
    test('should store background and text colors', () {
      final headerColors = HeaderColors()
        ..background = Colors.black
        ..text = Colors.white
        ..start = 100.0
        ..screenY = 50.0;

      expect(headerColors.background, equals(Colors.black));
      expect(headerColors.text, equals(Colors.white));
      expect(headerColors.start, equals(100.0));
      expect(headerColors.screenY, equals(50.0));
    });
  });
}