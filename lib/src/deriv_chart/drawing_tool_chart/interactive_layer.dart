import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chart/data_visualization/chart_data.dart';
import '../chart/data_visualization/chart_series/data_series.dart';
import '../chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import '../chart/y_axis/y_axis_config.dart';
import 'drawing_tools.dart';

/// Interactive layer of the chart package where elements can be drawn and can
/// be interacted with.
class InteractiveLayer extends StatefulWidget {
  /// Initializes the interactive layer.
  const InteractiveLayer({
    required this.drawingTools,
    required this.series,
    required this.chartConfig,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    required this.epochToCanvasX,
    required this.epochFromCanvasX,
    required this.drawingToolsRepo,
    this.selectedDrawingTool,
    super.key,
  });

  /// Drawing tools.
  final DrawingTools drawingTools;

  /// Drawing tools repo.
  final Repository<DrawingToolConfig> drawingToolsRepo;

  /// Main Chart series
  final DataSeries<Tick> series;

  /// Chart configuration
  final ChartConfig chartConfig;

  /// Converts quote to canvas Y coordinate.
  final QuoteToY quoteToCanvasY;

  /// Converts canvas Y coordinate to quote.
  final QuoteFromY quoteFromCanvasY;

  /// Converts canvas X coordinate to epoch.
  final EpochFromX epochFromCanvasX;

  /// Converts epoch to canvas X coordinate.
  final EpochToX epochToCanvasX;

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

  @override
  State<InteractiveLayer> createState() => _InteractiveLayerState();
}

class _InteractiveLayerState extends State<InteractiveLayer> {
  /// 1. Keep the state of the selected tool here, the tool that the focus is on
  /// it right now
  /// 2. provide callback to outside to let them what is the current selected tool
  /// 3. This widget will handle adding a tool, can delegate adding to inner components
  ///    but anyway it will happen here. either directly or indirectly through inner components
  /// 4. This widget knows the current selected tool, will update its position when its interacted
  /// 5. the decision to make which tool is selected based on the user click and it's coordinate will happen here
  /// 6.
  ///
  InteractableDrawing? _selectedDrawing;

  final List<InteractableDrawing> _interactableDrawings = [];

  bool _panningStartedWithAToolDragged = false;

  /// Timer for debouncing repository updates
  Timer? _debounceTimer;

  /// Duration for debouncing repository updates (300ms is a good balance)
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    widget.drawingToolsRepo.addListener(_setDrawingsFromConfigs);

