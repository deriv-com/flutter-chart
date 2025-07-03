import 'dart:math' as math;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Represents a single Fibonacci level with all its associated properties.
///
/// This class encapsulates the ratio, label, and color key for each
/// Fibonacci retracement level, providing a more structured and
/// maintainable approach to managing level data.
@immutable
class FibonacciLevel {
  /// Creates a new Fibonacci level with the specified properties.
  const FibonacciLevel({
    required this.ratio,
    required this.label,
    required this.colorKey,
  });

  /// The mathematical ratio for this Fibonacci level (0.0 to 1.0).
  final double ratio;

  /// Human-readable percentage label (e.g., "38.2%", "61.8%").
  final String label;

  /// Color key for customizable styling (e.g., "level38_2").
  final String colorKey;

  @override
  String toString() =>
      'FibonacciLevel(ratio: $ratio, label: $label, colorKey: $colorKey)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FibonacciLevel &&
          runtimeType == other.runtimeType &&
          ratio == other.ratio &&
          label == other.label &&
          colorKey == other.colorKey;

  @override
  int get hashCode => ratio.hashCode ^ label.hashCode ^ colorKey.hashCode;
}

/// Constants for Fibonacci Fan drawing operations.
///
/// This class centralizes all magic numbers used throughout the Fibonacci Fan
/// implementation to improve maintainability and provide clear semantic meaning
/// to numerical values.
class FibfanConstants {
  /// Private constructor to prevent instantiation of this utility class.
  FibfanConstants._();

  // ========== Validation Thresholds ==========

  /// Minimum meaningful delta threshold for coordinate differences.
  ///
  /// Used to determine if the difference between two coordinates is significant
  /// enough to warrant drawing operations. Values below this threshold are
  /// considered too small to be visually meaningful.
  static const double defaultDeltaThreshold = 1;

  /// Threshold for detecting vertical lines to avoid division by zero.
  ///
  /// When the horizontal delta (deltaX) is below this threshold, the line
  /// is considered vertical and special handling is applied to avoid
  /// mathematical errors in slope calculations.
  static const double verticalLineThreshold = 0.001;

  /// Minimum line length required for processing fan lines.
  ///
  /// Lines shorter than this value are skipped during hit testing and
  /// other operations to avoid unnecessary calculations and potential
  /// visual artifacts.
  static const double minLineLength = 1;

  // ========== Mobile Positioning Constants ==========

  /// X-axis ratio for positioning the start point on mobile devices.
  ///
  /// Represents the fraction of screen width where the fan's start point
  /// should be positioned (6% from the left edge).
  static const double mobileStartXRatio = 0.06;

  /// Y-axis ratio for positioning the start point on mobile devices.
  ///
  /// Represents the fraction of screen height where the fan's start point
  /// should be positioned (50% - center vertically).
  static const double mobileStartYRatio = 0.5;

  /// X-axis ratio for positioning the end point on mobile devices.
  ///
  /// Represents the fraction of screen width where the fan's end point
  /// should be positioned (65% from the left edge).
  static const double mobileEndXRatio = 0.65;

  /// Y-axis ratio for positioning the end point on mobile devices.
  ///
  /// Represents the fraction of screen height where the fan's end point
  /// should be positioned (30% - upper portion of screen).
  static const double mobileEndYRatio = 0.3;

  /// Fallback X coordinate when screen size is unavailable on mobile.
  ///
  /// Used as a default horizontal position when the drawing context
  /// cannot provide accurate screen dimensions.
  static const double mobileFallbackX = 50;

  /// Fallback Y coordinate when screen size is unavailable on mobile.
  ///
  /// Used as a default vertical position when the drawing context
  /// cannot provide accurate screen dimensions. Negative value places
  /// the point above the start point.
  static const double mobileFallbackY = -50;

  // ========== Drawing Constants ==========

  /// Width of each dash segment in dashed lines.
  ///
  /// Controls the length of visible segments when drawing dashed
  /// preview lines in mobile mode.
  static const double dashWidth = 5;

  /// Width of each space between dash segments.
  ///
  /// Controls the length of invisible gaps between visible segments
  /// in dashed preview lines.
  static const double dashSpace = 3;

  /// Opacity level for dashed preview lines.
  ///
  /// Applied to preview fan lines to make them visually distinct
  /// from final drawn lines (70% opacity).
  static const double dashOpacity = 0.7;

