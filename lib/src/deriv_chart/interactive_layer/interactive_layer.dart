import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/multiple_animated_builder.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/drawing_context.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/types.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_selected_tool_state.dart';
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
import 'interactable_drawings/drawing_v2.dart';
import 'interactable_drawings/interactable_drawing.dart';
import 'interactable_drawing_custom_painter.dart';
import 'interaction_notifier.dart';
import 'interactive_layer_base.dart';
import 'enums/state_change_direction.dart';
import 'interactive_layer_behaviours/interactive_layer_behaviour.dart';
import 'interactive_layer_states/interactive_normal_state.dart';

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
  final Map<String, InteractableDrawing> _interactableDrawings =
      <String, InteractableDrawing>{};

  @override
  void initState() {
    super.initState();

    widget.drawingToolsRepo.addListener(syncDrawingsWithConfigs);
  }

  void syncDrawingsWithConfigs() {
    final configListIds =
        widget.drawingToolsRepo.items.map((c) => c.configId).toSet();

    for (final config in widget.drawingToolsRepo.items) {
      if (!_interactableDrawings.containsKey(config.configId)) {
        // Add new drawing if it doesn't exist
        final drawing = config.getInteractableDrawing(
          widget.interactiveLayerBehaviour.interactiveLayer.drawingContext,
          widget.interactiveLayerBehaviour.getToolState,
        );
        _interactableDrawings[config.configId!] = drawing;
      }
    }

    bool anyToolRemoved = false;

    // Remove drawings that are not in the config list
    _interactableDrawings.removeWhere((id, _) {
      if (!configListIds.contains(id)) {
        anyToolRemoved = true;
        return true;
      }
      return false;
    });

    if (anyToolRemoved) {
      widget.interactiveLayerBehaviour.updateStateTo(
        InteractiveNormalState(
          interactiveLayerBehaviour: widget.interactiveLayerBehaviour,
        ),
        StateChangeAnimationDirection.forward,
      );
    }

    setState(() {});
  }

  /// Updates the config in the repository with debouncing
  void _updateConfigInRepository(DrawingToolConfig drawing) {
    final String? configId = drawing.configId;

    if (configId == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final Repository<DrawingToolConfig> repo =
        context.read<Repository<DrawingToolConfig>>();

    // Find the index of the config in the repository
    final int index =
        repo.items.indexWhere((config) => config.configId == drawing.configId);

    if (index == -1) {
      return; // Config not found
    }

    // Update the config in the repository
    repo.updateAt(index, drawing);
  }

  DrawingToolConfig _addDrawingToRepo(DrawingToolConfig drawing) {
    final config = drawing.copyWith(
      configId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    widget.drawingToolsRepo.add(config);

    return config;
  }

  @override
  void dispose() {
    widget.drawingToolsRepo.removeListener(syncDrawingsWithConfigs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InteractiveLayerGestureHandler(
      drawings: _interactableDrawings.values.toList(),
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
      onRemoveDrawing: widget.drawingToolsRepo.remove,
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
    this.onRemoveDrawing,
  });

  final List<InteractableDrawing> drawings;

  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  final Function(DrawingToolConfig)? onSaveDrawingChange;
  final Function(DrawingToolConfig)? onRemoveDrawing;

  final DrawingToolConfig Function(DrawingToolConfig) onAddDrawing;

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
  static const Curve _stateChangeCurve = Curves.easeOut;
  final InteractionNotifier _interactionNotifier = InteractionNotifier();

  String? _addedDrawing;

  @override
  AnimationController? get stateChangeAnimationController =>
      _stateChangeController;

  DrawingContext _drawingContext = DrawingContext(
    fullSize: Size.zero,
    contentSize: Size.zero,
  );

  @override
  void initState() {
    super.initState();

    _stateChangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    widget.interactiveLayerBehaviour.init(
      interactiveLayer: this,
      onUpdate: () => setState(() {}),
      stateChangeController: _stateChangeController,
    );
    // register the callback
    context.read<GestureManagerState>().registerCallback(onTap);
  }

  @override
  void didUpdateWidget(covariant _InteractiveLayerGestureHandler oldWidget) {
    super.didUpdateWidget(oldWidget);

    _checkAddingToolToLayer(oldWidget);
  }

  void _checkAddingToolToLayer(_InteractiveLayerGestureHandler oldWidget) {
    _checkNeedStartAdding(oldWidget);
    _checkIsAToolAdded();
  }

  /// Checks if user want to add a new drawing tool and starts adding it if so
  void _checkNeedStartAdding(_InteractiveLayerGestureHandler oldWidget) {
    if (widget.addingDrawingTool != null &&
        widget.addingDrawingTool != oldWidget.addingDrawingTool) {
      widget.interactiveLayerBehaviour
          .startAddingTool(widget.addingDrawingTool!);
    }
  }

  /// Checks if a tool has been added to the layer and updates the state to
  /// [InteractiveSelectedToolState] if it has.
  void _checkIsAToolAdded() {
    for (final drawing in widget.drawings) {
      if (drawing.id == _addedDrawing) {
        WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
            (_) => widget.interactiveLayerBehaviour.aNewToolsIsAdded(drawing));
        break;
      }
    }

    _addedDrawing = null;
  }

  @override
  Future<void> animateStateChange(
    StateChangeAnimationDirection direction, {
    bool animate = true,
  }) async {
    await _runAnimation(direction, animate);
  }

  Future<void> _runAnimation(
    StateChangeAnimationDirection direction,
    bool animate,
  ) async {
    if (direction == StateChangeAnimationDirection.forward) {
      _stateChangeController.reset();
      if (animate) {
        await _stateChangeController.forward();
      } else {
        _stateChangeController.value = 1.0;
      }
    } else {
      if (animate) {
        await _stateChangeController.reverse(from: 1);
      } else {
        _stateChangeController.value = 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    return LayoutBuilder(builder: (_, BoxConstraints constraints) {
      final YAxisConfig yAxisConfig = YAxisConfig.instance;

      _drawingContext = DrawingContext(
        fullSize: Size(constraints.maxWidth, constraints.maxHeight),
        contentSize: Size(
          constraints.maxWidth - yAxisConfig.cachedLabelWidth!,
          constraints.maxHeight,
        ),
      );

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
          child: Stack(
            children: [
              _buildDrawingsLayer(context, xAxis),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDrawingsLayer(BuildContext context, XAxisModel xAxis) =>
      RepaintBoundary(
        child: MultipleAnimatedBuilder(
            animations: [
              _stateChangeController,
              _interactionNotifier,
              widget.interactiveLayerBehaviour.controller
            ],
            builder: (_, __) {
              final double animationValue =
                  _stateChangeCurve.transform(_stateChangeController.value);

              return Stack(
                fit: StackFit.expand,
                children: widget.series.input.isEmpty
                    ? []
                    : [
                        ...widget.drawings
                            .where(
                              (e) =>
                                  widget.interactiveLayerBehaviour
                                      .getToolZOrder(e) ==
                                  DrawingZOrder.bottom,
                            )
                            .map((DrawingV2 drawing) => _buildDrawing(
                                  drawing,
                                  context,
                                  xAxis,
                                  animationValue,
                                ))
                            .toList(),
                        ...widget.drawings
                            .where(
                              (e) =>
                                  widget.interactiveLayerBehaviour
                                      .getToolZOrder(e) ==
                                  DrawingZOrder.top,
                            )
                            .map((DrawingV2 drawing) => _buildDrawing(
                                  drawing,
                                  context,
                                  xAxis,
                                  animationValue,
                                ))
                            .toList(),
                        ...widget.interactiveLayerBehaviour.previewDrawings
                            .map((DrawingV2 drawing) => _buildDrawing(
                                  drawing,
                                  context,
                                  xAxis,
                                  animationValue,
                                ))
                            .toList(),
                        ...widget.interactiveLayerBehaviour.previewWidgets
                      ],
              );
            }),
      );

  CustomPaint _buildDrawing(
    DrawingV2 e,
    BuildContext context,
    XAxisModel xAxis,
    double animationValue,
  ) =>
      CustomPaint(
        key: ValueKey<String>(e.id),
        foregroundPainter: InteractableDrawingCustomPainter(
          drawing: e,
          currentDrawingState: widget.interactiveLayerBehaviour.getToolState(e),
          drawingState: widget.interactiveLayerBehaviour.getToolState,
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
      );

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
  DrawingToolConfig addDrawing(DrawingToolConfig drawing) {
    final config = widget.onAddDrawing.call(drawing);
    _addedDrawing = config.configId;
    return config;
  }

  @override
  void saveDrawing(DrawingToolConfig drawing) =>
      widget.onSaveDrawingChange?.call(drawing);

  @override
  void removeDrawing(DrawingToolConfig drawing) =>
      widget.onRemoveDrawing?.call(drawing);

  @override
  void dispose() {
    _interactionNotifier.dispose();
    _stateChangeController.dispose();
    super.dispose();
  }

  @override
  DrawingContext get drawingContext => _drawingContext;
}
