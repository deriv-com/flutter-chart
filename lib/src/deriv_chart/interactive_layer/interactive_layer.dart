import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/multiple_animated_builder.dart';
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
import 'interaction_notifier.dart';
import 'interactive_layer_base.dart';
import 'enums/state_change_direction.dart';
import 'interactive_layer_behaviours/interactive_layer_behaviour.dart';

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
    required this.interactiveLayerBehaviour,
    super.key,
  });

  /// Interactive layer behaviour which defines how interactive layer should
  /// behave in scenarios like adding/dragging, etc.
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

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

  /// Timers for debouncing repository updates
  ///
  /// We use a map to have one timer per each drawing tool config. This is
  /// because the request to update the config of different tools can come at
  /// the same time. If we use only one timer a new request from a different
  /// tool will cancel the previous one.
  final Map<String, Timer> _debounceTimers = <String, Timer>{};

  /// Duration for debouncing repository updates (1-sec is a good balance)
  static const Duration _debounceDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();

    widget.drawingToolsRepo.addListener(_setDrawingsFromConfigs);
  }

  void _setDrawingsFromConfigs() {
    _interactableDrawings.clear();

    for (final config in widget.drawingToolsRepo.items) {
      _interactableDrawings.add(config.getInteractableDrawing());
    }

    setState(() {});
  }

  /// Updates the config in the repository with debouncing
  void _updateConfigInRepository(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) {
    final String? configId = drawing.config.configId;

    if (configId == null) {
      return;
    }

    // Cancel any existing timer
    _debounceTimers[configId]?.cancel();

    // Create a new timer
    _debounceTimers[configId] = Timer(_debounceDuration, () {
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
    // Cancel the debounce timers when the widget is disposed
    for (final Timer timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

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
      quoteRange: widget.quoteRange,
      interactiveLayerBehaviour: widget.interactiveLayerBehaviour,
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
    required this.interactiveLayerBehaviour,
    this.addingDrawingTool,
    this.onSaveDrawingChange,
  });

  final List<InteractableDrawing> drawings;

  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  final Function(InteractableDrawing<DrawingToolConfig>)? onSaveDrawingChange;
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
  late AnimationController _stateChangeController;
  static const Curve _stateChangeCurve = Curves.easeInOut;
  final InteractionNotifier _interactionNotifier = InteractionNotifier();

  @override
  AnimationController? get stateChangeAnimationController =>
      _stateChangeController;

  final GlobalKey _layerKey = GlobalKey();

  Size? _size;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      setState(() {
        _size =
            (_layerKey.currentContext?.findRenderObject() as RenderBox?)?.size;
      });
    });

    widget.interactiveLayerBehaviour.init(
      interactiveLayer: this,
      onUpdate: () => setState(() {}),
    );

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
      widget.interactiveLayerBehaviour
          .onAddDrawingTool(widget.addingDrawingTool!);
    }
  }

  @override
  Future<void> animateStateChange(
      StateChangeAnimationDirection direction) async {
    await _runAnimation(direction);
  }

  Future<void> _runAnimation(StateChangeAnimationDirection direction) async {
    if (direction == StateChangeAnimationDirection.forward) {
      _stateChangeController.reset();
      await _stateChangeController.forward();
    } else {
      await _stateChangeController.reverse(from: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    return MouseRegion(
      onHover: (event) {
        widget.interactiveLayerBehaviour.onHover(event);
        _interactionNotifier.notify();
      },
      child: GestureDetector(
        onTapUp: (details) {
          widget.interactiveLayerBehaviour.onTap(details);
          _interactionNotifier.notify();
        },
        onPanStart: (details) {
          widget.interactiveLayerBehaviour.onPanStart(details);
          _interactionNotifier.notify();
        },
        onPanUpdate: (details) {
          widget.interactiveLayerBehaviour.onPanUpdate(details);
          _interactionNotifier.notify();
        },
        onPanEnd: (details) {
          widget.interactiveLayerBehaviour.onPanEnd(details);
          _interactionNotifier.notify();
        },
        // TODO(NA): Move this part into separate widget. InteractiveLayer only cares about the interactions and selected tool movement
        // It can delegate it to an inner component as well. which we can have different interaction behaviours like per platform as well.
        child: RepaintBoundary(
          key: _layerKey,
          child: MultipleAnimatedBuilder(
              animations: [_stateChangeController, _interactionNotifier],
              builder: (_, __) {
                final double animationValue =
                    _stateChangeCurve.transform(_stateChangeController.value);

                return Stack(
                  fit: StackFit.expand,
                  children: widget.series.input.isEmpty
                      ? []
                      : [
                          ...widget.drawings
                              .map((e) => CustomPaint(
                                    key: ValueKey<String>(e.id),
                                    foregroundPainter:
                                        InteractableDrawingCustomPainter(
                                      drawing: e,
                                      currentDrawingState: widget
                                          .interactiveLayerBehaviour
                                          .getToolState(e),
                                      drawingState: widget
                                          .interactiveLayerBehaviour
                                          .getToolState,
                                      series: widget.series,
                                      theme: context.watch<ChartTheme>(),
                                      chartConfig: widget.chartConfig,
                                      epochFromX: xAxis.epochFromX,
                                      epochToX: xAxis.xFromEpoch,
                                      quoteToY: widget.quoteToY,
                                      quoteFromY: widget.quoteFromY,
                                      epochRange: EpochRange(
                                        rightEpoch: xAxis.rightBoundEpoch,
                                        leftEpoch: xAxis.leftBoundEpoch,
                                      ),
                                      quoteRange: widget.quoteRange,
                                      animationInfo: AnimationInfo(
                                        stateChangePercent: animationValue,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          ...widget.interactiveLayerBehaviour.previewDrawings
                              .map((e) => CustomPaint(
                                    key: ValueKey<String>(e.id),
                                    foregroundPainter:
                                        InteractableDrawingCustomPainter(
                                            drawing: e,
                                            series: widget.series,
                                            currentDrawingState: widget
                                                .interactiveLayerBehaviour
                                                .getToolState(e),
                                            drawingState: widget
                                                .interactiveLayerBehaviour
                                                .getToolState,
                                            theme: context.watch<ChartTheme>(),
                                            chartConfig: widget.chartConfig,
                                            epochFromX: xAxis.epochFromX,
                                            epochToX: xAxis.xFromEpoch,
                                            quoteToY: widget.quoteToY,
                                            quoteFromY: widget.quoteFromY,
                                            epochRange: EpochRange(
                                              rightEpoch: xAxis.rightBoundEpoch,
                                              leftEpoch: xAxis.leftBoundEpoch,
                                            ),
                                            quoteRange: widget.quoteRange,
                                            animationInfo: AnimationInfo(
                                                stateChangePercent:
                                                    animationValue)
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
    widget.interactiveLayerBehaviour.onTap(details);
    _interactionNotifier.notify();
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

  @override
  Size? get layerSize => _size;
}
