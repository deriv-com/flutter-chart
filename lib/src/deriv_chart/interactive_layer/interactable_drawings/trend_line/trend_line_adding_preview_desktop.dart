import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/types.dart';
import 'trend_line_adding_preview.dart';

/// Desktop-specific implementation for trend line adding preview.
///
/// This class handles trend line creation and preview specifically for desktop
/// environments where users interact via mouse hover and click events. It extends
/// [TrendLineAddingPreview] to inherit shared functionality while implementing
/// desktop-specific interaction patterns.
///
/// ## Desktop Interaction Flow:
/// 1. **Hover Phase**: User moves mouse over chart, alignment guides appear
/// 2. **First Click**: Sets the start point of the trend line
/// 3. **Preview Phase**: Shows preview line from start point to mouse position
/// 4. **Second Click**: Sets the end point and completes the trend line
///
/// ## Key Features:
/// - Real-time hover feedback with alignment guides and labels
/// - Preview line that follows mouse cursor after first point is set
/// - Immediate visual feedback for point placement
/// - Consistent styling with shared base class methods
///
/// ## Usage:
/// This class is typically instantiated by the drawing system when a user
/// selects the trend line tool on a desktop platform:
///
/// ```dart
/// final preview = TrendLineAddingPreviewDesktop(
///   interactiveLayerBehaviour: desktopBehaviour,
///   interactableDrawing: trendLineDrawing,
/// );
/// ```
///
/// ## State Management:
/// - Tracks hover position for real-time preview updates
/// - Manages point creation sequence (start → end)
/// - Handles completion callback when both points are set
///
/// ## Performance Considerations:
/// - Hover events are processed efficiently without heavy computations
/// - Alignment guides are only drawn when hovering
/// - Preview line updates smoothly with mouse movement
class TrendLineAddingPreviewDesktop extends TrendLineAddingPreview {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  });

  Offset? _hoverPosition;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {}

  @override
  void paintOverYAxis(
      Canvas canvas,
      Size size,
      EpochToX epochToX,
      QuoteToY quoteToY,
      EpochFromX? epochFromX,
      QuoteFromY? quoteFromY,
      AnimationInfo animationInfo,
      ChartConfig chartConfig,
      ChartTheme chartTheme,
      GetDrawingState getDrawingState) {
    final (paintStyle, lineStyle) = getStyles();
    final EdgePoint? startPoint = interactableDrawing.startPoint;

    if (startPoint != null) {
      drawStyledPoint(
          startPoint, epochToX, quoteToY, canvas, paintStyle, lineStyle);

      if (_hoverPosition != null) {
        // endPoint doesn't exist yet and it means we're creating this line.
        // Drawing preview line from startPoint to hoverPosition.
        final Offset startPosition =
            edgePointToOffset(startPoint, epochToX, quoteToY);
        drawPreviewLine(
            canvas, startPosition, _hoverPosition!, paintStyle, lineStyle);

        // Draw alignment guides with labels
        drawAlignmentGuidesWithLabels(canvas, size, _hoverPosition!, epochToX,
            quoteToY, chartConfig, chartTheme, epochFromX, quoteFromY);
      }
    } else if (_hoverPosition != null) {
      // Show alignment guides with labels when hovering before first point is set
      drawAlignmentGuidesWithLabels(canvas, size, _hoverPosition!, epochToX,
          quoteToY, chartConfig, chartTheme, epochFromX, quoteFromY);
    }

    if (interactableDrawing.endPoint != null) {
      drawStyledPoint(interactableDrawing.endPoint!, epochToX, quoteToY, canvas,
          paintStyle, lineStyle);
    }
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
    VoidCallback onDone,
  ) {
    createPoint(details.localPosition, epochFromX, quoteFromY, onDone);
  }

  @override
  String get id => 'line-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;
}