  /// Radius for drawing endpoint circles.
  ///
  /// Size of the circular indicators drawn at the start and end
  /// points of the Fibonacci fan.
  static const double pointRadius = 4;

  // ========== Visual Effect Constants ==========

  /// Radius of the focused circle effect around endpoints.
  ///
  /// Size of the glowing circle effect displayed around fan endpoints
  /// when the drawing is selected or being dragged.
  static const double focusedCircleRadius = 10;

  /// Stroke width of the focused circle effect.
  ///
  /// Thickness of the border for the glowing circle effect around
  /// fan endpoints during interaction states.
  static const double focusedCircleStroke = 3;

  /// Distance offset for labels from their corresponding fan lines.
  ///
  /// Horizontal spacing between Fibonacci level labels and their
  /// associated trend lines to prevent visual overlap.
  static const double labelDistanceFromLine = 5;

  /// Multiplier for positioning labels along fan lines.
  ///
  /// Factor used to position labels slightly beyond the fan endpoint
  /// along each trend line (102% of the line length).
  static const double labelPositionMultiplier = 1.02;

  /// Font size for Fibonacci level labels.
  ///
  /// Text size used for displaying percentage labels (0%, 38.2%, etc.)
  /// next to each fan line.
  static const double labelFontSize = 12;

  // ========== Fill Opacity Constants ==========

  /// Opacity for even-indexed fill areas between fan lines.
  ///
  /// Applied to alternating fill regions to create visual distinction
  /// between different Fibonacci levels (10% opacity).
  static const double evenFillOpacity = 0.1;

  /// Opacity for odd-indexed fill areas between fan lines.
  ///
  /// Applied to alternating fill regions to create visual distinction
  /// between different Fibonacci levels (5% opacity).
  static const double oddFillOpacity = 0.05;

  // ========== UI Constants ==========

  /// Size for toolbar icons (width and height).
  ///
  /// Dimensions for interactive elements in the drawing tool's
  /// configuration toolbar (32x32 pixels).
  static const double toolbarIconSize = 32;

  /// Spacing between toolbar elements.
  ///
  /// Horizontal gap between different controls in the drawing
  /// tool's configuration toolbar.
  static const double toolbarSpacing = 4;

  /// Border radius for toolbar buttons.
  ///
  /// Corner rounding applied to interactive buttons in the
  /// drawing tool's configuration interface.
  static const double toolbarBorderRadius = 4;

  /// Font size for toolbar text elements.
  ///
  /// Text size used for labels and values displayed in the
  /// drawing tool's configuration toolbar.
  static const double toolbarFontSize = 14;

  /// Line height multiplier for toolbar text.
  ///
  /// Vertical spacing factor applied to text elements in the
  /// toolbar to ensure proper vertical alignment.
  static const double toolbarTextHeight = 2;

  // ========== Coordinate Defaults ==========

  /// Default coordinate value for fallback scenarios.
  ///
  /// Used as a safe default when coordinate calculations fail
  /// or when initializing coordinate values.
  static const double defaultCoordinate = 0;
}

/// Helper class for Fibonacci Fan drawing operations.
///
/// This class provides static methods and constants for drawing Fibonacci Fan
/// technical analysis tools on charts. Fibonacci fans are used to identify
/// potential support and resistance levels based on Fibonacci ratios.
///
/// The fan consists of multiple trend lines drawn from a base point, each
/// representing different Fibonacci retracement levels (0%, 38.2%, 50%, 61.8%, 100%).
///
/// **Performance Optimization:**
/// This class implements paint object caching to improve rendering performance
/// by reusing Paint objects instead of creating new ones for each draw operation.
class FibonacciFanHelpers {
  /// Cache for line paint objects to improve performance.
  ///
  /// Maps paint configuration keys to reusable Paint objects. This prevents
  /// the overhead of creating new Paint objects for each drawing operation,
  /// which can significantly improve performance during animations and
  /// frequent redraws.
  ///
  /// **Cache Key Format:** `"line_${color.value}_${thickness}"`
  static final Map<String, Paint> _linePaintCache = <String, Paint>{};

