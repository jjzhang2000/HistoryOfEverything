import 'dart:math';
import 'dart:ui';
import "dart:ui" as ui;

// TODO: Reimplement with Rive - Flare/Nima imports removed
// import 'package:flare_flutter/flare.dart' as flare;
// import 'package:flare_dart/actor_image.dart' as flare;
// import 'package:flare_dart/math/aabb.dart' as flare;
// import 'package:flare_dart/math/mat2d.dart' as flare;
// import 'package:flare_dart/math/vec2d.dart' as flare;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
// import 'package:nima/nima.dart' as nima;
// import 'package:nima/nima/actor_image.dart' as nima;
// import 'package:nima/nima/math/aabb.dart' as nima;
// import 'package:nima/nima/math/vec2d.dart' as nima;
// import 'package:timeline/article/controllers/amelia_controller.dart';
// import 'package:timeline/article/controllers/flare_interaction_controller.dart';
// import 'package:timeline/article/controllers/newton_controller.dart';
// import 'package:timeline/article/controllers/nima_interaction_controller.dart';
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
      {Key? key, required this.isActive, this.timelineEntry, this.interactOffset})
      : super(key: key);

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

// Stub classes for controllers - TODO: Reimplement with Rive
class FlareInteractionController {
  // Stub - will be reimplemented
}

class NimaInteractionController {
  // Stub - will be reimplemented
}


/// When extending a [RenderBox] we provide a custom set of instructions for the widget being rendered.
/// 
/// In particular this means overriding the [paint()] and [hitTestSelf()] methods to render the loaded
/// Flare/Nima [FlutterActor] where the widget is being placed.
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
  // TODO: Reimplement with Rive
  // nima.FlutterActor _nimaActor;
  // flare.FlutterActorArtboard _flareActor;
  // FlareInteractionController? _flareController;
  // NimaInteractionController? _nimaController;

  /// Called whenever a new [TimelineEntry] is being set.
  updateActor() {
    // TODO: Reimplement with Rive
    // if (_timelineEntry == null) {
    //   /// If [_timelineEntry] is removed, free its resources.
    //   _nimaActor?.dispose();
    //   _flareActor?.dispose();
    //   _nimaActor = null;
    //   _flareActor = null;
    // } else {
    //   TimelineAsset asset = _timelineEntry!.asset;
    //   if (asset is TimelineNima && asset.actor != null) {
    //     /// Instance [_nimaActor] through the actor reference in the asset
    //     /// and set the initial starting value for its animation.
    //     _nimaActor = asset.actor.makeInstance();
    //     asset.animation.apply(asset.animation.duration, _nimaActor, 1.0);
    //     _nimaActor.advance(0.0);
    //     if (asset.filename == "assets/Newton/Newton_v2.nma") {
    //       /// Newton uses a custom controller! =)
    //       _nimaController = NewtonController();
    //       _nimaController.initialize(_nimaActor);
    //     }
    //   } else if (asset is TimelineFlare && asset.actor != null) {
    //     /// Instance [_flareActor] through the actor reference in the asset
    //     /// and set the initial starting value for its animation.
    //     _flareActor = asset.actor.makeInstance();
    //     _flareActor.initializeGraphics();
    //     asset.animation.apply(asset.animation.duration, _flareActor, 1.0);
    //     _flareActor.advance(0.0);
    //     if (asset.filename == "assets/Amelia_Earhart/Amelia_Earhart.flr") {
    //       /// Amelia Earhart uses a custom controller too..!
    //       _flareController = AmeliaController();
    //       _flareController.initialize(_flareActor);
    //     }
    //   }
    // }
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
      if (asset is TimelineNima) {
        asset.animationTime = 0.0;
      } else if (asset is TimelineFlare) {
        asset.animationTime = 0.0;
      }
    }
    return true;
  }

  @override
  void performResize() {
    size = constraints!.biggest;
  }

  /// This overridden method is where we can implement our custom logic, for
  /// laying out the [FlutterActor], and drawing it to [canvas].
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
    // TODO: Reimplement Nima/Flare rendering with Rive
    // else if (asset is TimelineNima && _nimaActor != null) {
    //   ...nima rendering code...
    // } else if (asset is TimelineFlare && _flareActor != null) {
    //   ...flare rendering code...
    // }
    canvas.restore();
  }

  /// This callback is used by the [SchedulerBinding] in order to advance the Flare/Nima 
  /// animations properly, and update the corresponding [FlutterActor]s.
  /// It is also responsible for advancing any attached components to said Actors,
  /// such as [_nimaController] or [_flareController].
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
    // TODO: Reimplement Nima/Flare animation with Rive
    // if (_timelineEntry != null) {
    //   TimelineAsset asset = _timelineEntry!.asset;
    //   ...animation code...
    // }

    /// Invalidate the current widget visual state and let Flutter paint it again.
    markNeedsPaint();
    /// Schedule a new frame to update again - but only if needed.
    if (isActive && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }
}