    // register the callback
    context.read<GestureManagerState>().registerCallback(onTap);
  }

  void onTap(TapUpDetails details) => _ifDrawingSelected(details.localPosition);

  void _setDrawingsFromConfigs() {
    _interactableDrawings.clear();

    for (final config in widget.drawingToolsRepo.items) {
      _interactableDrawings.add(config.getInteractableDrawing());
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_selectedDrawing == null) {
      return;
    }

    // Store the original points before update
    final originalPoints = _getDrawingPoints(_selectedDrawing!);

    // Update the drawing
    _selectedDrawing!.onDragUpdate(
      details,
      widget.epochFromCanvasX,
      widget.quoteFromCanvasY,
      widget.epochToCanvasX,
      widget.quoteToCanvasY,
    );

    setState(() {});

    // Check if points have changed and update the config in the repository
    final updatedPoints = _getDrawingPoints(_selectedDrawing!);
    if (_havePointsChanged(originalPoints, updatedPoints)) {
      _updateConfigInRepository(_selectedDrawing!);
    }
  }

  /// Gets the points from a drawing (specific to each drawing type)
  List<EdgePoint> _getDrawingPoints(InteractableDrawing drawing) {
    if (drawing is LineInteractableDrawing) {
      return [drawing.startPoint, drawing.endPoint];
    }
    // Add cases for other drawing types as needed
    return [];
  }

  /// Checks if points have changed
  bool _havePointsChanged(List<EdgePoint> original, List<EdgePoint> updated) {
    if (original.length != updated.length) {
      return true;
    }

    for (int i = 0; i < original.length; i++) {
      if (original[i].epoch != updated[i].epoch ||
          original[i].quote != updated[i].quote) {
        return true;
      }
    }

    return false;
  }

  /// Updates the config in the repository with debouncing
  void _updateConfigInRepository(InteractableDrawing drawing) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Create a new timer
    _debounceTimer = Timer(_debounceDuration, () {
      // Only proceed if the widget is still mounted
      if (!mounted) {
        return;
      }

      final Repository<DrawingToolConfig> repo =
          context.read<Repository<DrawingToolConfig>>();

      // Find the index of the config in the repository
      final int index = repo.items
          .indexWhere((config) => config.configId == drawing.config.configId);

      if (index == -1) {
        return; // Config not found
      }

      // Create a new config with updated edge points
      final updatedConfig = drawing.config.copyWith(
        edgePoints: _getDrawingPoints(drawing),
      );

      // Update the config in the repository
      repo.updateAt(index, updatedConfig);
    });
  }

  @override
  void dispose() {
    // Cancel the debounce timer when the widget is disposed
    _debounceTimer?.cancel();

    widget.drawingToolsRepo.removeListener(_setDrawingsFromConfigs);
    super.dispose();
  }

  InteractableDrawing? _ifDrawingSelected(Offset position) {
    bool anyDrawingHit = false;
    InteractableDrawing? selectedDrawing;
    for (final drawing in _interactableDrawings) {
      if (drawing.hitTest(
        position,
        widget.epochToCanvasX,
        widget.quoteToCanvasY,
      )) {
        anyDrawingHit = true;
        selectedDrawing = drawing;
        _selectedDrawing = selectedDrawing;
        break;
      }
    }

    // If no drawing was hit, clear the selection
    if (!anyDrawingHit) {
      _selectedDrawing = null;
    }

    setState(() {});

    return selectedDrawing;
  }

  bool _isDrawingSelected(InteractableDrawing drawing) =>
      drawing.config.configId == _selectedDrawing?.config.configId;

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    return GestureDetector(
      onTapUp: (details) {
        _ifDrawingSelected(details.localPosition);
      },
      onPanStart: (details) {
        final selectedTool = _ifDrawingSelected(details.localPosition);
        if (selectedTool != null) {
          _panningStartedWithAToolDragged = true;
        }

        _selectedDrawing = selectedTool;
      },
      onPanUpdate: (details) {
        if (_panningStartedWithAToolDragged) {
          onPanUpdate(details);
        }
      },
      onPanEnd: (details) {
        _panningStartedWithAToolDragged = false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ..._interactableDrawings
              .map((e) => CustomPaint(
                    foregroundPainter: _DrawingPainter(
                      drawing: e,
                      series: widget.series,
                      config: e.config,
                      theme: context.watch<ChartTheme>(),
                      chartConfig: widget.chartConfig,
                      epochFromX: xAxis.epochFromX,
                      epochToX: xAxis.xFromEpoch,
                      quoteToY: widget.quoteToCanvasY,
                      quoteFromY: widget.quoteFromCanvasY,
                      isDrawingToolSelected: widget.selectedDrawingTool != null,
                      isSelected: _isDrawingSelected,
                      leftEpoch: xAxis.leftBoundEpoch,
                      rightEpoch: xAxis.rightBoundEpoch,
                      // onDrawingToolClicked: () => _selectedDrawing = e,
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

/// A callback which calling it should return if the [drawing] is selected.
typedef IsDrawingSelected = bool Function(InteractableDrawing drawing);

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawing,
    required this.series,
    required this.config,
    required this.theme,
    required this.chartConfig,
    required this.epochFromX,
    required this.epochToX,
    required this.quoteToY,
    required this.quoteFromY,
    required this.leftEpoch,
    required this.rightEpoch,
    // required this.onDrawingToolClicked,
    required this.isSelected,
    this.isDrawingToolSelected = false,
  });

  final InteractableDrawing drawing;
  final DataSeries<Tick> series;
  final DrawingToolConfig config;
  final ChartTheme theme;
  final ChartConfig chartConfig;
  final bool isDrawingToolSelected;
  final int Function(double x) epochFromX;
  final double Function(int x) epochToX;
  final double Function(double y) quoteToY;

  /// Current left epoch of the chart.
  final int leftEpoch;

  /// Current right epoch of the chart.
  final int rightEpoch;

  double Function(double) quoteFromY;

  // final Function() onDrawingToolClicked;

  /// Returns `true` if the drawing tool is selected.
  final bool Function(InteractableDrawing) isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      drawing.paint(
        canvas,
        size,
        epochToX,
        quoteToY,
        const AnimationInfo(),
        isSelected,
      );
      // TODO(NA): Paint the [drawing]
    });
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) =>
      // TODO(NA): Return true/false based on the [drawing] state
      true;

  @override
  bool shouldRebuildSemantics(_DrawingPainter oldDelegate) => false;

  @override
  bool hitTest(Offset position) {
    if (drawing.hitTest(position, epochToX, quoteToY)) {
      // onDrawingToolClicked();
      return true;
    }
    return false;
  }
}