  /// Cache for fill paint objects to improve performance.
  ///
  /// Maps paint configuration keys to reusable Paint objects for fill operations.
  /// This is particularly beneficial for drawing the filled areas between
  /// fan lines, which can involve multiple fill operations per frame.
  ///
  /// **Cache Key Format:** `"fill_${color.value}_${thickness}"`
  static final Map<String, Paint> _fillPaintCache = <String, Paint>{};

  /// Cache for dash paint objects to improve performance.
  ///
  /// Maps paint configuration keys to reusable Paint objects for dashed lines.
  /// Used primarily in mobile preview mode where dashed lines are drawn
  /// frequently during user interactions.
  ///
  /// **Cache Key Format:** `"dash_${color.value}_${thickness}_${opacity}"`
  static final Map<String, Paint> _dashPaintCache = <String, Paint>{};

  /// Cache for text painter objects to improve label rendering performance.
  ///
  /// Maps text configuration keys to reusable TextPainter objects. This is
  /// especially beneficial for Fibonacci level labels which are drawn
  /// repeatedly with the same styling.
  ///
  /// **Cache Key Format:** `"text_${text}_${color.value}_${fontSize}"`
  static final Map<String, TextPainter> _textPainterCache =
      <String, TextPainter>{};

  /// Gets or creates a cached line paint object.
  ///
  /// Returns a reusable Paint object configured for line drawing. If a paint
  /// object with the same configuration already exists in the cache, it is
  /// returned. Otherwise, a new one is created, cached, and returned.
  ///
  /// **Parameters:**
  /// - [color]: Line color
  /// - [thickness]: Line thickness
  ///
  /// **Returns:** Cached or newly created Paint object for line drawing
  ///
  /// **Performance Benefit:** Eliminates Paint object allocation overhead
  /// during frequent drawing operations, especially during animations.
  static Paint getCachedLinePaint(Color color, double thickness) {
    final String key = 'line_${color.value}_$thickness';
    return _linePaintCache.putIfAbsent(
        key,
        () => Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness);
  }

  /// Gets or creates a cached fill paint object.
  ///
  /// Returns a reusable Paint object configured for fill operations. This is
  /// particularly useful for drawing the filled areas between fan lines.
  ///
  /// **Parameters:**
  /// - [color]: Fill color
  /// - [thickness]: Stroke thickness (for fill border if applicable)
  ///
  /// **Returns:** Cached or newly created Paint object for fill operations
  ///
  /// **Performance Benefit:** Reduces memory allocation during fill operations,
  /// which can be frequent when drawing multiple fan fill areas.
  static Paint getCachedFillPaint(Color color, double thickness) {
    final String key = 'fill_${color.value}_$thickness';
    return _fillPaintCache.putIfAbsent(
        key,
        () => Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeWidth = thickness);
  }

  /// Gets or creates a cached dash paint object.
  ///
  /// Returns a reusable Paint object configured for dashed line drawing.
  /// Used primarily in mobile preview mode for drawing dashed fan lines.
  ///
  /// **Parameters:**
  /// - [color]: Dash line color
  /// - [thickness]: Dash line thickness
  /// - [opacity]: Dash line opacity (0.0 to 1.0)
  ///
  /// **Returns:** Cached or newly created Paint object for dashed lines
  ///
  /// **Performance Benefit:** Optimizes mobile preview performance where
  /// dashed lines are drawn frequently during user interactions.
  static Paint getCachedDashPaint(
      Color color, double thickness, double opacity) {
    final String key = 'dash_${color.value}_${thickness}_$opacity';
    return _dashPaintCache.putIfAbsent(
        key,
        () => Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness);
  }

  /// Gets or creates a cached text painter object.
  ///
  /// Returns a reusable TextPainter object configured for text rendering.
  /// This is especially beneficial for Fibonacci level labels which use
  /// consistent styling and are drawn repeatedly.
  ///
  /// **Parameters:**
  /// - [text]: Text content to render
  /// - [color]: Text color
  /// - [fontSize]: Text font size
  ///
  /// **Returns:** Cached or newly created TextPainter object
  ///
  /// **Performance Benefit:** Eliminates TextPainter creation and layout
  /// overhead for repeated label rendering, significantly improving
  /// performance during animations and frequent redraws.
  static TextPainter getCachedTextPainter(
      String text, Color color, double fontSize) {
    final String key = 'text_${text}_${color.value}_$fontSize';
    return _textPainterCache.putIfAbsent(key, () {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return textPainter;
    });
  }

