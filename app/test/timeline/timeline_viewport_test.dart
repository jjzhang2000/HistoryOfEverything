import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/timeline/timeline_viewport.dart';

void main() {
  group('TimelineViewport', () {
    late TimelineViewport viewport;

    setUp(() {
      viewport = TimelineViewport(
        platform: TargetPlatform.android,
        viewportPaddingTop: 100.0,
        viewportPaddingBottom: 100.0,
      );
    });

    test('should initialize with default values', () {
      expect(viewport.start, equals(0.0));
      expect(viewport.end, equals(0.0));
      expect(viewport.renderStart, equals(0.0));
      expect(viewport.renderEnd, equals(0.0));
      expect(viewport.timeMin, equals(double.infinity));
      expect(viewport.timeMax, equals(-double.infinity));
    });

    group('setViewport', () {
      test('should set start and end values', () {
        viewport.setViewport(newStart: 0.0, newEnd: 1000.0);

        expect(viewport.start, equals(0.0));
        expect(viewport.end, equals(1000.0));
      });

      test('should set height', () {
        viewport.setViewport(newHeight: 800.0);

        expect(viewport.height, equals(800.0));
      });

      test('should update render values after animation', () {
        viewport.setViewport(newStart: 0.0, newEnd: 1000.0);

        // Render values should eventually match start/end
        expect(viewport.renderStart, equals(0.0));
        expect(viewport.renderEnd, equals(1000.0));
      });
    });

    group('clampScroll', () {
      test('should clamp scroll within bounds', () {
        viewport.setViewport(newStart: 0.0, newEnd: 1000.0);
        viewport.setViewport(newHeight: 500.0);
        viewport.timeMin = 0.0;
        viewport.timeMax = 2000.0;

        bool callbackCalled = false;
        viewport.clampScroll(() {
          callbackCalled = true;
        });

        // Start should be within bounds
        expect(viewport.start, greaterThanOrEqualTo(viewport.timeMin));
      });
    });

    group('computeScaleFor', () {
      test('should compute correct scale', () {
        viewport.setViewport(newHeight: 1000.0);

        // 1000 time units / 1000 pixels = scale of 1.0
        final scale = viewport.computeScaleFor(0.0, 1000.0);
        expect(scale, equals(1.0));
      });

      test('should compute scale with different ranges', () {
        viewport.setViewport(newHeight: 500.0);

        // 500 time units / 500 pixels = scale of 1.0
        final scale = viewport.computeScaleFor(0.0, 500.0);
        expect(scale, equals(1.0));
      });
    });

    group('devicePadding', () {
      test('should set and get device padding', () {
        const padding = EdgeInsets.only(top: 44.0, bottom: 34.0);
        viewport.devicePadding = padding;

        expect(viewport.devicePadding, equals(padding));
      });

      test('should have default zero padding', () {
        expect(viewport.devicePadding, equals(EdgeInsets.zero));
      });
    });

    group('Platform-specific behavior', () {
      test('should work with iOS platform', () {
        final iosViewport = TimelineViewport(
          platform: TargetPlatform.iOS,
          viewportPaddingTop: 100.0,
          viewportPaddingBottom: 100.0,
        );

        expect(iosViewport, isNotNull);
      });

      test('should work with Android platform', () {
        final androidViewport = TimelineViewport(
          platform: TargetPlatform.android,
          viewportPaddingTop: 100.0,
          viewportPaddingBottom: 100.0,
        );

        expect(androidViewport, isNotNull);
      });
    });

    group('Scroll simulation', () {
      test('should not have scroll simulation initially', () {
        expect(viewport.hasScrollSimulation, isFalse);
      });
    });

    group('animateViewport', () {
      test('should return false when not animating', () {
        viewport.setViewport(newStart: 0.0, newEnd: 1000.0);

        final isAnimating = viewport.animateViewport(
          0.0, // elapsed
          false, // animate
          10.0, // moveSpeed
          5.0, // moveSpeedInteracting
          false, // isInteracting
        );

        expect(isAnimating, isFalse);
      });
    });
  });
}