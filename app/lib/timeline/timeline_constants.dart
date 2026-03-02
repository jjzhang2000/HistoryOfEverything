/// Timeline layout constants for proper alignment and rendering.
class TimelineConstants {
  /// Line width and spacing
  static const double lineWidth = 2.0;
  static const double lineSpacing = 10.0;
  static const double depthOffset = lineSpacing + lineWidth;

  /// Edge and movement
  static const double edgePadding = 8.0;
  static const double moveSpeed = 10.0;
  static const double moveSpeedInteracting = 40.0;
  static const double deceleration = 3.0;
  
  /// Gutter (favorites sidebar)
  static const double gutterLeft = 45.0;
  static const double gutterLeftExpanded = 75.0;

  /// Bubble dimensions
  static const double edgeRadius = 4.0;
  static const double minChildLength = 50.0;
  static const double defaultBubbleHeight = 50.0;
  static const double bubbleArrowSize = 19.0;
  static const double bubblePadding = 20.0;
  static const double bubbleTextHeight = 20.0;
  
  /// Asset rendering
  static const double assetPadding = 30.0;
  static const double parallax = 100.0;
  static const double assetScreenScale = 0.3;
  
  /// Viewport padding
  static const double initialViewportPadding = 100.0;
  static const double travelViewportPaddingTop = 400.0;
  static const double viewportPaddingTop = 120.0;
  static const double viewportPaddingBottom = 100.0;
  
  /// Timing
  static const int steadyMilliseconds = 500;
}