  /// Clears all paint and text painter caches.
  ///
  /// This method should be called when memory optimization is needed or
  /// when the drawing configuration has changed significantly. It's
  /// recommended to call this during major theme changes or when the
  /// drawing tool is no longer in use.
  ///
  /// **Use Cases:**
  /// - Memory cleanup during app lifecycle events
  /// - Theme changes that invalidate cached paint objects
  /// - Drawing tool deactivation
  ///
  /// **Performance Note:** After clearing caches, the next drawing operations
  /// will recreate paint objects, so avoid calling this during active drawing.
  static void clearPaintCaches() {
    _linePaintCache.clear();
    _fillPaintCache.clear();
    _dashPaintCache.clear();
    _textPainterCache.clear();
  }

  /// Clears only the text painter cache.
  ///
  /// This method provides selective cache invalidation for text painters
  /// without affecting paint object caches. Use this when text styling
  /// changes but paint configurations remain the same.
  ///
  /// **Use Cases:**
  /// - Font size changes in user preferences
  /// - Text color theme updates
  /// - Label content modifications
  /// - Localization changes affecting label text
  ///
  /// **Performance Benefit:** Preserves paint object caches while ensuring
  /// text rendering reflects the latest styling changes.
  static void clearTextPainterCache() {
    _textPainterCache.clear();
  }

  /// Clears text painter cache entries for a specific color.
  ///
  /// Provides targeted cache invalidation when only specific color
  /// configurations have changed. This is more efficient than clearing
  /// the entire text painter cache.
  ///
  /// **Parameters:**
  /// - [color]: The color for which to clear cached text painters
  ///
  /// **Use Cases:**
  /// - Single color theme updates
  /// - User customization of specific Fibonacci level colors
  /// - Selective color scheme changes
  ///
  /// **Performance Benefit:** Preserves text painters with other colors,
  /// reducing the need to recreate unaffected cache entries.
  static void clearTextPainterCacheForColor(Color color) {
    _textPainterCache.removeWhere((key, _) => key.contains('_${color.value}_'));
  }

  /// Clears text painter cache entries for a specific font size.
  ///
  /// Provides targeted cache invalidation when font size preferences
  /// change. This is more efficient than clearing the entire cache
  /// when only font size has been modified.
  ///
  /// **Parameters:**
  /// - [fontSize]: The font size for which to clear cached text painters
  ///
  /// **Use Cases:**
  /// - User font size preference changes
  /// - Accessibility font scaling updates
  /// - Dynamic font size adjustments
  ///
  /// **Performance Benefit:** Preserves text painters with other font sizes,
  /// maintaining cache efficiency for unaffected configurations.
  static void clearTextPainterCacheForFontSize(double fontSize) {
    _textPainterCache.removeWhere((key, _) => key.endsWith('_$fontSize'));
  }

  /// Clears only paint object caches, preserving text painter cache.
  ///
  /// This method provides selective cache invalidation for paint objects
  /// without affecting text painter caches. Use this when paint styling
  /// changes but text configurations remain the same.
  ///
  /// **Use Cases:**
  /// - Line thickness changes
  /// - Paint color updates (non-text)
  /// - Stroke style modifications
  /// - Fill opacity adjustments
  ///
  /// **Performance Benefit:** Preserves text painter caches while ensuring
  /// paint rendering reflects the latest styling changes.
  static void clearPaintObjectCaches() {
    _linePaintCache.clear();
    _fillPaintCache.clear();
    _dashPaintCache.clear();
  }

  /// Gets cache statistics for performance monitoring.
  ///
  /// Returns information about the current state of all paint caches.
  /// This can be useful for performance monitoring and optimization.
  ///
  /// **Returns:** Map containing cache sizes and memory usage information
  ///
  /// **Example:**
  /// ```dart
  /// final stats = FibonacciFanHelpers.getCacheStats();
  /// print('Line paint cache size: ${stats['linePaintCacheSize']}');
  /// ```
  static Map<String, int> getCacheStats() {
    return {
      'linePaintCacheSize': _linePaintCache.length,
      'fillPaintCacheSize': _fillPaintCache.length,
      'dashPaintCacheSize': _dashPaintCache.length,
      'textPainterCacheSize': _textPainterCache.length,
    };
  }

