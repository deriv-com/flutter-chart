import 'package:collection/collection.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';

/// This calss is used to keep all the methods and data related to drawing tools
/// Which need to be shared between the DerivChart and the DrawingToolsDialog
class DrawingTools {
  /// Existing drawings.
  final List<DrawingData> drawings = <DrawingData>[];

  /// A flag to show when to stop drawing only for drawings which don't have
  /// fixed number of points like continuous drawing
  bool? shouldStopDrawing;

  /// Selected drawing tool.
  DrawingToolConfig? selectedDrawingTool;

  /// Keep the reference to the drawing tools repository.
  Repository<DrawingToolConfig>? drawingToolsRepo;

  /// For tracking the drawing movement
  bool isDrawingMoving = false;

  /// Remove unfinished drawings before openning the dialog.
  /// For the scenario where the user adds part of a drawing
  /// and then opens the dialog.
  void init() {
    if (selectedDrawingTool != null) {
      shouldStopDrawing = true;
    }
    drawings.removeWhere((DrawingData data) => !data.isDrawingFinished);
    selectedDrawingTool = null;
  }

  /// Callback to remove a drawing.
  void onDrawingToolRemoval(int index) {
    drawings.removeAt(index);
  }

  /// Callback for keeping the selected drawing tool data.
  void onDrawingToolSelection(DrawingToolConfig config) {
    shouldStopDrawing = false;
    selectedDrawingTool = config;
  }

  /// Callback for updating the drawing data list.
  void onDrawingToolUpdate(int index, DrawingToolConfig config) {
    drawings[index] = drawings[index].updateConfig(config);
  }

  /// Callback to add the new drawing to the list of drawings
  /// isInfiniteDrawing used for drawings which don't have fixed number of
  /// points
  void onAddDrawing(
    String drawingId,
    List<Drawing> drawingParts, {
    bool isDrawingFinished = false,
    bool isInfiniteDrawing = false,
  }) {
    final DrawingData? existingDrawing = drawings.firstWhereOrNull(
      (DrawingData drawing) => drawing.id == drawingId,
    );

    if (existingDrawing == null) {
      drawings.add(DrawingData(
        id: drawingId,
        config: selectedDrawingTool!,
        drawingParts: drawingParts,
        isDrawingFinished: isDrawingFinished,
      ));
    } else {
      existingDrawing
        ..updateDrawingPartList(drawingParts)
        ..isSelected = true
        ..isDrawingFinished = isDrawingFinished;
    }

    if (isDrawingFinished) {
      drawingToolsRepo!.add(selectedDrawingTool!);

      if (isInfiniteDrawing && shouldStopDrawing!) {
        selectedDrawingTool = null;
      }
      if (!isInfiniteDrawing) {
        selectedDrawingTool = null;
      }
    }

    if (drawings.length > 1) {
      drawings.removeWhere((DrawingData data) =>
          data.id != drawingId && !data.isDrawingFinished);
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
}
