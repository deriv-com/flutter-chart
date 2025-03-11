import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chart/data_visualization/chart_data.dart';
import '../chart/data_visualization/chart_series/data_series.dart';
import '../chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import '../chart/data_visualization/models/animation_info.dart';
import '../drawing_tool_chart/drawing_tools.dart';
import 'interactable_drawings/interactable_drawing.dart';
import 'interactable_drawing_custom_painter.dart';
import 'interactive_layer_base.dart';
import 'interactive_states/interactive_adding_tool_state.dart';
import 'interactive_states/interactive_normal_state.dart';
import 'interactive_states/interactive_state.dart';
import 'state_change_direction.dart';

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
    required this.quoteRange,
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

  /// Chart's y-axis range.
  final QuoteRange quoteRange;

  @override
  State<InteractiveLayer> createState() => _InteractiveLayerState();
}

class _InteractiveLayerState extends State<InteractiveLayer> {
  final List<InteractableDrawing> _interactableDrawings = [];

  /// Timer for debouncing repository updates
  Timer? _debounceTimer;

  /// Duration for debouncing repository updates (300ms is a good balance)
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    widget.drawingToolsRepo.addListener(_setDrawingsFromConfigs);
  }

  void _setDrawingsFromConfigs() {
    if (widget.drawingToolsRepo.items.length == _interactableDrawings.length) {
      return;
    }

    _interactableDrawings.clear();

    for (final config in widget.drawingToolsRepo.items) {
      _interactableDrawings.add(config.getInteractableDrawing());
    }

    setState(() {});
  }

  /// Updates the config in the repository with debouncing
  void _updateConfigInRepository(InteractableDrawing<dynamic> drawing) {
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

      // Update the config in the repository
      repo.updateAt(index, drawing.getUpdatedConfig());
    });
  }

  DrawingToolConfig _addDrawingToRepo(
      InteractableDrawing<DrawingToolConfig> drawing) {
    final config = drawing
        .getUpdatedConfig()
        .copyWith(configId: DateTime.now().millisecondsSinceEpoch.toString());

    widget.drawingToolsRepo.add(config);

    return config;
  }

  @override
  void dispose() {
    // Cancel the debounce timer when the widget is disposed
    _debounceTimer?.cancel();

    widget.drawingToolsRepo.removeListener(_setDrawingsFromConfigs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Rebuild InteractiveLayer ${widget.quoteRange} ${DateTime.now()}');
    return _InteractiveLayerGestureHandler(
      drawings: _interactableDrawings,
      epochFromX: widget.epochFromCanvasX,
      quoteFromY: widget.quoteFromCanvasY,
      epochToX: widget.epochToCanvasX,
      quoteToY: widget.quoteToCanvasY,
      series: widget.series,
      chartConfig: widget.chartConfig,
      addingDrawingTool: widget.drawingTools.selectedDrawingTool,
      quoteRange: widget.quoteRange,
      onClearAddingDrawingTool: widget.drawingTools.clearDrawingToolSelection,
      onSaveDrawingChange: _updateConfigInRepository,
      onAddDrawing: _addDrawingToRepo,
    );
  }
}

class _InteractiveLayerGestureHandler extends StatefulWidget {
  const _InteractiveLayerGestureHandler({
    required this.drawings,
    required this.epochFromX,
    required this.quoteFromY,
    required this.epochToX,
    required this.quoteToY,
    required this.series,
    required this.chartConfig,
    required this.onClearAddingDrawingTool,
    required this.onAddDrawing,
    required this.quoteRange,
    this.addingDrawingTool,
    this.onSaveDrawingChange,
  });

  final List<InteractableDrawing> drawings;

  final Function(InteractableDrawing<dynamic>)? onSaveDrawingChange;
  final DrawingToolConfig Function(InteractableDrawing<DrawingToolConfig>)
      onAddDrawing;

  final DrawingToolConfig? addingDrawingTool;

  /// To be called whenever adding the [addingDrawingTool] is done to clear it.
  final VoidCallback onClearAddingDrawingTool;

  /// Main Chart series
  final DataSeries<Tick> series;

  /// Chart configuration
  final ChartConfig chartConfig;

  final EpochFromX epochFromX;
  final QuoteFromY quoteFromY;
  final EpochToX epochToX;
  final QuoteToY quoteToY;
  final QuoteRange quoteRange;

  @override
  State<_InteractiveLayerGestureHandler> createState() =>
      _InteractiveLayerGestureHandlerState();
}

