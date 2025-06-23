import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../chart/data_visualization/chart_data.dart';
import '../../chart/data_visualization/models/animation_info.dart';
import '../enums/drawing_tool_state.dart';
import '../helpers/types.dart';

/// The margin for hit testing.
const double hitTestMargin = 32;

/// Base interface for any drawing painted on the [InteractiveLayer] and can be
/// interacted with by the user.
///
/// This base class defines the life-cycle functionality of the drawings in
/// [InteractiveLayer], anything from gesture handling (onTap, onDrag, etc)
/// to painting the drawing on the chart.
abstract class DrawingV2 {
  /// Initializes [InteractableDrawing].
  const DrawingV2();

  /// The id of the drawing which should be unique for each drawing in
  /// [InteractiveLayer].
  String get id;

  /// Returns `true` if the drawing tool is hit by the given offset.
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY);

  /// Called when the drawing tool dragging is started.
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  );

  /// Called when the drawing tool is dragged and updates the drawing position
  /// properties based on the dragging [details].
  ///
  /// Each drawing will know how to handle and update itself accordingly based
  /// on where the dragging position is like if it's dragging a point or a line
  /// of the tool.
  ///
  /// The drawing tools will update its properties based on the dragging at
  /// runtime. Saving the new updates to a persistent storage is not the
  /// responsibility of this method.
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  );

  /// Called when the drawing tool dragging is ended.
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  );

  /// Called when the user's pointer is hovering over the drawing tool.
  void onHover(
    PointerHoverEvent event,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  );

  /// Paints the drawing tool on the chart.
  ///
  /// Whatever that is painted here it will be in the chart's excluding Y-axis
  /// area.
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  );

  /// Paints the drawing tool chart but over the Y-axis.
  ///
  /// This is useful for the drawing wants to paint something that should be
  /// visible over the Y-axis, like a horizontal line or a label.
  void paintOverYAxis(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  );

  /// Returns true if the drawing tool should repaint.
  bool shouldRepaint(
    Set<DrawingToolState> drawingState,
    DrawingV2 oldDrawing,
  );

  /// Whether this drawing is in epoch range.
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange);
}