  /// Validates that all coordinates in the given offsets are not NaN.
  ///
  /// This method checks a list of [Offset] objects to ensure that both
  /// their x and y coordinates are valid numbers (not NaN). This is
  /// essential for preventing rendering errors when drawing operations
  /// encounter invalid coordinate data.
  ///
  /// **Parameters:**
  /// - [offsets]: List of coordinate points to validate
  ///
  /// **Returns:**
  /// - `true` if all coordinates are valid (not NaN)
  /// - `false` if any coordinate contains NaN values
  ///
  /// **Example:**
  /// ```dart
  /// final points = [Offset(10, 20), Offset(30, 40)];
  /// if (FibonacciFanHelpers.areCoordinatesValid(points)) {
  ///   // Safe to proceed with drawing operations
  /// }
  /// ```
  static bool areCoordinatesValid(List<Offset> offsets) {
    return offsets.every((offset) => !offset.dx.isNaN && !offset.dy.isNaN);
  }

  /// Validates that a single offset has valid coordinates.
  ///
  /// Checks whether both x and y coordinates of an [Offset] are valid
  /// numbers (not NaN). This is a fundamental validation used throughout
  /// the drawing operations to prevent mathematical errors.
  ///
  /// **Parameters:**
  /// - [offset]: The coordinate point to validate
  ///
  /// **Returns:**
  /// - `true` if both x and y coordinates are valid numbers
  /// - `false` if either coordinate is NaN
  ///
  /// **Example:**
  /// ```dart
  /// final point = Offset(mouseX, mouseY);
  /// if (FibonacciFanHelpers.isOffsetValid(point)) {
  ///   // Safe to use this point for calculations
  /// }
  /// ```
  static bool isOffsetValid(Offset offset) {
    return !offset.dx.isNaN && !offset.dy.isNaN;
  }

  /// Validates that two offsets have valid coordinates.
  ///
  /// Convenience method that checks both offsets for coordinate validity.
  /// This is commonly used when validating start and end points before
  /// performing line drawing or geometric calculations.
  ///
  /// **Parameters:**
  /// - [offset1]: First coordinate point to validate
  /// - [offset2]: Second coordinate point to validate
  ///
  /// **Returns:**
  /// - `true` if both offsets have valid coordinates
  /// - `false` if either offset contains NaN values
  ///
  /// **Example:**
  /// ```dart
  /// if (FibonacciFanHelpers.areTwoOffsetsValid(startPoint, endPoint)) {
  ///   // Safe to draw line between these points
  /// }
  /// ```
  static bool areTwoOffsetsValid(Offset offset1, Offset offset2) {
    return isOffsetValid(offset1) && isOffsetValid(offset2);
  }

  /// Validates that coordinate deltas are meaningful (not too small).
  ///
  /// Determines whether the difference between two coordinates is large
  /// enough to warrant drawing operations. Very small deltas can cause
  /// visual artifacts or unnecessary computational overhead.
  ///
  /// **Parameters:**
  /// - [deltaX]: Horizontal coordinate difference
  /// - [deltaY]: Vertical coordinate difference
  /// - [threshold]: Minimum meaningful difference (defaults to [FibfanConstants.defaultDeltaThreshold])
  ///
  /// **Returns:**
  /// - `true` if either delta exceeds the threshold
  /// - `false` if both deltas are below the threshold
  ///
  /// **Example:**
  /// ```dart
  /// final deltaX = endPoint.dx - startPoint.dx;
  /// final deltaY = endPoint.dy - startPoint.dy;
  /// if (FibonacciFanHelpers.areDeltasMeaningful(deltaX, deltaY)) {
  ///   // Proceed with drawing the fan
  /// }
  /// ```
  static bool areDeltasMeaningful(double deltaX, double deltaY,
      {double threshold = FibfanConstants.defaultDeltaThreshold}) {
    return deltaX.abs() > threshold || deltaY.abs() > threshold;
  }

