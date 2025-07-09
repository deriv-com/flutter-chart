// ignore_for_file: deprecated_member_use_from_same_package

import 'package:collection/collection.dart';
import 'package:deriv_chart/src/add_ons/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import '../chart/data_visualization/drawing_tools/data_model/edge_point.dart';

/// Callback to notify mouse enter over the addon.
typedef OnMouseEnterCallback = void Function(int index);

/// Callback to notify mouse exit over the addon.
typedef OnMouseExitCallback = void Function(int index);

/// This calss is used to keep all the methods and data related to drawing tools
/// Which need to be shared between the DerivChart and the DrawingToolsDialog
class DrawingTools {
  /// Initializes
  DrawingTools({
    this.onMouseEnterCallback,
    this.onMouseExitCallback,
  });

  /// A flag to show when to stop drawing only for drawings which don't have
  /// fixed number of points like continuous drawing
  bool? shouldStopDrawing;

  /// Selected drawing tool.
  @Deprecated('''
  This property and possibly the whole class will be removed in future versions.
  To start adding a drawing tool, instead of setting a value to 
  selectedDrawingTool, use [InteractiveLayerController.startAddingNewTool]
  method.
  ''')
  DrawingToolConfig? selectedDrawingTool;

  /// Keep the reference to the drawing tools repository.
  Repository<DrawingToolConfig>? drawingToolsRepo;

  /// For tracking the drawing movement
  bool isDrawingMoving = false;

  /// Callback to notify mouse enter over the addon.
  OnMouseEnterCallback? onMouseEnterCallback;

  /// Callback to notify mouse exit over the addon.
  OnMouseExitCallback? onMouseExitCallback;

  /// Remove unfinished drawings before openning the dialog.
  /// For the scenario where the user adds part of a drawing
  /// and then opens the dialog.
  void init() {
    if (selectedDrawingTool != null) {
      shouldStopDrawing = true;
    }

    /// Remove unfinshed drawings before openning the dialog.
    final List<DrawingData?> unfinishedDrawings = getDrawingData()
        .where((DrawingData? data) => !data!.isDrawingFinished)
        .toList();
    if (unfinishedDrawings.isNotEmpty) {
      drawingToolsRepo!
          .removeAt(getDrawingData().indexOf(unfinishedDrawings.first));
    }

    clearDrawingToolSelection();
  }

  /// Callback for keeping the selected drawing tool data.
  void onDrawingToolSelection(DrawingToolConfig config) {
    shouldStopDrawing = false;
    selectedDrawingTool = config;
  }

  /// Callback to add the new drawing to the list of drawings
  /// isInfiniteDrawing used for drawings which don't have fixed number of
  /// points
  void onAddDrawing(
    String drawingId,
    List<Drawing> drawingParts, {
    bool isDrawingFinished = false,
    bool isInfiniteDrawing = false,
    List<EdgePoint>? edgePoints,
  }) {
    final DrawingData? existingDrawing = getDrawingData().firstWhereOrNull(
      (DrawingData? drawing) => drawing!.id == drawingId,
    );

    if (existingDrawing == null) {
      selectedDrawingTool = selectedDrawingTool!.copyWith(
        configId: drawingId,
        edgePoints: edgePoints,
        drawingData: DrawingData(
          id: drawingId,
          drawingParts: drawingParts,
          isDrawingFinished: isDrawingFinished,
          isSelected: true,
        ),
      );
    }

    if (drawingToolsRepo!.items
        .where((DrawingToolConfig element) => element.configId == drawingId)
        .isEmpty) {
      if (isDrawingFinished) {
        selectedDrawingTool = selectedDrawingTool!.copyWith(
          number: drawingToolsRepo!.getNumberForNewAddOn(selectedDrawingTool!),
        );
      }
      drawingToolsRepo!.add(selectedDrawingTool!);
    }

    /// Clear the selected drawing tool if the drawing is finished
    if (isDrawingFinished &&
        ((isInfiniteDrawing && shouldStopDrawing!) || !isInfiniteDrawing)) {
      clearDrawingToolSelection();
    }

    /// Remove any unfinished drawing before adding a new one.
    final List<DrawingData?> unfinishedDrawings = getDrawingData()
        .where((DrawingData? data) =>
            data!.id != drawingId && !data.isDrawingFinished)
        .toList();

    if (unfinishedDrawings.isNotEmpty) {
      drawingToolsRepo!
          .removeAt(getDrawingData().indexOf(unfinishedDrawings.first));
    }
  }

  /// Callback to inform parent about drawing tool removal.
  void clearDrawingToolSelection() {
    selectedDrawingTool = null;
  }

  /// Callback for tracking the drawing movement.
  // ignore: use_setters_to_change_properties
  void onMoveDrawing({bool isDrawingMoved = false}) {
    isDrawingMoving = isDrawingMoved;
  }

  /// Called when mouse enters over a drawing tool.
  void onMouseEnter(int index) {
    onMouseEnterCallback?.call(index);
  }

  /// Called when mouse leaves over a drawing tool.
  void onMouseExit(int index) {
    onMouseExitCallback?.call(index);
  }

  /// A method to get the list of drawing data from the repository
  List<DrawingData?> getDrawingData() => drawingToolsRepo != null
      ? drawingToolsRepo!.items
          .map<DrawingData?>((DrawingToolConfig config) => config.drawingData)
          .toList()
      : <DrawingData>[];
}
