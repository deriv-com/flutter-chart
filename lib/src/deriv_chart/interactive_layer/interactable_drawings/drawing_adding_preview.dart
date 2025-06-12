import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_v2.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import '../enums/drawing_tool_state.dart';
import '../helpers/types.dart';
import '../interactive_layer_behaviours/interactive_layer_behaviour.dart';

/// A preview of a drawing that is being added to the [InteractiveLayer].
///
/// This class serves as a temporary visual representation during the drawing
/// tool creation process. It's responsible for:
///
/// 1. Displaying a preview of the drawing being created
/// 2. Showing alignment guides, hints, or other visual aids
/// 3. Handling user interactions during the drawing creation process
/// 4. Coordinating with the [InteractiveLayerBehaviour] to manage
///    platform-specific interactions (mobile vs desktop)
///
/// The preview exists only during the drawing addition lifecycle and is removed
/// once the drawing is fully created and added to the chart. Different drawing
/// tools will implement their own specific preview behaviors by extending this
/// class.
///
/// See also:
///   * [InteractableDrawing], which this preview helps to create
///   * [DrawingV2], the base interface for all drawings
abstract class DrawingAddingPreview<
    T extends InteractableDrawing<DrawingToolConfig>> implements DrawingV2 {
  /// Initializes the [DrawingAddingPreview].
  ///
  /// Creates a preview instance that will help visualize and manage the creation
  /// of a new drawing tool on the chart.
  DrawingAddingPreview({
    required this.interactiveLayerBehaviour,
    required this.interactableDrawing,
  });

  /// The current interactive layer behaviour which is active and defines how
  /// this preview should behave.
  ///
  /// The preview's behavior can differ significantly between platforms (desktop
  /// or mobile) due to different input methods:
  /// - On desktop: Typically uses mouse movements, clicks, and hover events
  /// - On mobile: Uses touch gestures and taps
  ///
  /// This field provides access to the appropriate behavior implementation for
  /// the current platform.
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  /// The reference to the [InteractableDrawing] instance of the drawing tool
  /// that is going to be added.
  ///
  /// This is the actual drawing object being created. The preview uses this
  /// reference to:
  /// 1. Update the drawing's properties as the user interacts with the preview
  /// 2. Access configuration settings like colors, line styles, etc.
  ///
  /// When the drawing creation is complete, this instance will be added to
  /// the interactive layer as a permanent drawing.
  final T interactableDrawing;

  /// Handles tap events during the drawing creation process.
  ///
  /// This method is called when the user taps on the chart while in the drawing
  /// addition state. It allows the drawing preview to:
  ///
  /// 1. Capture coordinates needed to define the drawing's shape and position
  /// 2. Update the underlying [interactableDrawing] with these coordinates
  /// 3. Determine when the drawing creation is complete.
  ///
  /// Different drawing tools require different numbers of taps to complete:
  /// - A horizontal line may require just one tap to define its position
  /// - A trend line requires two taps to define start and end points
  /// - A rectangle or triangle may require multiple taps to define vertices
  ///
  /// When the drawing has received all necessary inputs, it should call the
  /// [onDone] callback to signal that creation is complete.
  ///
  /// Parameters:
  /// - [details]: Information about the tap event
  /// - [epochFromX]: Function to convert X coordinate to epoch (timestamp)
  /// - [quoteFromY]: Function to convert Y coordinate to price/quote value
  /// - [epochToX]: Function to convert epoch (timestamp) to X coordinate
  /// - [quoteToY]: Function to convert price/quote value to Y coordinate
  /// - [onDone]: Callback to invoke when drawing creation is complete
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
    VoidCallback onDone,
  );

  /// Handles the start of a drag gesture during drawing creation.
  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  /// Handles updates during a drag gesture for drawing creation.
  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  /// Handles the end of a drag gesture during drawing creation.
  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  /// Handles hover events during drawing creation (desktop platforms).
  @override
  void onHover(
    PointerHoverEvent event,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  @override
  void paintOverYAxis(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {}

  /// Determines if the drawing preview is within the current chart viewport.
  ///
  /// For drawing previews, this always returns `true` because the preview
  /// is always be visible during the drawing creation process.
  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) => true;

  /// Determines if the drawing preview needs to be repainted.
  ///
  /// For drawing previews, this always returns `true` because the preview
  /// should be repainted on every frame during the drawing creation process.
  /// This ensures that the preview is always up-to-date with the latest user
  /// interactions and provides smooth visual feedback.
  ///
  /// Parameters:
  /// - [drawingState]: The current state of the drawing tool
  /// - [oldDrawing]: The previous version of this drawing
  ///
  /// Returns `true` to ensure the preview is always repainted.
  @override
  bool shouldRepaint(
    Set<DrawingToolState> drawingState,
    DrawingV2 oldDrawing,
  ) =>
      true;
}