  /// Fibonacci levels in the desired visual order for drawing operations.
  ///
  /// This list defines all Fibonacci retracement levels used in the fan,
  /// ordered from flattest to steepest for proper visual layering.
  /// Each level contains its ratio, display label, and color key.
  ///
  /// **Visual Order (bottom to top):**
  /// 1. 0% (0.0) - Baseline level (horizontal, flattest)
  /// 2. 38.2% (0.382) - First major retracement level
  /// 3. 50% (0.5) - Midpoint retracement (commonly used)
  /// 4. 61.8% (0.618) - Golden ratio retracement level
  /// 5. 100% (1.0) - Steepest line, full retracement
  ///
  /// **Benefits of this approach:**
  /// - Single source of truth for all level data
  /// - Consistent ordering across all operations
  /// - Type-safe access to level properties
  /// - Easy to add/remove/modify levels
  /// - Eliminates data duplication
  static const List<FibonacciLevel> fibonacciLevels = [
    FibonacciLevel(ratio: 0, label: '0%', colorKey: 'level0'),
    FibonacciLevel(ratio: 0.382, label: '38.2%', colorKey: 'level38_2'),
    FibonacciLevel(ratio: 0.5, label: '50%', colorKey: 'level50'),
    FibonacciLevel(ratio: 0.618, label: '61.8%', colorKey: 'level61_8'),
    FibonacciLevel(ratio: 1, label: '100%', colorKey: 'level100'),
  ];

  /// Gets a Fibonacci level by its ratio value.
  ///
  /// Provides convenient access to level data when you have the ratio.
  /// Returns null if no level with the specified ratio exists.
  ///
  /// **Parameters:**
  /// - [ratio]: The mathematical ratio to search for
  ///
  /// **Returns:** The matching FibonacciLevel or null if not found
  ///
  /// **Example:**
  /// ```dart
  /// final goldenLevel = FibonacciFanHelpers.getLevelByRatio(0.618);
  /// print(goldenLevel?.label); // "61.8%"
  /// ```
  static FibonacciLevel? getLevelByRatio(double ratio) {
    try {
      return fibonacciLevels.firstWhere((level) => level.ratio == ratio);
    } on StateError {
      return null;
    }
  }

  /// Gets a Fibonacci level by its color key.
  ///
  /// Provides convenient access to level data when you have the color key.
  /// Returns null if no level with the specified color key exists.
  ///
  /// **Parameters:**
  /// - [colorKey]: The color key to search for
  ///
  /// **Returns:** The matching FibonacciLevel or null if not found
  ///
  /// **Example:**
  /// ```dart
  /// final level = FibonacciFanHelpers.getLevelByColorKey('level61_8');
  /// print(level?.ratio); // 0.618
  /// ```
  static FibonacciLevel? getLevelByColorKey(String colorKey) {
    try {
      return fibonacciLevels.firstWhere((level) => level.colorKey == colorKey);
    } on StateError {
      return null;
    }
  }

  /// Draws the filled areas between fan lines using angle-based calculations.
  ///
  /// Creates alternating filled regions between adjacent Fibonacci fan lines
  /// to provide visual distinction between different retracement levels.
  /// The fill areas help users identify price zones more easily.
  ///
  /// **Algorithm:**
  /// 1. Calculates the base angle from start to end point
  /// 2. For each Fibonacci ratio, calculates the angle as a percentage of the base angle
  /// 3. Extends lines to screen edges using trigonometric calculations
  /// 4. Creates triangular fill paths between adjacent lines
  /// 5. Applies alternating opacity levels for visual distinction
  ///
  /// **Parameters:**
  /// - [canvas]: The drawing canvas
  /// - [startOffset]: Starting point of the fan in screen coordinates
  /// - [deltaX]: Horizontal distance from start to end point
  /// - [deltaY]: Vertical distance from start to end point
  /// - [size]: Canvas size for boundary calculations
  /// - [paintStyle]: Paint style configuration
  /// - [fillStyle]: Fill style and color configuration
  ///
  /// **Visual Effect:**
  /// - Even-indexed areas: 10% opacity
  /// - Odd-indexed areas: 5% opacity
  /// - Creates alternating light/lighter pattern
  static void drawFanFills(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
    DrawingPaintStyle paintStyle,
    LineStyle fillStyle,
  ) {
    // Calculate the base angle from start to end point
    final double baseAngle = math.atan2(deltaY, deltaX);

    for (int i = 0; i < fibonacciLevels.length - 1; i++) {
      final double ratio1 = fibonacciLevels[i].ratio;
      final double ratio2 = fibonacciLevels[i + 1].ratio;

      // Calculate angles: 0% should point to end point, 100% should be horizontal (0 degrees)
      // Interpolate between the end angle (baseAngle) and horizontal reference (0 degrees)
      const double horizontalAngle = 0; // Horizontal reference
      final double angle1 = baseAngle + (horizontalAngle - baseAngle) * ratio1;
      final double angle2 = baseAngle + (horizontalAngle - baseAngle) * ratio2;

      // Extend lines to the edge of the screen using angle-based calculations
      final double screenWidth = size.width;
      final double distanceToEdge = screenWidth - startOffset.dx;

      // Calculate extended points using trigonometry
      final Offset extendedPoint1 = Offset(
        screenWidth,
        startOffset.dy + distanceToEdge * math.tan(angle1),
      );
      final Offset extendedPoint2 = Offset(
        screenWidth,
        startOffset.dy + distanceToEdge * math.tan(angle2),
      );

      // Validate coordinates before creating path
      if (areCoordinatesValid([startOffset, extendedPoint1, extendedPoint2])) {
        // Create path for the filled area
        final Path fillPath = Path()
          ..moveTo(startOffset.dx, startOffset.dy)
          ..lineTo(extendedPoint1.dx, extendedPoint1.dy)
          ..lineTo(extendedPoint2.dx, extendedPoint2.dy)
          ..close();

        // Draw filled area with alternating opacity
        final double opacity = (i % 2 == 0)
            ? FibfanConstants.evenFillOpacity
            : FibfanConstants.oddFillOpacity;
        canvas.drawPath(
          fillPath,
          paintStyle.fillPaintStyle(
            fillStyle.color.withOpacity(opacity),
            fillStyle.thickness,
          ),
        );
      }
    }
  }

