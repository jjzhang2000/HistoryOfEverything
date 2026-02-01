import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/timeline/timeline.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('Timeline', () {
    late Timeline timeline;

    setUp(() {
      timeline = Timeline(TargetPlatform.android);
    });

    test('should initialize with default values', () {
      expect(timeline, isNotNull);
      expect(timeline.start, equals(1536.0));
      expect(timeline.end, equals(3072.0));
    });

    test('should initialize with different platforms', () {
      final androidTimeline = Timeline(TargetPlatform.android);
      final iOSTimeline = Timeline(TargetPlatform.iOS);

      expect(androidTimeline, isNotNull);
      expect(iOSTimeline, isNotNull);
    });

    group('setViewport', () {
      test('should set viewport with start and end', () {
        timeline.setViewport(start: 0.0, end: 1000.0);

        expect(timeline.start, equals(0.0));
        expect(timeline.end, equals(1000.0));
      });

      test('should set viewport with height', () {
        timeline.setViewport(height: 800.0);

        // Height should be set internally (not directly exposed)
        expect(timeline.renderStart, isNotNull);
        expect(timeline.renderEnd, isNotNull);
      });

      test('should set viewport with padding', () {
        timeline.padding = const EdgeInsets.all(20.0);
        timeline.setViewport(start: 0.0, end: 1000.0, pad: true);

        expect(timeline.start, lessThanOrEqualTo(0.0));
        expect(timeline.end, greaterThanOrEqualTo(1000.0));
      });

      test('should set viewport with animation', () {
        timeline.setViewport(start: 0.0, end: 1000.0, animate: true);

        // Animation should be triggered
        expect(timeline.start, equals(0.0));
        expect(timeline.end, equals(1000.0));
      });

      test('should set viewport with velocity', () {
        timeline.setViewport(velocity: 100.0, animate: true);

        // Velocity is used internally for scroll simulation
        // Just verify the call doesn't throw
        expect(timeline.isActive, isFalse);
      });
    });

    group('computeScale', () {
      test('should compute scale correctly', () {
        timeline.setViewport(start: 0.0, end: 1000.0);
        timeline.setViewport(height: 1000.0);

        final scale = timeline.computeScale(0.0, 1000.0);
        expect(scale, equals(1.0)); // 1000 years / 1000 pixels
      });

      test('should compute scale with different ranges', () {
        timeline.setViewport(start: 0.0, end: 500.0);
        timeline.setViewport(height: 1000.0);

        final scale = timeline.computeScale(0.0, 500.0);
        expect(scale, equals(2.0)); // 1000 pixels / 500 years
      });
    });

    group('screenPaddingInTime', () {
      test('should calculate screen padding in time units', () {
        timeline.setViewport(start: 0.0, end: 1000.0);
        timeline.setViewport(height: 1000.0);

        final paddingInTime = timeline.screenPaddingInTime(100.0, 0.0, 1000.0);

        expect(paddingInTime, isNotNull);
        expect(paddingInTime, equals(100.0)); // 100 pixels / 1.0 scale = 100 time units
      });
    });

    group('Timeline Properties', () {
      test('should toggle showFavorites', () {
        expect(timeline.showFavorites, isFalse);

        timeline.showFavorites = true;
        expect(timeline.showFavorites, isTrue);

        timeline.showFavorites = false;
        expect(timeline.showFavorites, isFalse);
      });

      test('should toggle isInteracting', () {
        expect(timeline.isInteracting, isFalse);

        timeline.isInteracting = true;
        expect(timeline.isInteracting, isTrue);
      });

      test('should toggle isActive', () {
        expect(timeline.isActive, isFalse);

        timeline.isActive = true;
        expect(timeline.isActive, isTrue);
      });
    });

    group('Timeline Constants', () {
      test('should have correct constants', () {
        expect(Timeline.lineWidth, equals(2.0));
        expect(Timeline.lineSpacing, equals(10.0));
        expect(Timeline.depthOffset, equals(12.0)); // LineSpacing (10.0) + LineWidth (2.0)
        expect(Timeline.edgePadding, equals(8.0));
        expect(Timeline.moveSpeed, equals(10.0));
        expect(Timeline.deceleration, equals(3.0));
        expect(Timeline.gutterLeft, equals(45.0));
      });
    });

    group('Callbacks', () {
      test('should accept onNeedPaint callback', () {
        timeline.onNeedPaint = () {};
        expect(timeline.onNeedPaint, isNotNull);
      });

      test('should accept onEraChanged callback', () {
        timeline.onEraChanged = (era) {};
        expect(timeline.onEraChanged, isNotNull);
      });

      test('should accept onHeaderColorsChanged callback', () {
        timeline.onHeaderColorsChanged = (bg, txt) {};
        expect(timeline.onHeaderColorsChanged, isNotNull);
      });
    });

    group('Device Padding', () {
      test('should set devicePadding', () {
        const padding = EdgeInsets.only(top: 44.0, bottom: 34.0);
        timeline.devicePadding = padding;

        expect(timeline.devicePadding, equals(padding));
      });
    });

    group('currentEra', () {
      test('should have null currentEra initially', () {
        expect(timeline.currentEra, isNull);
      });
    });

    group('Header Colors', () {
      test('should have null header colors initially', () {
        expect(timeline.headerTextColor, isNull);
        expect(timeline.headerBackgroundColor, isNull);
        expect(timeline.currentHeaderColors, isNull);
      });
    });

    group('nextEntry and prevEntry', () {
      test('should have null next and prev entries initially', () {
        expect(timeline.nextEntry, isNull);
        expect(timeline.prevEntry, isNull);
      });
    });

    group('Timeline Entries', () {
      test('should be ready to load entries', () {
        expect(timeline, isNotNull);
        expect(timeline.start, equals(1536.0)); // Default value
        expect(timeline.end, equals(3072.0)); // Default value
      });

      test('should accept padding', () {
        const padding = EdgeInsets.all(20.0);
        timeline.padding = padding;
        expect(timeline.padding, equals(padding));
      });
    });
  });
}
