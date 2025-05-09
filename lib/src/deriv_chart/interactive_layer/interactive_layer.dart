import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_controller.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_widget.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_states/interactive_selected_tool_state.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
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
// ignore_for_file: public_member_api_docs

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
    required this.crosshairZoomOutAnimation,
    required this.crosshairController,
    required this.crosshairVariant,
    this.showCrosshair = true,
    this.pipSize = 4,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
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

  /// Whether to show the crosshair or not.
  final bool showCrosshair;

  /// Number of decimal digits when showing prices in the crosshair.
  final int pipSize;

  /// Called when the crosshair appears.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair disappears.
  final VoidCallback? onCrosshairDisappeared;

  /// Animation for zooming out the crosshair
  final Animation<double> crosshairZoomOutAnimation;

  /// Crosshair controller
  final CrosshairController crosshairController;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  @override
  State<InteractiveLayer> createState() => _InteractiveLayerState();
}

class _InteractiveLayerState extends State<InteractiveLayer> {
  final List<InteractableDrawing> _interactableDrawings = [];

  /// Timer for debouncing repository updates
  Timer? _debounceTimer;

  /// Duration for debouncing repository updates (1-sec is a good balance)
  static const Duration _debounceDuration = Duration(seconds: 1);

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
    return _InteractiveLayerGestureHandler(
      drawings: _interactableDrawings,
      epochFromX: widget.epochFromCanvasX,
      quoteFromY: widget.quoteFromCanvasY,
      epochToX: widget.epochToCanvasX,
      quoteToY: widget.quoteToCanvasY,
      series: widget.series,
      chartConfig: widget.chartConfig,
      addingDrawingTool: widget.drawingTools.selectedDrawingTool,
      onClearAddingDrawingTool: widget.drawingTools.clearDrawingToolSelection,
      onSaveDrawingChange: _updateConfigInRepository,
      onAddDrawing: _addDrawingToRepo,
      showCrosshair: widget.showCrosshair,
      pipSize: widget.pipSize,
      crosshairZoomOutAnimation: widget.crosshairZoomOutAnimation,
      onCrosshairAppeared: widget.onCrosshairAppeared,
      onCrosshairDisappeared: widget.onCrosshairDisappeared,
      crosshairController: widget.crosshairController,
      crosshairVariant: widget.crosshairVariant,
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
    required this.crosshairZoomOutAnimation,
    required this.crosshairController,
    required this.crosshairVariant,
    this.addingDrawingTool,
    this.onSaveDrawingChange,
    this.showCrosshair = true,
    this.pipSize = 4,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
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

  /// Whether to show the crosshair or not.
  final bool showCrosshair;

  /// Number of decimal digits when showing prices in the crosshair.
  final int pipSize;

  /// Called when the crosshair appears.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair disappears.
  final VoidCallback? onCrosshairDisappeared;

  /// Animation for zooming out the crosshair
  final Animation<double> crosshairZoomOutAnimation;

  /// Crosshair controller
  final CrosshairController crosshairController;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

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
  void dispose() {
    super.dispose();
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
    bool waitForAnimation = false,
  }) async {
    if (waitForAnimation) {
      await _runAnimation(direction);
      setState(() => _interactiveState = state);
    } else {
      unawaited(_runAnimation(direction));
      setState(() => _interactiveState = state);
    }
  }

  Future<void> _runAnimation(StateChangeAnimationDirection direction) async {
    if (direction == StateChangeAnimationDirection.forward) {
      _stateChangeController.reset();
      await _stateChangeController.forward();
    } else {
      await _stateChangeController.reverse(from: 1);
    }
  }

  void _handleHover(PointerHoverEvent event) {
    // First let the interactive state handle the hover for drawing tools
    _interactiveState.onHover(event);
    // Check if a drawing tool is being manipulated

    final bool isDrawingToolActive =
        _interactiveState is InteractiveAddingToolState ||
            _interactiveState is InteractiveSelectedToolState ||
            widget.drawings.any((drawing) => _interactiveState
                .getToolState(drawing)
                .contains(DrawingToolState.dragging));
    // Then let the crosshair controller handle the hover
    widget.crosshairController
        .onHover(event, isDrawingToolActive: isDrawingToolActive);
  }

  void _handleExit(PointerExitEvent event) {
    widget.crosshairController.onExit(event);
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    return Semantics(
      child: MouseRegion(
        onHover: _handleHover,
        onExit: _handleExit,
        child: GestureDetector(
          onTapUp: (details) {
            _interactiveState.onTap(details);
          },
          onLongPressStart: (details) {
            if (!_interactiveState.onLongPressStart(details)) {
              widget.crosshairController.onLongPressStart(details);
            }
          },
          onLongPressMoveUpdate: (details) {
            if (!_interactiveState.onLongPressMoveUpdate(details)) {
              widget.crosshairController.onLongPressUpdate(details);
            }
          },
          onLongPressEnd: (details) {
            if (!_interactiveState.onLongPressEnd(details)) {
              widget.crosshairController.onLongPressEnd(details);
            }
          },
          onPanStart: (details) {
            _interactiveState.onPanStart(details);
          },
          onPanUpdate: (details) {
            _interactiveState.onPanUpdate(details);
          },
          onPanEnd: (details) {
            _interactiveState.onPanEnd(details);
          },
          // TODO(NA): Move this part into separate widget. InteractiveLayer only cares about the interactions and selected tool movement
          // It can delegate it to an inner component as well. which we can have different interaction behaviours like per platform as well.
          child: AnimatedBuilder(
              animation: _stateChangeController,
              builder: (_, __) {
                final double animationValue =
                    _stateChangeCurve.transform(_stateChangeController.value);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CrosshairWidget(
                      mainSeries: widget.series,
                      quoteToCanvasY: widget.quoteToY,
                      pipSize: widget.pipSize,
                      crosshairController: widget.crosshairController,
                      crosshairZoomOutAnimation:
                          widget.crosshairZoomOutAnimation,
                      crosshairVariant: widget.crosshairVariant,
                    ),
                    ...widget.drawings
                        .map((e) => CustomPaint(
                              foregroundPainter: InteractableDrawingCustomPainter(
                                  drawing: e,
                                  series: widget.series,
                                  theme: context.watch<ChartTheme>(),
                                  chartConfig: widget.chartConfig,
                                  epochFromX: xAxis.epochFromX,
                                  epochToX: xAxis.xFromEpoch,
                                  quoteToY: widget.quoteToY,
                                  quoteFromY: widget.quoteFromY,
                                  getDrawingState: _interactiveState.getToolState,
                                  animationInfo: AnimationInfo(
                                    stateChangePercent: animationValue,
                                  )
                                  // onDrawingToolClicked: () => _selectedDrawing = e,
                                  ),
                            ))
                        .toList(),
                    ..._interactiveState.previewDrawings
                        .map((e) => CustomPaint(
                              foregroundPainter: InteractableDrawingCustomPainter(
                                  drawing: e,
                                  series: widget.series,
                                  theme: context.watch<ChartTheme>(),
                                  chartConfig: widget.chartConfig,
                                  epochFromX: xAxis.epochFromX,
                                  epochToX: xAxis.xFromEpoch,
                                  quoteToY: widget.quoteToY,
                                  quoteFromY: widget.quoteFromY,
                                  getDrawingState:
                                      _interactiveState.getToolState,
                                  animationInfo: AnimationInfo(
                                      stateChangePercent: animationValue)
                                  // onDrawingToolClicked: () => _selectedDrawing = e,
                                  ),
                            ))
                        .toList(),
                  ],
                );
              }),
        ),
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