  /// Draws the fan lines representing Fibonacci retracement levels using angle-based calculations.
  ///
  /// Creates the main trend lines of the Fibonacci fan, each representing
  /// a different retracement level. Lines extend from the start point to
  /// the screen edge, with each line angled according to its Fibonacci ratio
  /// as a percentage of the base angle.
  ///
  /// **Algorithm:**
  /// 1. Calculates the base angle from start to end point
  /// 2. For each Fibonacci ratio, calculates the angle as a percentage of the base angle
  /// 3. Determines line color (custom or default)
  /// 4. Extends line to screen edge using trigonometric calculations
  /// 5. Draws the line with appropriate styling
  ///
  /// **Parameters:**
  /// - [canvas]: The drawing canvas
  /// - [startOffset]: Starting point of the fan in screen coordinates
  /// - [deltaX]: Horizontal distance from start to end point
  /// - [deltaY]: Vertical distance from start to end point
  /// - [size]: Canvas size for boundary calculations
  /// - [paintStyle]: Paint style configuration
  /// - [lineStyle]: Default line style and color
  /// - [fibonacciLevelColors]: Optional custom colors for each level
  ///
  /// **Angle-Based Approach:**
  /// - 0%: Horizontal line (0 degrees)
  /// - 38.2%: 38.2% of the base angle
  /// - 50%: 50% of the base angle
  /// - 61.8%: 61.8% of the base angle
  /// - 100%: Full base angle (same as original trend line)
  ///
  /// **Color Mapping:**
  /// - Uses custom colors from [fibonacciLevelColors] if provided
  /// - Falls back to default [lineStyle.color] if no custom color exists
  static void drawFanLines(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle, {
    Map<String, Color>? fibonacciLevelColors,
  }) {
    // Calculate the base angle from start to end point
    final double baseAngle = math.atan2(deltaY, deltaX);

    for (int i = 0; i < fibonacciLevels.length; i++) {
      final FibonacciLevel level = fibonacciLevels[i];
      final Color lineColor = (fibonacciLevelColors != null &&
              fibonacciLevelColors.containsKey(level.colorKey))
          ? fibonacciLevelColors[level.colorKey]!
          : lineStyle.color;

      final Paint linePaint =
          getCachedLinePaint(lineColor, lineStyle.thickness);

      // Calculate angle: 0% should point to end point, 100% should be horizontal (0 degrees)
      // Interpolate between the end angle (baseAngle) and horizontal reference (0 degrees)
      const double horizontalAngle = 0; // Horizontal reference
      final double fanAngle =
          baseAngle + (horizontalAngle - baseAngle) * level.ratio;

      // Extend line to the edge of the screen using angle-based calculations
      final double screenWidth = size.width;
      final double distanceToEdge = screenWidth - startOffset.dx;

      // Calculate extended point using trigonometry
      final Offset extendedPoint = Offset(
        screenWidth,
        startOffset.dy + distanceToEdge * math.tan(fanAngle),
      );

      // Validate coordinates before drawing
      if (areTwoOffsetsValid(startOffset, extendedPoint)) {
        canvas.drawLine(startOffset, extendedPoint, linePaint);
      }
    }
  }

