import 'dart:math';

import 'package:flutter/material.dart';

/// Manages the timeline viewport state including position, scale, and scroll physics.
class TimelineViewport {
  /// Platform for scroll physics configuration
  final TargetPlatform platform;
  
  /// Viewport boundaries
  double start = 0.0;
  double end = 0.0;
  double renderStart = 0.0;
  double renderEnd = 0.0;
  
  /// Time range for the entire timeline
  double timeMin = 0.0;
  double timeMax = 0.0;
  
  /// Viewport dimensions
  double height = 0.0;
  
  /// Device padding
  EdgeInsets devicePadding = EdgeInsets.zero;
  EdgeInsets padding = EdgeInsets.zero;
  
  /// Scroll physics
  ScrollPhysics? _scrollPhysics;
  ScrollMetrics? _scrollMetrics;
  Simulation? _scrollSimulation;
  double _simulationTime = 0.0;
  
  /// Viewport padding constants
  final double viewportPaddingTop;
  final double viewportPaddingBottom;
  
  TimelineViewport({
    required this.platform,
    this.viewportPaddingTop = 120.0,
    this.viewportPaddingBottom = 100.0,
  });
  
  /// Compute the viewport scale from the start/end times.
  double computeScale() {
    return height == 0.0 ? 1.0 : height / (renderEnd - renderStart);
  }
  
  /// Compute scale for given start/end values
  double computeScaleFor(double s, double e) {
    return height == 0.0 ? 1.0 : height / (e - s);
  }
  
  /// Convert screen padding to time units
  double screenPaddingInTime(double pad, double s, double e) {
    return pad / computeScaleFor(s, e);
  }
  
  /// Initialize viewport with start/end values
  void setViewport({
    double newStart = double.infinity,
    double newEnd = double.infinity,
    double newHeight = double.infinity,
    bool pad = false,
    bool animate = false,
    double velocity = double.infinity,
  }) {
    /// Calculate the current height.
    if (newHeight != double.infinity) {
      if (height == 0.0 && newStart != double.infinity && newEnd != double.infinity) {
        double scale = newHeight / (end - start);
        start = start - padding.top / scale;
        end = end + padding.bottom / scale;
      }
      height = newHeight;
    }

    /// If a value for start&end has been provided, evaluate the top/bottom position
    /// for the current viewport accordingly.
    if (newStart != double.infinity && newEnd != double.infinity) {
      start = newStart;
      end = newEnd;
      if (pad && height != 0.0) {
        double scale = height / (end - start);
        start = start - padding.top / scale;
        end = end + padding.bottom / scale;
      }
    } else {
      if (newStart != double.infinity) {
        double scale = height / (end - start);
        start = pad ? newStart - padding.top / scale : newStart;
      }
      if (newEnd != double.infinity) {
        double scale = height / (end - start);
        end = pad ? newEnd + padding.bottom / scale : newEnd;
      }
    }

    /// If a velocity value has been passed, use the [ScrollPhysics] to create
    /// a simulation and perform scrolling natively to the current platform.
    if (velocity != double.infinity) {
      _initScrollSimulation(velocity);
    }

    if (!animate) {
      renderStart = start;
      renderEnd = end;
    }
  }
  
  /// Initialize scroll simulation with velocity
  void _initScrollSimulation(double velocity) {
    double scale = computeScale();
    double padTop = (devicePadding.top + viewportPaddingTop) / scale;
    double padBottom = (devicePadding.bottom + viewportPaddingBottom) / scale;
    double rangeMin = (timeMin - padTop) * scale;
    double rangeMax = (timeMax + padBottom) * scale - height;
    if (rangeMax < rangeMin) {
      rangeMax = rangeMin;
    }

    _simulationTime = 0.0;
    _scrollPhysics = platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();
    _scrollMetrics = FixedScrollMetrics(
        minScrollExtent: double.negativeInfinity,
        maxScrollExtent: double.infinity,
        pixels: 0.0,
        viewportDimension: height,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0);
    _scrollSimulation = _scrollPhysics!.createBallisticSimulation(_scrollMetrics!, velocity);
  }
  
  /// Advance scroll simulation
  /// Returns true if simulation is still active
  bool advanceScroll(double elapsed) {
    if (_scrollSimulation == null) {
      return false;
    }
    
    _simulationTime += elapsed;
    double scale = computeScaleFor(start, end);
    double velocity = _scrollSimulation!.dx(_simulationTime);
    double displace = velocity * elapsed / scale;

    start -= displace;
    end -= displace;
    
    /// If scrolling has terminated, clean up the resources.
    if (_scrollSimulation!.isDone(_simulationTime)) {
      _scrollMetrics = null;
      _scrollPhysics = null;
      _scrollSimulation = null;
      return false;
    }
    return true;
  }
  
  /// Clamp scroll position to valid bounds
  void clampScroll(void Function() scheduleFrame) {
    _scrollMetrics = null;
    _scrollPhysics = null;
    _scrollSimulation = null;

    /// Get measurements values for the current viewport.
    double scale = computeScaleFor(start, end);
    double padTop = (devicePadding.top + viewportPaddingTop) / scale;
    double padBottom = (devicePadding.bottom + viewportPaddingBottom) / scale;
    bool fixStart = start < timeMin - padTop;
    bool fixEnd = end > timeMax + padBottom;

    /// As the scale changes we need to re-solve the right padding
    for (int i = 0; i < 20; i++) {
      scale = computeScaleFor(start, end);
      padTop = (devicePadding.top + viewportPaddingTop) / scale;
      padBottom = (devicePadding.bottom + viewportPaddingBottom) / scale;
      if (fixStart) {
        start = timeMin - padTop;
      }
      if (fixEnd) {
        end = timeMax + padBottom;
      }
    }
    if (end < start) {
      end = start + height / scale;
    }
  }
  
  /// Animate viewport towards target position
  /// Returns true if still animating
  bool animateViewport(double elapsed, bool animate, double moveSpeed, double moveSpeedInteracting, bool isInteracting) {
    double scale = computeScale();
    double speed = min(1.0, elapsed * (isInteracting ? moveSpeedInteracting : moveSpeed));
    double ds = start - renderStart;
    double de = end - renderEnd;

    /// If the current view is animating, adjust the [renderStart]/[renderEnd] based on the interaction speed.
    if (!animate || ((ds * scale).abs() < 1.0 && (de * scale).abs() < 1.0)) {
      renderStart = start;
      renderEnd = end;
      return false;
    } else {
      renderStart += ds * speed;
      renderEnd += de * speed;
      return true;
    }
  }
  
  /// Check if scroll simulation is active
  bool get hasScrollSimulation => _scrollSimulation != null;
  
  /// Get current scroll simulation
  Simulation? get scrollSimulation => _scrollSimulation;
}