class _InteractiveLayerGestureHandlerState
    extends State<_InteractiveLayerGestureHandler>
    with SingleTickerProviderStateMixin
    implements InteractiveLayerBase {
  // InteractableDrawing? _selectedDrawing;

  late InteractiveState _interactiveState;
  late AnimationController _stateChangeController;
  static const Curve _stateChangeCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();

    _interactiveState = InteractiveNormalState(interactiveLayer: this);

    _stateChangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // register the callback
    context.read<GestureManagerState>().registerCallback(onTap);
  }

  @override
  void didUpdateWidget(covariant _InteractiveLayerGestureHandler oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.addingDrawingTool != null &&
        widget.addingDrawingTool != oldWidget.addingDrawingTool) {
      updateStateTo(
        InteractiveAddingToolState(
          widget.addingDrawingTool!,
          interactiveLayer: this,
        ),
        StateChangeAnimationDirection.forward,
      );
    }
  }

  @override
  Future<void> updateStateTo(
    InteractiveState state,
    StateChangeAnimationDirection direction, {
    bool blocking = false,
  }) async {
    if (blocking) {
      if (direction == StateChangeAnimationDirection.forward) {
        _stateChangeController.reset();
        await _stateChangeController.forward();
      } else {
        await _stateChangeController.reverse(from: 1);
      }
      setState(() => _interactiveState = state);
    } else {
      if (direction == StateChangeAnimationDirection.forward) {
        _stateChangeController.reset();
        unawaited(_stateChangeController.forward());
      } else {
        unawaited(_stateChangeController.reverse(from: 1));
      }
      _interactiveState = state;
    }
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    return MouseRegion(
      onHover: (event) {
        _interactiveState.onHover(event);
      },
      child: GestureDetector(
        onTapUp: (details) => _interactiveState.onTap(details),
        onPanStart: (details) => _interactiveState.onPanStart(details),
        onPanUpdate: (details) => _interactiveState.onPanUpdate(details),
        onPanEnd: (details) => _interactiveState.onPanEnd(details),
        // TODO(NA): Move this part into separate widget. InteractiveLayer only cares about the interactions and selected tool movement
        // It can delegate it to an inner component as well. which we can have different interaction behaviours like per platform as well.
        child: AnimatedBuilder(
            animation: _stateChangeController,
            builder: (_, __) {
              final double animationValue =
                  _stateChangeCurve.transform(_stateChangeController.value);

              return RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ...widget.drawings
                        .map((e) => CustomPaint(
                              foregroundPainter:
                                  InteractableDrawingCustomPainter(
                                drawing: e,
                                series: widget.series,
                                theme: context.watch<ChartTheme>(),
                                chartConfig: widget.chartConfig,
                                epochFromX: xAxis.epochFromX,
                                epochToX: xAxis.xFromEpoch,
                                quoteToY: widget.quoteToY,
                                quoteFromY: widget.quoteFromY,
                                getDrawingState: _interactiveState.getToolState,
                                quoteRange: widget.quoteRange,
                                epochRange: EpochRange(
                                  leftEpoch: xAxis.leftBoundEpoch,
                                  rightEpoch: xAxis.rightBoundEpoch,
                                ),
                                animationInfo: AnimationInfo(
                                  stateChangePercent: animationValue,
                                ),
                              ),
                            ))
                        .toList(),
                    ..._interactiveState.previewDrawings
                        .map((e) => CustomPaint(
                              foregroundPainter:
                                  InteractableDrawingCustomPainter(
                                drawing: e,
                                series: widget.series,
                                theme: context.watch<ChartTheme>(),
                                chartConfig: widget.chartConfig,
                                epochFromX: xAxis.epochFromX,
                                epochToX: xAxis.xFromEpoch,
                                quoteToY: widget.quoteToY,
                                quoteFromY: widget.quoteFromY,
                                getDrawingState: _interactiveState.getToolState,
                                quoteRange: widget.quoteRange,
                                epochRange: EpochRange(
                                  leftEpoch: xAxis.leftBoundEpoch,
                                  rightEpoch: xAxis.rightBoundEpoch,
                                ),
                                animationInfo: AnimationInfo(
                                  stateChangePercent: animationValue,
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                ),
              );
            }),
      ),
    );
  }

  void onTap(TapUpDetails details) {
    _interactiveState.onTap(details);
  }

  @override
  List<InteractableDrawing<DrawingToolConfig>> get drawings => widget.drawings;

  @override
  EpochFromX get epochFromX => widget.epochFromX;

  @override
  EpochToX get epochToX => widget.epochToX;

  @override
  QuoteFromY get quoteFromY => widget.quoteFromY;

  @override
  QuoteToY get quoteToY => widget.quoteToY;

  @override
  void clearAddingDrawing() => widget.onClearAddingDrawingTool.call();

  @override
  DrawingToolConfig onAddDrawing(
          InteractableDrawing<DrawingToolConfig> drawing) =>
      widget.onAddDrawing.call(drawing);

  @override
  void onSaveDrawing(InteractableDrawing<DrawingToolConfig> drawing) =>
      widget.onSaveDrawingChange?.call(drawing);
}