  /// Draws labels for the fan lines showing Fibonacci percentages using angle-based calculations.
  ///
  /// Places percentage labels (0%, 38.2%, 50%, 61.8%, 100%) next to their
  /// corresponding fan lines. Labels are rotated to align with their respective
  /// lines and positioned slightly beyond the fan endpoint for clarity.
  ///
  /// **Algorithm:**
  /// 1. Calculates the base angle from start to end point
  /// 2. For each Fibonacci ratio, calculates the angle as a percentage of the base angle
  /// 3. Positions label along the calculated angle
  /// 4. Applies canvas transformations (translate + rotate)
  /// 5. Draws the rotated text with appropriate styling
  /// 6. Restores canvas state for next label
  ///
  /// **Parameters:**
  /// - [canvas]: The drawing canvas
  /// - [startOffset]: Starting point of the fan in screen coordinates
  /// - [deltaX]: Horizontal distance from start to end point
  /// - [deltaY]: Vertical distance from start to end point
  /// - [size]: Canvas size for boundary calculations
  /// - [lineStyle]: Default line style for fallback color
  /// - [fibonacciLevelColors]: Optional custom colors for each level
  ///
  /// **Label Positioning:**
  /// - Position: Along each fan line at a fixed distance from start point
  /// - Rotation: Aligned with the angle of the corresponding fan line
  /// - Offset: 5 pixels from the line to prevent overlap
  /// - Font: 12px medium weight for readability
  ///
  /// **Color Mapping:**
  /// - Uses custom colors from [fibonacciLevelColors] if provided
  /// - Falls back to default [lineStyle.color] if no custom color exists
  static void drawFanLabels(
    Canvas canvas,
    Offset startOffset,
    double deltaX,
    double deltaY,
    Size size,
    LineStyle lineStyle, {
    Map<String, Color>? fibonacciLevelColors,
  }) {
    // Calculate the base angle from start to end point
    final double baseAngle = math.atan2(deltaY, deltaX);

    // Calculate a fixed distance for label positioning
    final double labelDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY) *
        FibfanConstants.labelPositionMultiplier;

    for (int i = 0; i < FibonacciFanHelpers.fibonacciLevels.length; i++) {
      final FibonacciLevel level = FibonacciFanHelpers.fibonacciLevels[i];

      // Calculate angle: 0% should point to end point, 100% should be horizontal (0 degrees)
      // Interpolate between the end angle (baseAngle) and horizontal reference (0 degrees)
      const double horizontalAngle = 0; // Horizontal reference
      final double fanAngle =
          baseAngle + (horizontalAngle - baseAngle) * level.ratio;

      // Calculate label position along the fan line
      final Offset labelPosition = Offset(
        startOffset.dx + labelDistance * math.cos(fanAngle),
        startOffset.dy + labelDistance * math.sin(fanAngle),
      );

      // Use custom color if provided, otherwise use default line style color
      final Color labelColor = (fibonacciLevelColors != null &&
              fibonacciLevelColors.containsKey(level.colorKey))
          ? fibonacciLevelColors[level.colorKey]!
          : lineStyle.color;

      final TextPainter textPainter = getCachedTextPainter(
        level.label,
        labelColor,
        FibfanConstants.labelFontSize,
      );

      // Save the current canvas state
      canvas
        ..save()
        // Translate to the label position
        ..translate(labelPosition.dx, labelPosition.dy)
        // Rotate the canvas by the fan angle
        ..rotate(fanAngle);

      // Adjust text position to left-align it when rotated
      final Offset textOffset = Offset(
        FibfanConstants.labelDistanceFromLine, // Small offset from the line
        -textPainter.height,
      );

      // Draw the rotated text
      textPainter.paint(canvas, textOffset);

      // Restore the canvas state
      canvas.restore();
    }
  }
}
