import "dart:ui" as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart';
import 'package:timeline/timeline/timeline_entry.dart';

/// This widget renders a single [TimelineEntry]. It relies on a [LeafRenderObjectWidget] 
/// so it can implement a custom [RenderObject] and update it accordingly.
class TimelineEntryWidget extends LeafRenderObjectWidget {
  /// A flag is used to animate the widget only when needed.
  final bool isActive;
  final TimelineEntry? timelineEntry;
  /// If this widget also has a custom controller, the [interactOffset]
  /// parameter can be used to detect motion effects and alter the animation accordingly.
  final Offset? interactOffset;

  const TimelineEntryWidget(
      {super.key, required this.isActive, this.timelineEntry, this.interactOffset});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return VignetteRenderObject()
      ..timelineEntry = timelineEntry
      ..isActive = isActive
      ..interactOffset = interactOffset;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant VignetteRenderObject renderObject) {
    renderObject
      ..timelineEntry = timelineEntry
      ..isActive = isActive
      ..interactOffset = interactOffset;
  }

  @override
  didUnmountRenderObject(covariant VignetteRenderObject renderObject) {
    renderObject
      ..isActive = false
      ..timelineEntry = null;
  }
}

/// When extending a [RenderBox] we provide a custom set of instructions for the widget being rendered.
/// 
/// In particular this means overriding the [paint()] and [hitTestSelf()] methods to render the loaded
/// Rive animations or static images where the widget is being placed.
class VignetteRenderObject extends RenderBox {
  static const Alignment alignment = Alignment.center;
  static const BoxFit fit = BoxFit.contain;
  
  bool _isActive = false;
  bool _firstUpdate = true;
  bool _isFrameScheduled = false;
  double _lastFrameTime = 0.0;
  Offset? interactOffset;
  Offset? _renderOffset;

  TimelineEntry? _timelineEntry;

  /// Called whenever a new [TimelineEntry] is being set.
  /// Rive animations are already loaded in TimelineRive, so no additional setup needed here.
  updateActor() {
    // Rive animations are managed by TimelineRive class
    // The artboard is already initialized in timeline.dart
    _firstUpdate = true;
  }

  /// Uses the [SchedulerBinding] to trigger a new paint for this widget.
  void updateRendering() {
    if (_isActive && _timelineEntry != null) {
      markNeedsPaint();
      if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }
    }
    markNeedsLayout();
  }

  TimelineEntry? get timelineEntry => _timelineEntry;
  set timelineEntry(TimelineEntry? value) {
    if (_timelineEntry == value) {
      return;
    }
    _timelineEntry = value;
    _firstUpdate = true;
    updateActor();
    updateRendering();
  }


  bool get isActive => _isActive;
  set isActive(bool value) {
    if (_isActive == value) {
      return;
    }
    _isActive = value;
    updateRendering();
  }

  /// The size of this widget is determined by its parent, for optimization purposes.
  @override
  bool get sizedByParent => true;

  /// Determine if this widget has been tapped. If that's the case, restart its animation.
  @override
  bool hitTestSelf(Offset screenOffset) {
    if (_timelineEntry != null) {
      TimelineAsset? asset = _timelineEntry!.asset;
      if (asset is TimelineRive) {
        asset.animationTime = 0.0;
      } else if (asset is TimelineNima) {
        asset.animationTime = 0.0;
      } else if (asset is TimelineFlare) {
        asset.animationTime = 0.0;
      }
    }
    return true;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  /// This overridden method is where we can implement our custom logic, for
  /// laying out the animation assets, and drawing it to [canvas].
  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    TimelineAsset? asset = _timelineEntry?.asset;
    _renderOffset = offset;

    /// Don't paint if not needed.
    if (_timelineEntry == null || asset == null) {
      return;
    }

    canvas.save();

    double w = asset.width;
    double h = asset.height;

    /// If the asset is just a static image, draw the image directly to [canvas].
    if (asset is TimelineImage && asset.image != null) {
      canvas.drawImageRect(
          asset.image!,
          Rect.fromLTWH(0.0, 0.0, asset.width, asset.height),
          Rect.fromLTWH(offset.dx + size.width - w, asset.y, w, h),
          Paint()
            ..isAntiAlias = true
            ..filterQuality = ui.FilterQuality.low
            ..color = Colors.white.withValues(alpha: asset.opacity));
    } 
    /// Render Rive animation
    else if (asset is TimelineRive && asset.artboard != null) {
      final artboard = asset.artboard!;
      
      // Calculate the position for the animation
      double x = offset.dx + size.width - w;
      double y = asset.y;
      
      // Apply transformation for positioning
      canvas.translate(x, y);
      
      // Draw the Rive artboard directly on canvas
      // Note: Rive artboards are drawn using their draw method
      artboard.draw(canvas);
    }
    
    canvas.restore();
  }

  /// This callback is used by the [SchedulerBinding] in order to advance the 
  /// animations properly, and update the corresponding artboards.
  void beginFrame(Duration timeStamp) {
    _isFrameScheduled = false;
    final double t =
        timeStamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;
    if (_lastFrameTime == 0) {
      _lastFrameTime = t;
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      return;
    }

    /// Calculate the elapsed time to [advance()] the animations.
    double elapsed = t - _lastFrameTime;
    _lastFrameTime = t;
    
    // Advance Rive animation if it's a Rive asset
    if (_timelineEntry != null) {
      TimelineAsset? asset = _timelineEntry!.asset;
      if (asset is TimelineRive && asset.artboard != null) {
        asset.artboard!.advance(elapsed);
      }
    }

    /// Invalidate the current widget visual state and let Flutter paint it again.
    markNeedsPaint();
    /// Schedule a new frame to update again - but only if needed.
    if (isActive && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }
}
